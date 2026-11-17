import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/data/entity/base_url_config.dart';
import 'package:flutter_nga/providers/settings/base_url_settings_provider.dart';
import 'package:flutter_nga/ui/widget/base_url_selection_dialog.dart';

class _FakeBaseUrlSettingsNotifier extends BaseUrlSettingsNotifier {
  _FakeBaseUrlSettingsNotifier({required this.isLoading});

  final bool isLoading;
  final List<BaseUrlConfig> selected = [];

  @override
  BaseUrlSettingsState build() => BaseUrlSettingsState(
    currentConfig: BaseUrlPresets.ngaOfficial,
    isLoading: isLoading,
  );

  @override
  Future<void> setBaseUrlConfig(BaseUrlConfig config) async {
    selected.add(config);
  }
}

Future<_FakeBaseUrlSettingsNotifier> _pumpDialog(
  WidgetTester tester, {
  bool isLoading = false,
}) async {
  final notifier = _FakeBaseUrlSettingsNotifier(isLoading: isLoading);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [baseUrlSettingsProvider.overrideWith(() => notifier)],
      child: const MaterialApp(home: Scaffold(body: BaseUrlSelectionDialog())),
    ),
  );
  return notifier;
}

void main() {
  testWidgets('RadioGroup marks the current config as selected', (
    tester,
  ) async {
    await _pumpDialog(tester);

    final group = tester.widget<RadioGroup<BaseUrlConfig>>(
      find.byType(RadioGroup<BaseUrlConfig>),
    );
    expect(group.groupValue, BaseUrlPresets.ngaOfficial);
    expect(find.byType(RadioListTile<BaseUrlConfig>), findsNWidgets(3));
  });

  testWidgets('tapping another option switches the base url', (tester) async {
    final notifier = await _pumpDialog(tester);

    await tester.tap(find.text(BaseUrlPresets.ngaBbs.name));
    await tester.pumpAndSettle();

    expect(notifier.selected, [BaseUrlPresets.ngaBbs]);
  });

  testWidgets('tapping the selected option does nothing', (tester) async {
    final notifier = await _pumpDialog(tester);

    await tester.tap(find.text(BaseUrlPresets.ngaOfficial.name));
    await tester.pumpAndSettle();

    expect(notifier.selected, isEmpty);
  });

  testWidgets('options are disabled while loading', (tester) async {
    final notifier = await _pumpDialog(tester, isLoading: true);

    await tester.tap(find.text(BaseUrlPresets.ngaBbs.name));
    await tester.pumpAndSettle();

    expect(notifier.selected, isEmpty);
    final tiles = tester.widgetList<RadioListTile<BaseUrlConfig>>(
      find.byType(RadioListTile<BaseUrlConfig>),
    );
    expect(tiles.every((tile) => tile.enabled == false), isTrue);
  });
}
