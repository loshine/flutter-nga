import { webview } from '@kit.ArkWeb';
import router from '@ohos.router';
import { CookiesEventHandler } from '../entryability/CookiesEventHandler';

const LOGIN_URL = 'https://bbs.nga.cn/nuke.php?__lib=login&__act=account&login';
const SUCCESS_PREFIX = 'loginSuccess : ';

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
      Web({ src: LOGIN_URL, controller: this.controller })
        .javaScriptAccess(true)
        .domStorageAccess(true)
        .onConsole((event) => {
          const message = event.getMessage();
          if (message.startsWith(SUCCESS_PREFIX)) {
            const json = message.substring(SUCCESS_PREFIX.length);
            CookiesEventHandler.getInstance().onCookiesChanges(json);
            router.back();
          }
        })
        .width('100%')
        .height('100%')
    }
  }
}
