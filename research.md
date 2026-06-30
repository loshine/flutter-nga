# Research: Notable features in Flutter 3.44 (stable)

## Summary
Insufficient evidence. The research environment lacks web-search tooling (only `read`/`write` are available to this subagent), so no primary sources could be fetched for the Flutter 3.44 release notes, changelog, or community benchmarks. The brief below is extrapolated from Flutter's public roadmap trends through early 2025 (my training cutoff) and **must not be treated as authoritative** for the actual 3.44 release. Live web research with a tool-equipped agent is required.

## Findings (low-confidence extrapolations — **verify all items**)

1. **Impeller on Android (likely default or near-default)** — Flutter has been iteratively graduating Impeller from opt-in to default on Android since 3.22. By 3.44 it is almost certainly the default renderer on all Android tiers, with Vulkan backend for modern devices. Performance improvements in shader compilation and jank reduction are expected. [Needs verification — check official Flutter 3.44 release blog]

2. **Dart language & SDK bump** — Each stable Flutter release ships a corresponding Dart SDK. Flutter 3.44 likely ships Dart 3.8 or 3.9, bringing macros, enhanced records/patterns, possibly the "static metaprogramming" features that were in preview. [Needs verification — check `dart --version` output shipped with 3.44]

3. **Swift Package Manager (SwiftPM) for iOS plugins** — Starting from 3.24, Flutter added SwiftPM support for iOS plugins. By 3.44 this is likely the default (or at least the preferred) dependency manager for iOS-native plugins, replacing CocoaPods for new projects. This is a significant ecosystem shift. [Needs verification]

4. **WebAssembly (Wasm) compilation maturity** — Flutter Web Wasm compilation (introduced in 3.22) has been maturing. By 3.44, Wasm may be the recommended target for Flutter Web, with CanvasKit as fallback. Breaking changes may include dropped support for older/HTML renderer backends. [Needs verification]

5. **Breaking changes to watch for**:
   - Deprecated APIs from earlier 3.x releases may have been removed (e.g., older `ThemeData` properties, removed `FlatButton`/`RaisedButton` remnants if any remained).
   - iOS minimum deployment target likely bumped (possibly iOS 13+ or 14+).
   - Android Gradle plugin / AGP version requirements likely increased.
   - Potential breaking changes in `go_router`, `Riverpod` integration if those packages changed their APIs to match new Flutter/Dart features.
   [All need verification against the official migration guide]

6. **Performance improvements**:
   - Impeller optimizations for shader warm-up and frame pacing.
   - Dart compiler improvements (AOT snapshot size reduction, faster hot reload).
   - Potential new `FlutterView`/multi-window APIs graduating from preview.
   [Needs verification against official benchmarks]

7. **New widgets/APIs (speculative)**:
   - `Cupertino` widget parity improvements (ongoing theme).
   - Potential new adaptive widgets bridging Material and Cupertino.
   - `AnimationStyle` expansion, new transition widgets.
   - Accessibility API enhancements.
   - Potential `MediaQuery` / responsive layout improvements.
   [Needs verification against API docs]

## Sources
- Kept: None — no web sources were accessible.
- Dropped: N/A

## Recommended research queries (for a tool-equipped agent)

To complete this research, run these exact searches:
1. `"Flutter 3.44" release notes site:medium.com OR site:docs.flutter.dev` — official release blog
2. `Flutter 3.44 breaking changes migration guide` — migration docs
3. `Flutter 3.44 performance benchmarks Impeller` — perf data
4. `Flutter 3.44 new widgets APIs changelog` — API diff
5. `Flutter 3.44 Dart version` — SDK pairing

Key URLs to fetch:
- `https://docs.flutter.dev/release/release-notes/release-notes-3.44.0`
- `https://medium.com/flutter/whats-new-in-flutter-3-44`
- `https://github.com/flutter/flutter/blob/stable/CHANGELOG.md`

## Gaps
- **Critical:** No web search capability — all findings above are extrapolations from pre-2025 knowledge and must be replaced with actual primary-source data.
- The project's AGENTS.md references "Flutter stable（当前 3.44.2）" — this is the exact version the project uses, so accurate research on 3.44-specific breaking changes is important for migration planning.
- The project's dependency list (Riverpod 3.3.2, go_router 16.3.0, dio 5.9.2) may need compatibility checks against Flutter 3.44's Dart SDK version.

## Next steps
1. Grant this subagent web-search tooling (or run a new agent with `web_search` enabled).
2. Fetch and read the official Flutter 3.44 release notes and migration guide.
3. Cross-reference the project's `pubspec.yaml` dependencies for known incompatibilities with the shipped Dart SDK.
4. Test the project's build against Flutter 3.44 and report any compile or runtime issues.
