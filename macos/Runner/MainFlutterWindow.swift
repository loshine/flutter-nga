import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  private static let goMenuItemTag = 9001

  private var appleNativeChannel: FlutterMethodChannel?
  private var isAppleWindowStyle = false

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.minSize = NSSize(width: 760, height: 520)
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    let dynamicColorChannel = FlutterMethodChannel(
      name: "io.github.loshine.flutternga/dynamic_color",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    dynamicColorChannel.setMethodCallHandler { call, result in
      switch call.method {
      case "getAccentColor":
        guard let color = NSColor.controlAccentColor.usingColorSpace(.sRGB) else {
          result(nil)
          return
        }
        let r = Int((color.redComponent * 255.0).rounded()) & 0xFF
        let g = Int((color.greenComponent * 255.0).rounded()) & 0xFF
        let b = Int((color.blueComponent * 255.0).rounded()) & 0xFF
        result(Int(0xFF000000 | (r << 16) | (g << 8) | b))
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    let channel = FlutterMethodChannel(
      name: "io.github.loshine.flutternga/apple_native",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    self.appleNativeChannel = channel
    channel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "isLiquidGlassSupported":
        #if compiler(>=6.2)
          if #available(macOS 26.0, *) {
            result(true)
            return
          }
        #endif
        result(false)
      case "setWindowStyle":
        let args = call.arguments as? [String: Any]
        let appleStyle = args?["appleStyle"] as? Bool ?? false
        DispatchQueue.main.async {
          let inset = self?.applyWindowStyle(appleStyle: appleStyle) ?? 0
          result(inset)
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    let center = NotificationCenter.default
    center.addObserver(
      self,
      selector: #selector(handleFullScreenChange),
      name: NSWindow.willEnterFullScreenNotification,
      object: self
    )
    center.addObserver(
      self,
      selector: #selector(handleFullScreenChange),
      name: NSWindow.didEnterFullScreenNotification,
      object: self
    )
    center.addObserver(
      self,
      selector: #selector(handleFullScreenChange),
      name: NSWindow.willExitFullScreenNotification,
      object: self
    )
    center.addObserver(
      self,
      selector: #selector(handleFullScreenChange),
      name: NSWindow.didExitFullScreenNotification,
      object: self
    )

    let registrar = flutterViewController.registrar(forPlugin: "MacOSLiquidGlassBridge")
    registrar.register(
      MacOSLiquidGlassViewFactory(),
      withId: "io.github.loshine.flutternga/liquid_glass_view"
    )

    super.awakeFromNib()

    DispatchQueue.main.async { [weak self] in
      self?.configureMainMenu()
    }
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  /// 在保留 MainMenu.xib 原生 Edit 菜单（保证 WKWebView 粘贴/复制/全选/撤销与系统自动填充菜单可用）
  /// 的前提下，增量接入 FNGA 的「关于」「设置…」「前往」导航菜单项。
  private func configureMainMenu() {
    guard let mainMenu = NSApp.mainMenu else { return }

    if let appSubmenu = mainMenu.items.first?.submenu {
      for item in appSubmenu.items {
        if item.action == #selector(NSApplication.orderFrontStandardAboutPanel(_:)) {
          item.title = "关于 FNGA"
          item.target = self
          item.action = #selector(handleMenuNavigate(_:))
          item.representedObject = "/about"
        } else if item.keyEquivalent == "," {
          item.title = "设置…"
          item.target = self
          item.action = #selector(handleMenuNavigate(_:))
          item.representedObject = "/settings"
        }
      }
    }

    // 避免 Edit → Find → Find… 的 ⌘F 与「前往 → 搜索…」冲突，同时保留 Edit 下全部编辑与自动填充项。
    if mainMenu.items.count > 1, let editSubmenu = mainMenu.items[1].submenu {
      clearFindShortcut(in: editSubmenu)
    }

    if mainMenu.item(withTag: Self.goMenuItemTag) == nil {
      let goMenu = NSMenu(title: "前往")
      goMenu.addItem(makeNavigateItem(title: "搜索…", keyEquivalent: "f", route: "/search"))
      goMenu.addItem(.separator())
      goMenu.addItem(makeNavigateItem(title: "贴子收藏", keyEquivalent: "1", route: "/favourite_topics"))
      goMenu.addItem(makeNavigateItem(title: "浏览历史", keyEquivalent: "2", route: "/topic_history"))
      goMenu.addItem(makeNavigateItem(title: "短消息", keyEquivalent: "3", route: "/conversations"))
      goMenu.addItem(makeNavigateItem(title: "提醒信息", keyEquivalent: "4", route: "/notifications"))

      let goMenuItem = NSMenuItem(title: "前往", action: nil, keyEquivalent: "")
      goMenuItem.tag = Self.goMenuItemTag
      goMenuItem.submenu = goMenu
      let insertIndex = min(2, mainMenu.items.count)
      mainMenu.insertItem(goMenuItem, at: insertIndex)
    }
  }

  private func clearFindShortcut(in menu: NSMenu) {
    for item in menu.items {
      if item.keyEquivalent == "f" && item.keyEquivalentModifierMask == [.command] {
        item.keyEquivalent = ""
      }
      if let submenu = item.submenu {
        clearFindShortcut(in: submenu)
      }
    }
  }

  private func makeNavigateItem(
    title: String,
    keyEquivalent: String,
    route: String
  ) -> NSMenuItem {
    let item = NSMenuItem(
      title: title,
      action: #selector(handleMenuNavigate(_:)),
      keyEquivalent: keyEquivalent
    )
    item.target = self
    item.representedObject = route
    return item
  }

  @objc private func handleMenuNavigate(_ sender: NSMenuItem) {
    guard let route = sender.representedObject as? String else { return }
    appleNativeChannel?.invokeMethod("onMenuNavigate", arguments: route)
  }

  @objc private func handleFullScreenChange(_ notification: Notification) {
    let entering = notification.name == NSWindow.willEnterFullScreenNotification
    let exiting = notification.name == NSWindow.willExitFullScreenNotification
    let isFullScreen: Bool
    if entering {
      isFullScreen = true
    } else if exiting {
      isFullScreen = false
    } else {
      isFullScreen = styleMask.contains(.fullScreen)
    }
    let inset = currentTrafficLightInset(isFullScreen: isFullScreen)
    appleNativeChannel?.invokeMethod("onTrafficLightInsetChanged", arguments: inset)
  }

  /// 计算左上角红绿灯需要预留的水平安全区宽度；全屏或 Material 模式下返回 0。
  private func currentTrafficLightInset(isFullScreen: Bool? = nil) -> Double {
    let fullScreen = isFullScreen ?? styleMask.contains(.fullScreen)
    if !isAppleWindowStyle || fullScreen {
      return 0.0
    }
    if let zoomButton = standardWindowButton(.zoomButton), !zoomButton.isHidden {
      return Double(max(zoomButton.frame.maxX + 6.0, 68.0))
    }
    return 72.0
  }

  /// 按当前界面风格动态切换 macOS 融合透明标题栏与常规标题栏，并返回红绿灯水平安全区宽度。
  private func applyWindowStyle(appleStyle: Bool) -> Double {
    isAppleWindowStyle = appleStyle
    if appleStyle {
      styleMask.insert(.fullSizeContentView)
      titlebarAppearsTransparent = true
      titleVisibility = .hidden
      isMovableByWindowBackground = true
      if #available(macOS 11.0, *) {
        toolbarStyle = .unified
      }
      return currentTrafficLightInset()
    } else {
      styleMask.remove(.fullSizeContentView)
      titlebarAppearsTransparent = false
      titleVisibility = .visible
      isMovableByWindowBackground = false
      return 0.0
    }
  }
}

private final class MacOSLiquidGlassViewFactory: NSObject, FlutterPlatformViewFactory {
  func createArgsCodec() -> (FlutterMessageCodec & NSObjectProtocol)? {
    FlutterStandardMessageCodec.sharedInstance()
  }

  func create(
    withViewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> NSView {
    let params = args as? [String: Any]
    let cornerRadius = (params?["cornerRadius"] as? NSNumber)?.doubleValue ?? 0
    let variant = params?["variant"] as? String ?? "regular"
    let interactive = params?["interactive"] as? Bool ?? false
    let tintValue = (params?["tintColor"] as? NSNumber)?.uint32Value
    let isDark = params?["isDark"] as? Bool ?? false

    #if compiler(>=6.2)
      if #available(macOS 26.0, *) {
        let glassView = NSGlassEffectView(frame: .zero)
        glassView.style = variant == "clear" ? .clear : .regular
        glassView.cornerRadius = CGFloat(cornerRadius)
        if let tintValue {
          glassView.tintColor = Self.colorFromARGB(tintValue)
        }
        if #available(macOS 27.0, *) {
          glassView.effectIsInteractive = interactive
        }
        glassView.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
        return glassView
      }
    #endif

    let effectView = NSVisualEffectView(frame: .zero)
    effectView.blendingMode = .withinWindow
    effectView.state = .active
    effectView.material = switch variant {
    case "sidebar": .sidebar
    case "bar": .headerView
    default: .popover
    }
    effectView.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
    if cornerRadius > 0 {
      effectView.wantsLayer = true
      effectView.layer?.cornerRadius = CGFloat(cornerRadius)
      effectView.layer?.masksToBounds = true
    }
    return effectView
  }

  private static func colorFromARGB(_ argb: UInt32) -> NSColor {
    let a = CGFloat((argb >> 24) & 0xFF) / 255.0
    let r = CGFloat((argb >> 16) & 0xFF) / 255.0
    let g = CGFloat((argb >> 8) & 0xFF) / 255.0
    let b = CGFloat(argb & 0xFF) / 255.0
    return NSColor(srgbRed: r, green: g, blue: b, alpha: a)
  }
}
