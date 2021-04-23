String getShowName(String username) {
  if (username.startsWith("#anony_")) {
    final prefix = "甲乙丙丁戊己庚辛壬癸子丑寅卯辰巳午未申酉戌亥";
    final suffix = "王李张刘陈杨黄吴赵周徐孙马朱胡林郭何高罗郑梁谢宋唐许邓冯韩曹曾彭萧蔡潘田董袁于"
        "余叶蒋杜苏魏程吕丁沈任姚卢傅钟姜崔谭廖范汪陆金石戴贾韦夏邱方侯邹熊孟秦白江阎薛"
        "尹段雷黎史龙陶贺顾毛郝龚邵万钱严赖覃洪武莫孔汤向常温康施文牛樊葛邢安齐易乔伍庞"
        "颜倪庄聂章鲁岳翟殷詹申欧耿关兰焦俞左柳甘祝包宁尚符舒阮柯纪梅童凌毕单季裴霍涂成"
        "苗谷盛曲翁冉骆蓝路游辛靳管柴蒙鲍华喻祁蒲房滕屈饶解牟艾尤阳时穆农司卓古吉缪简车"
        "项连芦麦褚娄窦戚岑景党宫费卜冷晏席卫米柏宗瞿桂全佟应臧闵苟邬边卞姬师和仇栾隋商"
        "刁沙荣巫寇桑郎甄丛仲虞敖巩明佘池查麻苑迟邝";
    final buffer = new StringBuffer();
    var i = 6;
    for (var j = 0; j <= 5; j++) {
      if (j == 0 || j == 3) {
        int pos = int.tryParse(username.substring(i + 1, i + 2), radix: 16)!;
        if (pos >= prefix.length) {
          pos = prefix.length - 1;
        } else if (pos < 0) {
          pos = 0;
        }
        buffer.write(prefix[pos]);
      } else {
        int pos = int.tryParse(username.substring(i, i + 2), radix: 16)!;
        if (pos >= suffix.length) {
          pos = suffix.length - 1;
        } else if (pos < 0) {
          pos = 0;
        }
        buffer.write(suffix[pos]);
      }
      i += 2;
    }
    return buffer.toString();
  } else {
    return username;
  }
}
