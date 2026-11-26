import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "AppleNativeBridge") else {
      return
    }
    let channel = FlutterMethodChannel(
      name: "io.github.loshine.flutternga/apple_native",
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "isLiquidGlassSupported":
        #if compiler(>=6.2)
          if #available(iOS 26.0, *) {
            result(true)
            return
          }
        #endif
        result(false)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    registrar.register(
      IOSLiquidGlassViewFactory(),
      withId: "io.github.loshine.flutternga/liquid_glass_view"
    )
  }
}

private final class IOSLiquidGlassViewFactory: NSObject, FlutterPlatformViewFactory {
  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    IOSLiquidGlassPlatformView(frame: frame, args: args as? [String: Any])
  }
}

private final class IOSLiquidGlassPlatformView: NSObject, FlutterPlatformView {
  private let containerView: UIVisualEffectView

  init(frame: CGRect, args: [String: Any]?) {
    let cornerRadius = (args?["cornerRadius"] as? NSNumber)?.doubleValue ?? 0
    let variant = args?["variant"] as? String ?? "regular"
    let interactive = args?["interactive"] as? Bool ?? false
    let tintValue = (args?["tintColor"] as? NSNumber)?.uint32Value
    let isDark = args?["isDark"] as? Bool ?? false

    let effect: UIVisualEffect
    #if compiler(>=6.2)
      if #available(iOS 26.0, *) {
        let style: UIGlassEffect.Style = variant == "clear" ? .clear : .regular
        let glassEffect = UIGlassEffect(style: style)
        glassEffect.isInteractive = interactive
        if let tintValue {
          glassEffect.tintColor = Self.colorFromARGB(tintValue)
        }
        effect = glassEffect
      } else {
        effect = UIBlurEffect(style: isDark ? .systemChromeMaterialDark : .systemChromeMaterialLight)
      }
    #else
      effect = UIBlurEffect(style: isDark ? .systemChromeMaterialDark : .systemChromeMaterialLight)
    #endif

    containerView = UIVisualEffectView(effect: effect)
    containerView.frame = frame
    containerView.backgroundColor = .clear
    containerView.isUserInteractionEnabled = false
    containerView.overrideUserInterfaceStyle = isDark ? .dark : .light
    if cornerRadius > 0 {
      containerView.layer.cornerRadius = CGFloat(cornerRadius)
      containerView.layer.cornerCurve = .continuous
      containerView.clipsToBounds = true
    }
    super.init()
  }

  func view() -> UIView {
    containerView
  }

  private static func colorFromARGB(_ argb: UInt32) -> UIColor {
    let a = CGFloat((argb >> 24) & 0xFF) / 255.0
    let r = CGFloat((argb >> 16) & 0xFF) / 255.0
    let g = CGFloat((argb >> 8) & 0xFF) / 255.0
    let b = CGFloat(argb & 0xFF) / 255.0
    return UIColor(red: r, green: g, blue: b, alpha: a)
  }
}
