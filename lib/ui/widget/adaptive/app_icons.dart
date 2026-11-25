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

  static IconData grid(BuildContext context, {bool filled = false}) {
    if (context.isAppleStyle) {
      return filled
          ? CupertinoIcons.square_grid_2x2_fill
          : CupertinoIcons.square_grid_2x2;
    }
    return filled ? Icons.grid_view_rounded : Icons.grid_view_outlined;
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
      context.isAppleStyle ? CupertinoIcons.plus : Icons.add;

  static IconData addForum(BuildContext context) => context.isAppleStyle
      ? CupertinoIcons.rectangle_stack_badge_plus
      : Icons.create_new_folder_outlined;

  static IconData tag(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.number : Icons.tag;

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

  static IconData expandMore(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.chevron_down : Icons.expand_more;

  static IconData check(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.check_mark : Icons.check;

  static IconData bookmark(BuildContext context, {bool filled = false}) {
    if (context.isAppleStyle) {
      return filled ? CupertinoIcons.bookmark_fill : CupertinoIcons.bookmark;
    }
    return filled ? Icons.bookmark : Icons.bookmark_outline;
  }

  static IconData star(BuildContext context, {bool filled = false}) {
    if (context.isAppleStyle) {
      return filled ? CupertinoIcons.star_fill : CupertinoIcons.star;
    }
    return filled ? Icons.star : Icons.star_border;
  }

  static IconData history(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.clock : Icons.history_outlined;

  static IconData mail(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.chat_bubble_2 : Icons.mail_outlined;

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

  static IconData lineSpacing(BuildContext context) => context.isAppleStyle
      ? CupertinoIcons.text_alignleft
      : Icons.format_line_spacing;

  static IconData visibility(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.eye : Icons.visibility_outlined;

  static IconData block(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.nosign : Icons.block_outlined;

  static IconData shield(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.shield : Icons.shield_outlined;

  static IconData list(BuildContext context) => context.isAppleStyle
      ? CupertinoIcons.list_bullet
      : Icons.view_list_outlined;

  static IconData article(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.doc_text : Icons.article_outlined;

  static IconData tune(BuildContext context) => context.isAppleStyle
      ? CupertinoIcons.slider_horizontal_3
      : Icons.tune_outlined;

  static IconData personOff(BuildContext context) => context.isAppleStyle
      ? CupertinoIcons.person_crop_circle_badge_xmark
      : Icons.person_off_outlined;

  static IconData textSnippet(BuildContext context) => context.isAppleStyle
      ? CupertinoIcons.doc_plaintext
      : Icons.text_snippet_outlined;

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

  static IconData autoBrightness(BuildContext context) => context.isAppleStyle
      ? CupertinoIcons.circle_lefthalf_fill
      : Icons.brightness_auto;

  static IconData lightMode(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.sun_max : Icons.light_mode_outlined;

  static IconData darkMode(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.moon : Icons.dark_mode_outlined;

  static IconData wallpaper(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.sparkles : Icons.wallpaper_outlined;

  static IconData refresh(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.refresh : Icons.refresh;

  static IconData sidebar(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.sidebar_left : Icons.menu;

  static IconData delete(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.trash : Icons.delete_outline;

  static IconData openInNew(BuildContext context) => context.isAppleStyle
      ? CupertinoIcons.arrow_up_right_square
      : Icons.open_in_new;

  static IconData code(BuildContext context) => context.isAppleStyle
      ? CupertinoIcons.chevron_left_slash_chevron_right
      : Icons.code;

  static IconData bug(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.ant : Icons.bug_report_outlined;

  static IconData description(BuildContext context) => context.isAppleStyle
      ? CupertinoIcons.doc_text
      : Icons.description_outlined;

  static IconData cloud(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.cloud : Icons.cloud_outlined;

  static IconData storage(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.tray_full : Icons.storage_outlined;

  static IconData route(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.arrow_branch : Icons.route;

  static IconData timeline(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.waveform_path_ecg : Icons.timeline;

  static IconData login(BuildContext context) =>
      context.isAppleStyle ? CupertinoIcons.square_arrow_right : Icons.login;

  /// 将通用组件传入的 Material [IconData] 自动映射为 Apple 风格图标。
  static IconData resolve(BuildContext context, IconData icon) {
    if (!context.isAppleStyle) return icon;
    if (icon == Icons.article_outlined) return CupertinoIcons.doc_text;
    if (icon == Icons.forum_outlined) return CupertinoIcons.square_grid_2x2;
    if (icon == Icons.star_outline || icon == Icons.star_border) {
      return CupertinoIcons.star;
    }
    if (icon == Icons.favorite_border) return CupertinoIcons.heart;
    if (icon == Icons.history || icon == Icons.history_outlined) {
      return CupertinoIcons.clock;
    }
    if (icon == Icons.mail_outline || icon == Icons.mail_outlined) {
      return CupertinoIcons.chat_bubble_2;
    }
    if (icon == Icons.notifications_none_outlined ||
        icon == Icons.notifications_outlined) {
      return CupertinoIcons.bell;
    }
    if (icon == Icons.person_outline) return CupertinoIcons.person;
    if (icon == Icons.person_off_outlined) {
      return CupertinoIcons.person_crop_circle_badge_xmark;
    }
    if (icon == Icons.block_outlined) return CupertinoIcons.nosign;
    if (icon == Icons.chat_bubble_outline) return CupertinoIcons.chat_bubble;
    if (icon == Icons.search_off_outlined) return CupertinoIcons.search;
    if (icon == Icons.lock_outline) return CupertinoIcons.lock;
    if (icon == Icons.cloud_off_outlined) return CupertinoIcons.wifi_slash;
    if (icon == Icons.inbox_outlined) return CupertinoIcons.tray;
    return icon;
  }
}
