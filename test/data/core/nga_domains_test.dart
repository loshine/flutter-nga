import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_nga/data/core/nga_domains.dart';

void main() {
  group('normalizeNgaImageUrl', () {
    test('rewrites dead legacy image hosts to nga.cn, keeping the path', () {
      expect(
        normalizeNgaImageUrl(
          'https://img.nga.178.com/attachments/mon_202402/17/a.jpg',
        ),
        'https://img.nga.cn/attachments/mon_202402/17/a.jpg',
      );
      expect(
        normalizeNgaImageUrl('http://img4.nga.178.com/ngabbs/medal/1.gif'),
        'https://img4.nga.cn/ngabbs/medal/1.gif',
      );
      expect(
        normalizeNgaImageUrl('//img.ngacn.cc/avatars/2002/1/a.jpg?x=1'),
        'https://img.nga.cn/avatars/2002/1/a.jpg?x=1',
      );
      expect(
        normalizeNgaImageUrl('HTTPS://IMG4.NGACN.CC/ngabbs/post/smile/ac0.png'),
        'https://img4.nga.cn/ngabbs/post/smile/ac0.png',
      );
    });

    test('leaves other urls untouched', () {
      for (final url in [
        '',
        './mon_202402/17/a.jpg',
        'https://img.nga.cn/attachments/a.jpg',
        'http://example.com/a.jpg',
        'https://bbs.nga.cn/read.php?tid=1',
        'https://img.nga.178.com.example.org/a.jpg',
        'https://evil.com/?u=https://img.nga.178.com/a.jpg',
      ]) {
        expect(normalizeNgaImageUrl(url), url);
      }
    });

    test('origins point at nga.cn', () {
      expect(ngaAttachmentBase, 'https://img.nga.cn/attachments');
      expect(isNgaHost(Uri.parse(ngaImageOrigin).host), isTrue);
      expect(isNgaHost(Uri.parse(ngaImage4Origin).host), isTrue);
    });
  });
}
