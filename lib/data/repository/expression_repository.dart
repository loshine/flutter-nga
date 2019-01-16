import 'package:flutter_nga/data/entity/emoticon.dart';

class EmoticonRepository {
  static final EmoticonRepository _singleton =
      EmoticonRepository._internal();

  static final List<EmoticonGroup> expressionGroupList = [];

  factory EmoticonRepository() {
    return _singleton;
  }

  EmoticonRepository._internal();

  List<EmoticonGroup> getEmoticonGroups() {
    if (expressionGroupList.isEmpty) {
      var expressionList = [
        Emoticon(
          content: "[s:1]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/smile.gif",
        ),
        Emoticon(
          content: "[s:2]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/mrgreen.gif",
        ),
        Emoticon(
          content: "[s:3]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/question.gif",
        ),
        Emoticon(
          content: "[s:4]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/wink.gif",
        ),
        Emoticon(
          content: "[s:5]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/redface.gif",
        ),
        Emoticon(
          content: "[s:6]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/sad.gif",
        ),
        Emoticon(
          content: "[s:7]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/cool.gif",
        ),
        Emoticon(
          content: "[s:8]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/crazy.gif",
        ),
        Emoticon(
          content: "[s:24]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/04.gif",
        ),
        Emoticon(
          content: "[s:25]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/05.gif",
        ),
        Emoticon(
          content: "[s:26]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/06.gif",
        ),
        Emoticon(
          content: "[s:27]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/07.gif",
        ),
        Emoticon(
          content: "[s:28]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/08.gif",
        ),
        Emoticon(
          content: "[s:29]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/09.gif",
        ),
        Emoticon(
          content: "[s:30]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/10.gif",
        ),
        Emoticon(
          content: "[s:32]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/12.gif",
        ),
        Emoticon(
          content: "[s:33]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/13.gif",
        ),
        Emoticon(
          content: "[s:34]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/14.gif",
        ),
        Emoticon(
          content: "[s:35]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/15.gif",
        ),
        Emoticon(
          content: "[s:36]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/16.gif",
        ),
        Emoticon(
          content: "[s:37]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/17.gif",
        ),
        Emoticon(
          content: "[s:38]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/18.gif",
        ),
        Emoticon(
          content: "[s:39]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/19.gif",
        ),
        Emoticon(
          content: "[s:40]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/20.gif",
        ),
        Emoticon(
          content: "[s:41]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/21.gif",
        ),
        Emoticon(
          content: "[s:42]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/22.gif",
        ),
        Emoticon(
          content: "[s:43]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/23.gif",
        ),
      ];
      var group = EmoticonGroup("默认", expressionList);
      expressionGroupList.add(group);

      expressionList = [
        Emoticon(
          content: "[s:ac:blink]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac0.png",
        ),
        Emoticon(
          content: "[s:ac:goodjob]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac1.png",
        ),
        Emoticon(
          content: "[s:ac:上]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac2.png",
        ),
        Emoticon(
          content: "[s:ac:中枪]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac3.png",
        ),
        Emoticon(
          content: "[s:ac:偷笑]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac4.png",
        ),
        Emoticon(
          content: "[s:ac:冷]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac5.png",
        ),
        Emoticon(
          content: "[s:ac:凌乱]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac6.png",
        ),
        Emoticon(
          content: "[s:ac:反对]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac7.png",
        ),
        Emoticon(
          content: "[s:ac:吓]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac8.png",
        ),
        Emoticon(
          content: "[s:ac:吻]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac9.png",
        ),
        Emoticon(
          content: "[s:ac:呆]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac10.png",
        ),
        Emoticon(
          content: "[s:ac:咦]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac11.png",
        ),
        Emoticon(
          content: "[s:ac:哦]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac12.png",
        ),
        Emoticon(
          content: "[s:ac:哭]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac13.png",
        ),
        Emoticon(
          content: "[s:ac:哭1]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac14.png",
        ),
        Emoticon(
          content: "[s:ac:哭笑]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac15.png",
        ),
        Emoticon(
          content: "[s:ac:哼]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac16.png",
        ),
        Emoticon(
          content: "[s:ac:喘]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac17.png",
        ),
        Emoticon(
          content: "[s:ac:喷]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac18.png",
        ),
        Emoticon(
          content: "[s:ac:嘲笑]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac19.png",
        ),
        Emoticon(
          content: "[s:ac:嘲笑1]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac20.png",
        ),
        Emoticon(
          content: "[s:ac:囧]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac21.png",
        ),
        Emoticon(
          content: "[s:ac:委屈]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac22.png",
        ),
        Emoticon(
          content: "[s:ac:心]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac23.png",
        ),
        Emoticon(
          content: "[s:ac:忧伤]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac24.png",
        ),
        Emoticon(
          content: "[s:ac:怒]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac25.png",
        ),
        Emoticon(
          content: "[s:ac:怕]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac26.png",
        ),
        Emoticon(
          content: "[s:ac:惊]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac27.png",
        ),
        Emoticon(
          content: "[s:ac:愁]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac28.png",
        ),
        Emoticon(
          content: "[s:ac:抓狂]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac29.png",
        ),
        Emoticon(
          content: "[s:ac:抠鼻]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac30.png",
        ),
        Emoticon(
          content: "[s:ac:擦汗]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac31.png",
        ),
        Emoticon(
          content: "[s:ac:无语]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac32.png",
        ),
        Emoticon(
          content: "[s:ac:晕]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac33.png",
        ),
        Emoticon(
          content: "[s:ac:汗]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac34.png",
        ),
        Emoticon(
          content: "[s:ac:瞎]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac35.png",
        ),
        Emoticon(
          content: "[s:ac:羞]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac36.png",
        ),
        Emoticon(
          content: "[s:ac:羡慕]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac37.png",
        ),
        Emoticon(
          content: "[s:ac:花痴]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac38.png",
        ),
        Emoticon(
          content: "[s:ac:茶]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac39.png",
        ),
        Emoticon(
          content: "[s:ac:衰]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac40.png",
        ),
        Emoticon(
          content: "[s:ac:计划通]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac41.png",
        ),
        Emoticon(
          content: "[s:ac:赞同]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac42.png",
        ),
        Emoticon(
          content: "[s:ac:闪光]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac43.png",
        ),
        Emoticon(
          content: "[s:ac:黑枪]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/ac44.png",
        ),
      ];
      group = EmoticonGroup("AC娘", expressionList);
      expressionGroupList.add(group);

      expressionList = [
        Emoticon(
          content: "[s:a2:goodjob]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_02.png",
        ),
        Emoticon(
          content: "[s:a2:诶嘿]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_05.png",
        ),
        Emoticon(
          content: "[s:a2:偷笑]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_03.png",
        ),
        Emoticon(
          content: "[s:a2:怒]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_04.png",
        ),
        Emoticon(
          content: "[s:a2:笑]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_07.png",
        ),
        Emoticon(
          content: "[s:a2:那个…]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_08.png",
        ),
        Emoticon(
          content: "[s:a2:哦嗬嗬嗬]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_09.png",
        ),
        Emoticon(
          content: "[s:a2:舔]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_10.png",
        ),
        Emoticon(
          content: "[s:a2:鬼脸]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_14.png",
        ),
        Emoticon(
          content: "[s:a2:冷]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_16.png",
        ),
        Emoticon(
          content: "[s:a2:大哭]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_15.png",
        ),
        Emoticon(
          content: "[s:a2:哭]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_17.png",
        ),
        Emoticon(
          content: "[s:a2:恨]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_21.png",
        ),
        Emoticon(
          content: "[s:a2:中枪]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_23.png",
        ),
        Emoticon(
          content: "[s:a2:囧]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_24.png",
        ),
        Emoticon(
          content: "[s:a2:你看看你]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_25.png",
        ),
        Emoticon(
          content: "[s:a2:doge]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_27.png",
        ),
        Emoticon(
          content: "[s:a2:自戳双目]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_28.png",
        ),
        Emoticon(
          content: "[s:a2:偷吃]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_30.png",
        ),
        Emoticon(
          content: "[s:a2:冷笑]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_31.png",
        ),
        Emoticon(
          content: "[s:a2:壁咚]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_32.png",
        ),
        Emoticon(
          content: "[s:a2:不活了]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_33.png",
        ),
        Emoticon(
          content: "[s:a2:不明觉厉]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_36.png",
        ),
        Emoticon(
          content: "[s:a2:是在下输了]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_51.png",
        ),
        Emoticon(
          content: "[s:a2:你为猴这么]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_53.png",
        ),
        Emoticon(
          content: "[s:a2:干杯]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_54.png",
        ),
        Emoticon(
          content: "[s:a2:干杯2]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_55.png",
        ),
        Emoticon(
          content: "[s:a2:异议]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_47.png",
        ),
        Emoticon(
          content: "[s:a2:认真]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_48.png",
        ),
        Emoticon(
          content: "[s:a2:你已经死了]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_45.png",
        ),
        Emoticon(
          content: "[s:a2:你这种人…]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_49.png",
        ),
        Emoticon(
          content: "[s:a2:妮可妮可妮]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_18.png",
        ),
        Emoticon(
          content: "[s:a2:惊]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_19.png",
        ),
        Emoticon(
          content: "[s:a2:抢镜头]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_52.png",
        ),
        Emoticon(
          content: "[s:a2:yes]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_26.png",
        ),
        Emoticon(
          content: "[s:a2:有何贵干]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_11.png",
        ),
        Emoticon(
          content: "[s:a2:病娇]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_12.png",
        ),
        Emoticon(
          content: "[s:a2:lucky]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_13.png",
        ),
        Emoticon(
          content: "[s:a2:poi]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_20.png",
        ),
        Emoticon(
          content: "[s:a2:囧2]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_22.png",
        ),
        Emoticon(
          content: "[s:a2:威吓]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_42.png",
        ),
        Emoticon(
          content: "[s:a2:jojo立]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_37.png",
        ),
        Emoticon(
          content: "[s:a2:jojo立2",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_38.png",
        ),
        Emoticon(
          content: "[s:a2:jojo立3]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_39.png",
        ),
        Emoticon(
          content: "[s:a2:jojo立4]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_41.png",
        ),
        Emoticon(
          content: "[s:a2:jojo立5]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/a2_40.png",
        ),
      ];
      group = EmoticonGroup("新AC娘", expressionList);
      expressionGroupList.add(group);

      expressionList = [
        Emoticon(
          content: "[s:pst:举手]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt00.png",
        ),
        Emoticon(
          content: "[s:pst:亲]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt01.png",
        ),
        Emoticon(
          content: "[s:pst:偷笑]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt02.png",
        ),
        Emoticon(
          content: "[s:pst:偷笑2]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt03.png",
        ),
        Emoticon(
          content: "[s:pst:偷笑3]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt04.png",
        ),
        Emoticon(
          content: "[s:pst:傻眼]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt05.png",
        ),
        Emoticon(
          content: "[s:pst:傻眼2]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt06.png",
        ),
        Emoticon(
          content: "[s:pst:兔子]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt07.png",
        ),
        Emoticon(
          content: "[s:pst:发光]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt08.png",
        ),
        Emoticon(
          content: "[s:pst:呆]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt09.png",
        ),
        Emoticon(
          content: "[s:pst:呆2]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt10.png",
        ),
        Emoticon(
          content: "[s:pst:呆3]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt11.png",
        ),
        Emoticon(
          content: "[s:pst:呕]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt12.png",
        ),
        Emoticon(
          content: "[s:pst:呵欠]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt13.png",
        ),
        Emoticon(
          content: "[s:pst:哭]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt14.png",
        ),
        Emoticon(
          content: "[s:pst:哭2]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt15.png",
        ),
        Emoticon(
          content: "[s:pst:哭3]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt16.png",
        ),
        Emoticon(
          content: "[s:pst:嘲笑]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt17.png",
        ),
        Emoticon(
          content: "[s:pst:基]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt18.png",
        ),
        Emoticon(
          content: "[s:pst:宅]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt19.png",
        ),
        Emoticon(
          content: "[s:pst:安慰]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt20.png",
        ),
        Emoticon(
          content: "[s:pst:幸福]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt21.png",
        ),
        Emoticon(
          content: "[s:pst:开心]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt22.png",
        ),
        Emoticon(
          content: "[s:pst:开心2]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt23.png",
        ),
        Emoticon(
          content: "[s:pst:开心3]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt24.png",
        ),
        Emoticon(
          content: "[s:pst:怀疑]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt25.png",
        ),
        Emoticon(
          content: "[s:pst:怒]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt26.png",
        ),
        Emoticon(
          content: "[s:pst:怒2]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt27.png",
        ),
        Emoticon(
          content: "[s:pst:怨]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt28.png",
        ),
        Emoticon(
          content: "[s:pst:惊吓]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt29.png",
        ),
        Emoticon(
          content: "[s:pst:惊吓2]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt30.png",
        ),
        Emoticon(
          content: "[s:pst:惊呆]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt31.png",
        ),
        Emoticon(
          content: "[s:pst:惊呆2]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt32.png",
        ),
        Emoticon(
          content: "[s:pst:惊呆3]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt33.png",
        ),
        Emoticon(
          content: "[s:pst:惨]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt34.png",
        ),
        Emoticon(
          content: "[s:pst:斜眼]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt35.png",
        ),
        Emoticon(
          content: "[s:pst:晕]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt36.png",
        ),
        Emoticon(
          content: "[s:pst:汗]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt37.png",
        ),
        Emoticon(
          content: "[s:pst:泪]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt38.png",
        ),
        Emoticon(
          content: "[s:pst:泪2]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt39.png",
        ),
        Emoticon(
          content: "[s:pst:泪3]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt40.png",
        ),
        Emoticon(
          content: "[s:pst:泪4]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt41.png",
        ),
        Emoticon(
          content: "[s:pst:满足]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt42.png",
        ),
        Emoticon(
          content: "[s:pst:满足2]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt43.png",
        ),
        Emoticon(
          content: "[s:pst:火星]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt44.png",
        ),
        Emoticon(
          content: "[s:pst:牙疼]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt45.png",
        ),
        Emoticon(
          content: "[s:pst:电击]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt46.png",
        ),
        Emoticon(
          content: "[s:pst:看戏]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt47.png",
        ),
        Emoticon(
          content: "[s:pst:眼袋]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt48.png",
        ),
        Emoticon(
          content: "[s:pst:眼镜]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt49.png",
        ),
        Emoticon(
          content: "[s:pst:笑而不语]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt50.png",
        ),
        Emoticon(
          content: "[s:pst:紧张]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt51.png",
        ),
        Emoticon(
          content: "[s:pst:美味]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt52.png",
        ),
        Emoticon(
          content: "[s:pst:背]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt53.png",
        ),
        Emoticon(
          content: "[s:pst:脸红]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt54.png",
        ),
        Emoticon(
          content: "[s:pst:脸红]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt55.png",
        ),
        Emoticon(
          content: "[s:pst:腐]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt56.png",
        ),
        Emoticon(
          content: "[s:pst:星星眼]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt57.png",
        ),
        Emoticon(
          content: "[s:pst:谢]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt58.png",
        ),
        Emoticon(
          content: "[s:pst:醉]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt59.png",
        ),
        Emoticon(
          content: "[s:pst:闷]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt60.png",
        ),
        Emoticon(
          content: "[s:pst:闷2]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt61.png",
        ),
        Emoticon(
          content: "[s:pst:音乐]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt62.png",
        ),
        Emoticon(
          content: "[s:pst:黑脸]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt63.png",
        ),
        Emoticon(
          content: "[s:pst:鼻血]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pt64.png",
        ),
      ];
      group = EmoticonGroup("潘斯特", expressionList);
      expressionGroupList.add(group);

      expressionList = [
        Emoticon(
          content: "[s:dt:ROLL]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/dt01.png",
        ),
        Emoticon(
          content: "[s:dt:上]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/dt02.png",
        ),
        Emoticon(
          content: "[s:dt:傲娇]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/dt03.png",
        ),
        Emoticon(
          content: "[s:dt:叉出去]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/dt04.png",
        ),
        Emoticon(
          content: "[s:dt:发光]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/dt05.png",
        ),
        Emoticon(
          content: "[s:dt:呵欠]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/dt06.png",
        ),
        Emoticon(
          content: "[s:dt:哭]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/dt07.png",
        ),
        Emoticon(
          content: "[s:dt:啃古头]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/dt08.png",
        ),
        Emoticon(
          content: "[s:dt:嘲笑]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/dt09.png",
        ),
        Emoticon(
          content: "[s:dt:心]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/dt10.png",
        ),
        Emoticon(
          content: "[s:dt:怒]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/dt11.png",
        ),
        Emoticon(
          content: "[s:dt:怒2]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/dt12.png",
        ),
        Emoticon(
          content: "[s:dt:怨]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/dt13.png",
        ),
        Emoticon(
          content: "[s:dt:惊]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/dt14.png",
        ),
        Emoticon(
          content: "[s:dt:惊2]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/dt15.png",
        ),
        Emoticon(
          content: "[s:dt:无语]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/dt16.png",
        ),
        Emoticon(
          content: "[s:dt:星星眼]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/dt17.png",
        ),
        Emoticon(
          content: "[s:dt:星星眼2]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/dt18.png",
        ),
        Emoticon(
          content: "[s:dt:晕]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/dt19.png",
        ),
        Emoticon(
          content: "[s:dt:注意]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/dt20.png",
        ),
        Emoticon(
          content: "[s:dt:注意2]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/dt21.png",
        ),
        Emoticon(
          content: "[s:dt:泪]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/dt22.png",
        ),
        Emoticon(
          content: "[s:dt:泪2]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/dt23.png",
        ),
        Emoticon(
          content: "[s:dt:烧]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/dt24.png",
        ),
        Emoticon(
          content: "[s:dt:笑]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/dt25.png",
        ),
        Emoticon(
          content: "[s:dt:笑2]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/dt26.png",
        ),
        Emoticon(
          content: "[s:dt:笑3]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/dt27.png",
        ),
        Emoticon(
          content: "[s:dt:脸红]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/dt28.png",
        ),
        Emoticon(
          content: "[s:dt:药]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/dt29.png",
        ),
        Emoticon(
          content: "[s:dt:衰]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/dt30.png",
        ),
        Emoticon(
          content: "[s:dt:鄙视]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/dt31.png",
        ),
        Emoticon(
          content: "[s:dt:闲]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/dt32.png",
        ),
        Emoticon(
          content: "[s:dt:黑脸]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/dt33.png",
        ),
      ];
      group = EmoticonGroup("外域三人组", expressionList);
      expressionGroupList.add(group);

      expressionList = [
        Emoticon(
          content: "[s:pg:战斗力]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pg01.png",
        ),
        Emoticon(
          content: "[s:pg:哈啤]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pg02.png",
        ),
        Emoticon(
          content: "[s:pg:满分]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pg03.png",
        ),
        Emoticon(
          content: "[s:pg:衰]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pg04.png",
        ),
        Emoticon(
          content: "[s:pg:拒绝]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pg05.png",
        ),
        Emoticon(
          content: "[s:pg:心]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pg06.png",
        ),
        Emoticon(
          content: "[s:pg:严肃]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pg07.png",
        ),
        Emoticon(
          content: "[s:pg:吃瓜]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pg08.png",
        ),
        Emoticon(
          content: "[s:pg:嘣]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pg09.png",
        ),
        Emoticon(
          content: "[s:pg:嘣2]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pg10.png",
        ),
        Emoticon(
          content: "[s:pg:冻]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pg11.png",
        ),
        Emoticon(
          content: "[s:pg:谢]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pg12.png",
        ),
        Emoticon(
          content: "[s:pg:哭]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pg13.png",
        ),
        Emoticon(
          content: "[s:pg:响指]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pg14.png",
        ),
        Emoticon(
          content: "[s:pg:转身]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/pg15.png",
        ),
      ];
      group = EmoticonGroup("企鹅", expressionList);
      expressionGroupList.add(group);
    }

    return expressionGroupList;
  }
}
