
import { FlutterAbility, FlutterEngine } from '@ohos/flutter_ohos';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import FlutterLoginPlugin from './FlutterLoginPlugin';
import FlutterCookiesPlugin from './FlutterCookiesPlugin';
import FlutterGallerySaverPlugin from './FlutterGallerySaverPlugin';

export default class EntryAbility extends FlutterAbility {
  configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    GeneratedPluginRegistrant.registerWith(flutterEngine)
    this.addPlugin(new FlutterLoginPlugin())
    this.addPlugin(new FlutterCookiesPlugin())
    this.addPlugin(new FlutterGallerySaverPlugin())
  }
}
