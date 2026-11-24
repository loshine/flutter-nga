import { FlutterPlugin, FlutterPluginBinding, EventChannel, StreamHandler, EventSink, Any } from '@ohos/flutter_ohos';
import { CookiesEventHandler } from './CookiesEventHandler';

const CHANNEL = 'io.github.loshine.flutternga.cookies/plugin';

export default class FlutterCookiesPlugin implements FlutterPlugin {
  private channel: EventChannel | null = null;

  getUniqueClassName(): string {
    return 'FlutterCookiesPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new EventChannel(binding.getBinaryMessenger(), CHANNEL);
    this.channel.setStreamHandler(new CookiesStreamHandler());
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    CookiesEventHandler.getInstance().clearEventSink();
    this.channel = null;
  }
}

class CookiesStreamHandler implements StreamHandler {
  onListen(args: Any, events: EventSink): void {
    CookiesEventHandler.getInstance().setEventSink(events);
  }

  onCancel(args: Any): void {
    CookiesEventHandler.getInstance().clearEventSink();
  }
}
