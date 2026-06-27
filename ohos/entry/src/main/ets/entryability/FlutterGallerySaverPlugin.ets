import { FlutterPlugin, FlutterPluginBinding, MethodChannel, MethodCallHandler, MethodResult, MethodCall } from '@ohos/flutter_ohos';
import http from '@ohos.net.http';
import fs from '@ohos.file.fs';
import { common } from '@kit.AbilityKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileUri } from '@kit.CoreFileKit';

const CHANNEL = 'io.github.loshine.flutternga.gallery_saver/plugin';

export default class FlutterGallerySaverPlugin implements FlutterPlugin {
  private channel: MethodChannel | null = null;
  private context: common.Context | null = null;

  getUniqueClassName(): string {
    return 'FlutterGallerySaverPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.context = binding.getApplicationContext();
    this.channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL);
    this.channel.setMethodCallHandler({
      onMethodCall: (call: MethodCall, result: MethodResult): void => {
        switch (call.method) {
          case 'save':
            const url = String(call.argument('url'));
            this.saveImage(url, result);
            break;
          default:
            result.notImplemented();
            break;
        }
      }
    });
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.channel?.setMethodCallHandler(null);
    this.channel = null;
    this.context = null;
  }

  private async saveImage(url: string, result: MethodResult): Promise<void> {
    try {
      const buffer = await this.downloadImage(url);
      if (buffer === null) {
        result.success(false);
        return;
      }
      const fileUri = await this.writeTempFile(buffer);
      const success = await this.saveToAlbum(fileUri);
      result.success(success);
    } catch (e) {
      result.success(false);
    }
  }

  private async downloadImage(url: string): Promise<ArrayBuffer | null> {
    const httpClient = http.createHttp();
    try {
      const response = await httpClient.request(url, {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.ARRAY_BUFFER,
      });
      httpClient.destroy();
      if (response.responseCode === 200) {
        return response.result as ArrayBuffer;
      }
      return null;
    } catch (e) {
      httpClient.destroy();
      return null;
    }
  }

  private async writeTempFile(buffer: ArrayBuffer): Promise<string> {
    const tempDir = this.context!.tempDir;
    const fileName = `img_${Date.now()}.jpg`;
    const filePath = `${tempDir}/${fileName}`;
    const file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
    fs.writeSync(file.fd, buffer);
    fs.closeSync(file);
    return filePath;
  }

  private async saveToAlbum(filePath: string): Promise<boolean> {
    if (this.context === null) {
      return false;
    }
    const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(this.context);
    const uri = fileUri.getUriFromPath(filePath);
    const request = photoAccessHelper.MediaAssetChangeRequest.createImageAssetRequest(this.context, uri);
    await phAccessHelper.applyChanges(request);
    return true;
  }
}
