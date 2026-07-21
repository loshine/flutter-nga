import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/utils/error_utils.dart';
import 'package:toastification/toastification.dart';

abstract final class AppToast {
  static void success(Object? message) {
    _show(message, ToastificationType.success);
  }

  /// Accepts either a display string or an arbitrary error object.
  ///
  /// Error objects are normalized via [errorMessage] so Dio/server text
  /// is preferred over noisy [Object.toString] dumps.
  static void error(Object? message) {
    _show(errorMessage(message), ToastificationType.error);
  }

  static void warning(Object? message) {
    _show(message, ToastificationType.warning);
  }

  static void info(Object? message) {
    _show(message, ToastificationType.info);
  }

  static void _show(Object? message, ToastificationType type) {
    toastification.show(
      title: Text(message?.toString() ?? ''),
      type: type,
      style: ToastificationStyle.flatColored,
      alignment: alignmentForPlatform(defaultTargetPlatform),
      autoCloseDuration: const Duration(seconds: 3),
    );
  }

  @visibleForTesting
  static AlignmentGeometry alignmentForPlatform(TargetPlatform platform) {
    return switch (platform) {
      TargetPlatform.macOS ||
      TargetPlatform.windows ||
      TargetPlatform.linux =>
        Alignment.topRight,
      _ => Alignment.topCenter,
    };
  }
}
