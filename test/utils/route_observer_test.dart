import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/utils/route_observer.dart';

class _AwarePage extends StatefulWidget {
  const _AwarePage(this.events);

  final List<String> events;

  @override
  State<_AwarePage> createState() => _AwarePageState();
}

class _AwarePageState extends State<_AwarePage> with RouteAwareSubscription {
  @override
  void didPush() => widget.events.add('didPush');

  @override
  void didPushNext() => widget.events.add('didPushNext');

  @override
  void didPopNext() => widget.events.add('didPopNext');

  @override
  void didPop() => widget.events.add('didPop');

  @override
  Widget build(BuildContext context) => const Text('aware');
}

void main() {
  testWidgets('RouteAware callbacks fire through GoRouter observers',
      (tester) async {
    final events = <String>[];
    final router = GoRouter(
      initialLocation: '/',
      observers: [appRouteObserver],
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Text('home')),
        GoRoute(path: '/aware', builder: (_, _) => _AwarePage(events)),
        GoRoute(path: '/next', builder: (_, _) => const Text('next')),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    router.push('/aware');
    await tester.pumpAndSettle();
    expect(events, ['didPush']);

    router.push('/next');
    await tester.pumpAndSettle();
    expect(events, ['didPush', 'didPushNext']);

    router.pop();
    await tester.pumpAndSettle();
    expect(events, ['didPush', 'didPushNext', 'didPopNext']);

    router.pop();
    await tester.pumpAndSettle();
    expect(events, ['didPush', 'didPushNext', 'didPopNext', 'didPop']);
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('unsubscribes when the state is disposed', (tester) async {
    final events = <String>[];
    final router = GoRouter(
      initialLocation: '/aware',
      observers: [appRouteObserver],
      routes: [
        GoRoute(path: '/aware', builder: (_, _) => _AwarePage(events)),
        GoRoute(path: '/other', builder: (_, _) => const Text('other')),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    // 用 go 替换整个栈，_AwarePage 被移除并 dispose。
    router.go('/other');
    await tester.pumpAndSettle();
    events.clear();

    router.go('/aware');
    await tester.pumpAndSettle();
    router.push('/other');
    await tester.pumpAndSettle();

    // 只有新建的页面收到事件，已销毁的旧 State 不会再收到回调。
    expect(events, ['didPush', 'didPushNext']);
  });
}
