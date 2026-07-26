import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart';

/// Regenerates Android / master launcher icons with splash-like safe-zone padding.
void main() {
  const size = 1024;
  // Keep FNGA inside adaptive-icon safe zone (~66/108 of layer).
  const targetContentWidthRatio = 0.50;
  final background = ColorRgba8(0xE0, 0xC1, 0x9E, 0xFF);

  final foregroundSrc = _decode('images/launcher/icon_foreground_1024.png');
  final monochromeSrc = _decode('images/launcher/icon_monochrome_1024.png');

  final foreground =
      _padToSafeZone(foregroundSrc, size, targetContentWidthRatio);
  final monochrome =
      _padToSafeZone(monochromeSrc, size, targetContentWidthRatio);

  final full = Image(width: size, height: size, numChannels: 4);
  fill(full, color: background);
  compositeImage(full, foreground);

  final round = _circularMask(full);

  _writePng('images/launcher/icon_foreground_1024.png', foreground);
  _writePng('images/launcher/icon_monochrome_1024.png', monochrome);
  _writePng('images/launcher/icon_1024.png', full);
  _writePng('images/launcher/splash_icon_1024.png', full);

  const densities = <String, ({int launcher, int adaptive})>{
    'mdpi': (launcher: 48, adaptive: 108),
    'hdpi': (launcher: 72, adaptive: 162),
    'xhdpi': (launcher: 96, adaptive: 216),
    'xxhdpi': (launcher: 144, adaptive: 324),
    'xxxhdpi': (launcher: 192, adaptive: 432),
  };

  for (final entry in densities.entries) {
    final dir = 'android/app/src/main/res/mipmap-${entry.key}';
    final launcherSize = entry.value.launcher;
    final adaptiveSize = entry.value.adaptive;
    _writePng(
      '$dir/ic_launcher.png',
      copyResize(full,
          width: launcherSize,
          height: launcherSize,
          interpolation: Interpolation.average),
    );
    _writePng(
      '$dir/ic_launcher_round.png',
      copyResize(round,
          width: launcherSize,
          height: launcherSize,
          interpolation: Interpolation.average),
    );
    _writePng(
      '$dir/ic_launcher_foreground.png',
      copyResize(foreground,
          width: adaptiveSize,
          height: adaptiveSize,
          interpolation: Interpolation.average),
    );
    _writePng(
      '$dir/ic_launcher_monochrome.png',
      copyResize(monochrome,
          width: adaptiveSize,
          height: adaptiveSize,
          interpolation: Interpolation.average),
    );
  }

  // Keep iOS AppIcon set in sync with the padded full icon.
  const iosIcons = <String, int>{
    'Icon-App-20x20@1x.png': 20,
    'Icon-App-20x20@2x.png': 40,
    'Icon-App-20x20@3x.png': 60,
    'Icon-App-29x29@1x.png': 29,
    'Icon-App-29x29@2x.png': 58,
    'Icon-App-29x29@3x.png': 87,
    'Icon-App-40x40@1x.png': 40,
    'Icon-App-40x40@2x.png': 80,
    'Icon-App-40x40@3x.png': 120,
    'Icon-App-60x60@2x.png': 120,
    'Icon-App-60x60@3x.png': 180,
    'Icon-App-76x76@1x.png': 76,
    'Icon-App-76x76@2x.png': 152,
    'Icon-App-83.5x83.5@2x.png': 167,
    'Icon-App-1024x1024@1x.png': 1024,
  };
  for (final entry in iosIcons.entries) {
    _writePng(
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/${entry.key}',
      copyResize(
        full,
        width: entry.value,
        height: entry.value,
        interpolation: Interpolation.average,
      ),
    );
  }

  // Web icons
  for (final entry in {
    'web/favicon.png': 16,
    'web/icons/Icon-192.png': 192,
    'web/icons/Icon-512.png': 512,
    'web/icons/Icon-maskable-192.png': 192,
    'web/icons/Icon-maskable-512.png': 512,
  }.entries) {
    _writePng(
      entry.key,
      copyResize(
        full,
        width: entry.value,
        height: entry.value,
        interpolation: Interpolation.average,
      ),
    );
  }

  stdout.writeln('Launcher icons regenerated with safe-zone padding.');
}

Image _decode(String path) {
  final image = decodeImage(File(path).readAsBytesSync());
  if (image == null) {
    stderr.writeln('Failed to decode $path');
    exit(1);
  }
  return image;
}

void _writePng(String path, Image image) {
  File(path).writeAsBytesSync(encodePng(image));
}

Image _padToSafeZone(Image src, int size, double targetContentWidthRatio) {
  final bounds = _opaqueBounds(src);
  if (bounds == null) {
    stderr.writeln('No opaque content found');
    exit(1);
  }
  final content = copyCrop(
    src,
    x: bounds.$1,
    y: bounds.$2,
    width: bounds.$3,
    height: bounds.$4,
  );
  final targetWidth = (size * targetContentWidthRatio).round();
  final scale = targetWidth / content.width;
  final targetHeight = math.max(1, (content.height * scale).round());
  final resized = copyResize(
    content,
    width: targetWidth,
    height: targetHeight,
    interpolation: Interpolation.average,
  );

  final out = Image(width: size, height: size, numChannels: 4);
  // Transparent canvas for adaptive foreground / monochrome layers.
  for (final p in out) {
    p
      ..r = 0
      ..g = 0
      ..b = 0
      ..a = 0;
  }
  compositeImage(
    out,
    resized,
    dstX: (size - resized.width) ~/ 2,
    dstY: (size - resized.height) ~/ 2,
  );
  return out;
}

(int, int, int, int)? _opaqueBounds(Image image) {
  var minX = image.width;
  var minY = image.height;
  var maxX = -1;
  var maxY = -1;
  for (final p in image) {
    if (p.a < 16) continue;
    if (p.x < minX) minX = p.x;
    if (p.y < minY) minY = p.y;
    if (p.x > maxX) maxX = p.x;
    if (p.y > maxY) maxY = p.y;
  }
  if (maxX < minX || maxY < minY) return null;
  return (minX, minY, maxX - minX + 1, maxY - minY + 1);
}

Image _circularMask(Image src) {
  final out = Image.from(src);
  final cx = (out.width - 1) / 2.0;
  final cy = (out.height - 1) / 2.0;
  final radius = math.min(cx, cy);
  final radiusSq = radius * radius;
  for (final p in out) {
    final dx = p.x - cx;
    final dy = p.y - cy;
    if (dx * dx + dy * dy > radiusSq) {
      p.a = 0;
    }
  }
  return out;
}
