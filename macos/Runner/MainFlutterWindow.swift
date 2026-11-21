import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    let channel = FlutterMethodChannel(
      name: "io.github.loshine.flutternga/dynamic_color",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    channel.setMethodCallHandler { call, result in
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

    super.awakeFromNib()
  }
}
