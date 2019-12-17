package xyz.loshine.flutternga.event

import io.flutter.plugin.common.EventChannel
import io.reactivex.BackpressureStrategy
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import io.reactivex.schedulers.Schedulers
import io.reactivex.subjects.PublishSubject

object CookiesEventHandler {

    private var cookiesSubject: PublishSubject<String>? = null
    private var disposable: Disposable? = null

    fun init(eventSink: EventChannel.EventSink) {
        cookiesSubject = PublishSubject.create<String>().apply {
            disposable = toFlowable(BackpressureStrategy.LATEST)
                    .subscribeOn(Schedulers.io())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe({ eventSink.success(it) }) { it.printStackTrace() }
        }
    }

    fun dispose() {
        if (disposable != null) {
            disposable?.dispose()
        }
        cookiesSubject = null
        disposable = null
    }

    fun onCookiesChanges(cookies: String) {
        cookiesSubject?.onNext(cookies)
    }
}