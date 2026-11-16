import 'package:flutter/widgets.dart';

/// 根 Navigator 的路由观察者，挂在 `GoRouter(observers: [appRouteObserver])` 上。
///
/// 一个 [NavigatorObserver] 同一时刻只能挂在一个 Navigator 上。若以后引入
/// `ShellRoute` / `StatefulShellRoute`，其内部页面在子 Navigator 中，需要为
/// 子 Navigator 另建一个 [RouteObserver] 传给 `ShellRoute(observers: ...)`，
/// 并让对应页面订阅那个实例。
final RouteObserver<ModalRoute<dynamic>> appRouteObserver =
    RouteObserver<ModalRoute<dynamic>>();

/// 让 [State] 自动订阅 / 取消订阅 [RouteObserver]，以接收 [RouteAware] 回调
/// （`didPush` / `didPopNext` 等）。
///
/// 默认订阅 [appRouteObserver]；子 Navigator 中的页面可覆写 [routeObserver]。
mixin RouteAwareSubscription<T extends StatefulWidget> on State<T>
    implements RouteAware {
  ModalRoute<dynamic>? _subscribedRoute;

  RouteObserver<ModalRoute<dynamic>> get routeObserver => appRouteObserver;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route == _subscribedRoute) return;
    if (_subscribedRoute != null) routeObserver.unsubscribe(this);
    _subscribedRoute = route;
    if (route != null) routeObserver.subscribe(this, route);
  }

  @override
  void dispose() {
    if (_subscribedRoute != null) routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {}

  @override
  void didPopNext() {}

  @override
  void didPop() {}

  @override
  void didPushNext() {}
}
