import 'dart:ui';

const String DOMAIN = "http://bbs.nga.cn/";

const String LOGIN_URL = DOMAIN + "nuke.php?__lib=login&__act=account&login";

const int TOPIC_MASK_FONT_COLOR_DEFAULT = 0;
const int TOPIC_MASK_FONT_COLOR_RED = 1;
const int TOPIC_MASK_FONT_COLOR_BLUE = 2;
const int TOPIC_MASK_FONT_COLOR_GREEN = 4;
const int TOPIC_MASK_FONT_COLOR_ORANGE = 8;
const int TOPIC_MASK_FONT_COLOR_SILVER = 16;

const int TOPIC_MASK_FONT_STYLE_BOLD = 32;
const int TOPIC_MASK_FONT_STYLE_ITALIC = 64;
const int TOPIC_MASK_FONT_STYLE_UNDERLINE = 128;

const int TOPIC_MASK_TYPE_LOCK = 1024; // 主题被锁定 2^10
const int TOPIC_MASK_TYPE_ATTACHMENT = 8192; // 主题中有附件 2^13
const int TOPIC_MASK_TYPE_ASSEMBLE = 32768; // 合集 2^15

const TEXT_COLOR_MAP = {
  "skyblue": Color(0xFF87CEEB),
  "royalblue": Color(0xFF4169E1),
  "blue": Color(0xFF0000FF),
  "darkblue": Color(0xFF00008B),
  "orange": Color(0xFFFFA500),
  "orangered": Color(0xFFFF4500),
  "crimson": Color(0xFFDC143C),
  "red": Color(0xFFFF0000),
  "firebrick": Color(0xFFB22222),
  "darkred": Color(0xFF8B0000),
  "green": Color(0xFF008000),
  "limegreen": Color(0xFF32CD32),
  "seagreen": Color(0xFF2E8B57),
  "teal": Color(0xFF008080),
  "deeppink": Color(0xFFFF1493),
  "tomato": Color(0xFFFF6347),
  "coral": Color(0xFFFF7F50),
  "purple": Color(0xFF800080),
  "indigo": Color(0xFF4B0082),
  "burlywood": Color(0xFFDEB887),
  "sandybrown": Color(0xFFF4A460),
  "chocolate": Color(0xFFD2691E),
  "silver": Color(0xFFC0C0C0),
};
