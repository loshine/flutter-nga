import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/ui/page/splash/splash_page.dart';
import 'package:flutter_nga/utils/theme_builder.dart';

void main() {
  testWidgets('亮色主题下展示亮色启动页背景、图标与深色系统栏图标', (tester) async {
    final completer = Completer<void>();

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeBuilder.buildLightTheme(Colors.brown),
        home: SplashPage(initData: () => completer.future),
      ),
    );

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, SplashPage.lightBackground);

    final image = tester.widget<Image>(find.byType(Image));
    final asset = image.image as AssetImage;
    expect(asset.assetName, SplashPage.lightIconAsset);

    final region = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
      find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
    );
    expect(region.value.statusBarIconBrightness, Brightness.dark);
  });

  testWidgets('暗色主题下展示暗色启动页背景、图标与浅色系统栏图标', (tester) async {
    final completer = Completer<void>();

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeBuilder.buildDarkTheme(Colors.brown),
        home: SplashPage(initData: () => completer.future),
      ),
    );

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, SplashPage.darkBackground);

    final image = tester.widget<Image>(find.byType(Image));
    final asset = image.image as AssetImage;
    expect(asset.assetName, SplashPage.darkIconAsset);

    final region = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
      find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
    );
    expect(region.value.statusBarIconBrightness, Brightness.light);
  });
}
