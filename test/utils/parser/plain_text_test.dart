import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_nga/utils/parser/content_parser.dart';
import 'package:flutter_nga/utils/parser/plain_text.dart';

void main() {
  setUp(NgaContentParser.clearCache);

  test('strips UBB styling tags and keeps line breaks', () {
    expect(
      ngaContentToPlainText(
        '[b]加粗[/b] [color=red]红字[/color]<br/>第二行[size=120%]大字[/size]',
      ),
      '加粗 红字\n第二行大字',
    );
  });

  test('decodes html entities', () {
    expect(ngaContentToPlainText('a &amp; b &quot;c&quot;'), 'a & b "c"');
  });

  test('drops quoted floors and Reply to headers', () {
    const content =
        '[quote][pid=2,1,1]Reply[/pid] [b]Post by [uid=3]别人[/uid] '
        '(2026-01-01 10:00):[/b]<br/><br/>被引用的话[/quote]<br/>我的回复';
    expect(ngaContentToPlainText(content), '我的回复');

    const replyTo =
        '[b]Reply to [pid=2,1,1]Reply[/pid] Post by [uid=3]别人[/uid] '
        '(2026-01-01 10:00)[/b]<br/>回复正文';
    expect(ngaContentToPlainText(replyTo), '回复正文');
  });

  test('images become placeholders, links keep their text', () {
    expect(
      ngaContentToPlainText(
        '看图[img]./mon_202601/01/a.jpg[/img]<br/>'
        '[url=https://example.com]示例链接[/url]',
      ),
      '看图[图片]\n示例链接',
    );
  });

  test('collapse blocks output title and body', () {
    expect(
      ngaContentToPlainText('前文[collapse=剧透]隐藏内容[/collapse]后文'),
      '前文\n剧透\n隐藏内容\n后文',
    );
  });

  test('empty content yields empty string', () {
    expect(ngaContentToPlainText(''), '');
    expect(ngaContentToPlainText(null), '');
  });
}
