import Flutter
import UIKit
import Photos

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // 注册 GallerySaver 插件
    let controller = window?.rootViewController as! FlutterViewController
    let gallerySaverChannel = FlutterMethodChannel(
      name: "io.github.loshine.flutternga.gallery_saver/plugin",
      binaryMessenger: controller.binaryMessenger
    )
    
    gallerySaverChannel.setMethodCallHandler { (call, result) in
      if call.method == "save" {
        guard let args = call.arguments as? [String: Any],
              let urlString = args["url"] as? String,
              let url = URL(string: urlString) else {
          result(FlutterError(code: "INVALID_ARGS", message: "Invalid URL", details: nil))
          return
        }
        self.saveImageToGallery(url: url, result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func saveImageToGallery(url: URL, result: @escaping FlutterResult) {
    URLSession.shared.dataTask(with: url) { data, response, error in
      if let error = error {
        DispatchQueue.main.async {
          result(FlutterError(code: "DOWNLOAD_ERROR", message: error.localizedDescription, details: nil))
        }
        return
      }
      
      guard let data = data, let image = UIImage(data: data) else {
        DispatchQueue.main.async {
          result(FlutterError(code: "INVALID_IMAGE", message: "Failed to load image", details: nil))
        }
        return
      }
      
      PHPhotoLibrary.requestAuthorization { status in
        if status == .authorized || status == .limited {
          PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
          }) { success, error in
            DispatchQueue.main.async {
              if success {
                result(true)
              } else {
                result(FlutterError(code: "SAVE_ERROR", message: error?.localizedDescription ?? "Unknown error", details: nil))
              }
            }
          }
        } else {
          DispatchQueue.main.async {
            result(FlutterError(code: "PERMISSION_DENIED", message: "相册访问权限被拒绝", details: nil))
          }
        }
      }
    }.resume()
  }
}
