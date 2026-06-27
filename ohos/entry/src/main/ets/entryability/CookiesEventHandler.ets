import { EventSink } from '@ohos/flutter_ohos';

export class CookiesEventHandler {
  private static instance: CookiesEventHandler | null = null;
  private eventSink: EventSink | null = null;

  static getInstance(): CookiesEventHandler {
    if (CookiesEventHandler.instance === null) {
      CookiesEventHandler.instance = new CookiesEventHandler();
    }
    return CookiesEventHandler.instance;
  }

  setEventSink(sink: EventSink): void {
    this.eventSink = sink;
  }

  clearEventSink(): void {
    this.eventSink = null;
  }

  onCookiesChanges(json: string): void {
    if (this.eventSink !== null) {
      this.eventSink.success(json);
    }
  }
}
