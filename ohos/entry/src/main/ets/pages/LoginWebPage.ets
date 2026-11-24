import { webview } from '@kit.ArkWeb';
import router from '@ohos.router';
import { CookiesEventHandler } from '../entryability/CookiesEventHandler';

const LOGIN_URL = 'https://bbs.nga.cn/nuke.php?__lib=login&__act=account&login';
const SUCCESS_PREFIX = 'loginSuccess : ';
const APP_BAR_HEIGHT = 56;

@Entry
@Component
struct LoginWebPage {
  private controller: webview.WebviewController = new webview.WebviewController();

  aboutToAppear(): void {
    webview.WebCookieManager.clearAllCookiesSync();
  }

  aboutToDisappear(): void {
    webview.WebCookieManager.clearAllCookiesSync();
  }

  build() {
    Column() {
      Row() {
        Button() {
          Text('‹')
            .fontSize(36)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Normal)
        }
        .type(ButtonType.Normal)
        .backgroundColor(Color.Transparent)
        .width(56)
        .height(APP_BAR_HEIGHT)
        .padding(0)
        .onClick(() => router.back())

        Text('原生登录')
          .fontSize(20)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .maxLines(1)
      }
      .width('100%')
      .height(APP_BAR_HEIGHT)
      .backgroundColor('#795548')

      Web({ src: LOGIN_URL, controller: this.controller })
        .javaScriptAccess(true)
        .domStorageAccess(true)
        .onConsole((event: OnConsoleEvent): boolean => {
          const message: string = event.message.getMessage();
          if (message.startsWith(SUCCESS_PREFIX)) {
            const json: string = message.substring(SUCCESS_PREFIX.length);
            CookiesEventHandler.getInstance().onCookiesChanges(json);
            router.back();
            return true;
          }
          return false;
        })
        .width('100%')
        .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }
}
