import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoIcons;
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/providers/settings/design_style_provider.dart';

/// 平台自适应系统图标映射：Apple 风格下使用 SF Symbols 风格的 [CupertinoIcons]，
/// Material You 风格下保持 [Icons]。
abstract final class AppIcons {
  static IconData forum(BuildContext context, {bool filled = false}) {
    if (context.isAppleStyle) {
      return filled
          ? CupertinoIcons.bubble_left_bubble_right_fill
          : CupertinoIcons.bubble_left_bubble_right;
    }
    return filled ? Icons.forum : Icons.forum_outlined;
  }

  static IconData person(BuildContext context, {bool filled = false}) {
    if (context.isAppleStyle) {
      return filled ? CupertinoIcons.person_fill : CupertinoIcons.person;
    }
    return filled ? Icons.person : Icons.person_outline;
  }

  static IconData search(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.search : Icons.search;

  static IconData add(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.add : Icons.add;

  static IconData edit(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.square_pencil : Icons.edit;

  static IconData send(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.paperplane_fill : Icons.send;

  static IconData more(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.ellipsis_circle : Icons.more_vert;

  static IconData close(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.xmark : Icons.close;

  static IconData back(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.back : Icons.arrow_back;

  static IconData chevronRight(BuildContext context) => context.isAppleStyle
      ? CupertinoIcons.chevron_forward
      : Icons.chevron_right;

  static IconData chevronLeft(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.chevron_back : Icons.chevron_left;

  static IconData check(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.check_mark : Icons.check;

  static IconData bookmark(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.bookmark : Icons.bookmark_outline;

  static IconData history(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.clock : Icons.history_outlined;

  static IconData mail(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.mail : Icons.mail_outlined;

  static IconData notifications(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.bell : Icons.notifications_outlined;

  static IconData settings(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.gear : Icons.settings_outlined;

  static IconData info(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.info_circle : Icons.info_outline;

  static IconData palette(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.paintbrush : Icons.palette_outlined;

  static IconData style(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.layers_alt : Icons.style_outlined;

  static IconData textFields(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.textformat : Icons.text_fields;

  static IconData block(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.nosign : Icons.block_outlined;

  static IconData server(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.globe : Icons.dns_outlined;

  static IconData devices(BuildContext context) => context.isAppleStyle
      ? CupertinoIcons.device_laptop
      : Icons.devices_outlined;

  static IconData favorite(BuildContext context, {bool filled = false}) {
    if (context.isAppleStyle) {
      return filled ? CupertinoIcons.heart_fill : CupertinoIcons.heart;
    }
    return filled ? Icons.favorite : Icons.favorite_border;
  }

  static IconData reply(BuildContext context) => context.isAppleStyle
      ? CupertinoIcons.chat_bubble
      : Icons.chat_bubble_outline;

  static IconData lightMode(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.sun_max : Icons.light_mode_outlined;

  static IconData darkMode(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.moon : Icons.dark_mode_outlined;

  static IconData refresh(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.refresh : Icons.refresh;

  static IconData sidebar(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.sidebar_left : Icons.menu;

  static IconData delete(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.trash : Icons.delete_outline;
}
