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
