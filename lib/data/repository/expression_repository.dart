import 'package:flutter_nga/data/entity/expression.dart';

class ExpressionRepository {
  static final ExpressionRepository _singleton =
      ExpressionRepository._internal();

  static final List<ExpressionGroup> expressionGroupList = [];

  factory ExpressionRepository() {
    return _singleton;
  }

  ExpressionRepository._internal();

  List<ExpressionGroup> getExpressionGroups() {
    if (expressionGroupList.isEmpty) {
      var expressionList = [
        Expression(
          content: "[s:1]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/smile.gif",
        ),
        Expression(
          content: "[s:2]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/mrgreen.gif",
        ),
        Expression(
          content: "[s:3]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/question.gif",
        ),
        Expression(
          content: "[s:4]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/wink.gif",
        ),
        Expression(
          content: "[s:5]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/redface.gif",
        ),
        Expression(
          content: "[s:6]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/sad.gif",
        ),
        Expression(
          content: "[s:7]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/cool.gif",
        ),
        Expression(
          content: "[s:8]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/crazy.gif",
        ),
        Expression(
          content: "[s:24]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/04.gif",
        ),
        Expression(
          content: "[s:25]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/05.gif",
        ),
        Expression(
          content: "[s:26]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/06.gif",
        ),
        Expression(
          content: "[s:27]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/07.gif",
        ),
        Expression(
          content: "[s:28]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/08.gif",
        ),
        Expression(
          content: "[s:29]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/09.gif",
        ),
        Expression(
          content: "[s:30]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/10.gif",
        ),
        Expression(
          content: "[s:32]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/12.gif",
        ),
        Expression(
          content: "[s:33]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/13.gif",
        ),
        Expression(
          content: "[s:34]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/14.gif",
        ),
        Expression(
          content: "[s:35]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/15.gif",
        ),
        Expression(
          content: "[s:36]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/16.gif",
        ),
        Expression(
          content: "[s:37]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/17.gif",
        ),
        Expression(
          content: "[s:38]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/18.gif",
        ),
        Expression(
          content: "[s:39]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/19.gif",
        ),
        Expression(
          content: "[s:40]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/20.gif",
        ),
        Expression(
          content: "[s:41]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/21.gif",
        ),
        Expression(
          content: "[s:42]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/22.gif",
        ),
        Expression(
          content: "[s:43]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/23.gif",
        ),
      ];
      var group = ExpressionGroup("默认", expressionList);
      expressionGroupList.add(group);

      expressionList = [
        Expression(
          content: "[s:1]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/smile.gif",
        ),
        Expression(
          content: "[s:2]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/mrgreen.gif",
        ),
        Expression(
          content: "[s:3]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/question.gif",
        ),
        Expression(
          content: "[s:4]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/wink.gif",
        ),
      ];
      group = ExpressionGroup("AC娘", expressionList);
      expressionGroupList.add(group);

      expressionList = [
        Expression(
          content: "[s:1]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/smile.gif",
        ),
        Expression(
          content: "[s:2]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/mrgreen.gif",
        ),
        Expression(
          content: "[s:3]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/question.gif",
        ),
        Expression(
          content: "[s:4]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/wink.gif",
        ),
      ];
      group = ExpressionGroup("新AC娘", expressionList);
      expressionGroupList.add(group);

      expressionList = [
        Expression(
          content: "[s:1]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/smile.gif",
        ),
        Expression(
          content: "[s:2]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/mrgreen.gif",
        ),
        Expression(
          content: "[s:3]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/question.gif",
        ),
        Expression(
          content: "[s:4]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/wink.gif",
        ),
      ];
      group = ExpressionGroup("潘斯特", expressionList);
      expressionGroupList.add(group);

      expressionList = [
        Expression(
          content: "[s:1]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/smile.gif",
        ),
        Expression(
          content: "[s:2]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/mrgreen.gif",
        ),
        Expression(
          content: "[s:3]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/question.gif",
        ),
        Expression(
          content: "[s:4]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/wink.gif",
        ),
      ];
      group = ExpressionGroup("外域三人组", expressionList);
      expressionGroupList.add(group);

      expressionList = [
        Expression(
          content: "[s:1]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/smile.gif",
        ),
        Expression(
          content: "[s:2]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/mrgreen.gif",
        ),
        Expression(
          content: "[s:3]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/question.gif",
        ),
        Expression(
          content: "[s:4]",
          url: "https://img4.nga.178.com/ngabbs/post/smile/wink.gif",
        ),
      ];
      group = ExpressionGroup("企鹅", expressionList);
      expressionGroupList.add(group);
    }

    return expressionGroupList;
  }
}
