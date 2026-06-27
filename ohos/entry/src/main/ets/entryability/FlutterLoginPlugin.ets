import { FlutterPlugin, FlutterPluginBinding, MethodChannel, MethodCallHandler, MethodResult, MethodCall } from '@ohos/flutter_ohos';
import router from '@ohos.router';

const CHANNEL = 'io.github.loshine.flutternga.login/plugin';

export default class FlutterLoginPlugin implements FlutterPlugin {
  private channel: MethodChannel | null = null;

  getUniqueClassName(): string {
    return 'FlutterLoginPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL);
    this.channel.setMethodCallHandler({
      onMethodCall: (call: MethodCall, result: MethodResult): void => {
        switch (call.method) {
          case 'start_login':
            router.pushUrl({ url: 'pages/LoginWebPage' });
            result.success('success');
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
  }
}
