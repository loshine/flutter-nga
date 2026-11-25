import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
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

    let appleNativeChannel = FlutterMethodChannel(
      name: "io.github.loshine.flutternga/apple_native",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    appleNativeChannel.setMethodCallHandler { [weak self] call, result in
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

    let registrar = flutterViewController.registrar(forPlugin: "MacOSLiquidGlassBridge")
    registrar.register(
      MacOSLiquidGlassViewFactory(),
      withId: "io.github.loshine.flutternga/liquid_glass_view"
    )

    super.awakeFromNib()
  }

  /// 按当前界面风格动态切换 macOS 融合透明标题栏与常规标题栏，并返回红绿灯安全区高度。
  private func applyWindowStyle(appleStyle: Bool) -> Double {
    if appleStyle {
      styleMask.insert(.fullSizeContentView)
      titlebarAppearsTransparent = true
      titleVisibility = .hidden
      isMovableByWindowBackground = true
      let titlebarHeight = frame.height - contentLayoutRect.height
      return Double(max(titlebarHeight, 28.0))
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
