import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_nga/data/usecase/use_case.dart';

import '../../entity/topic.dart';
import '../../http.dart';

class GetTopicListUseCase extends UseCase<TopicListData, GetTopicListParams> {
  @override
  Future<TopicListData> execute(GetTopicListParams? params) async {
    var query = "__output=8";
    if (params?.fid != null) {
      query +=
          params?.type == 1 ? "&stid=${params?.fid}" : "&fid=${params?.fid}";
    }
    if (params?.authorid != null) {
      query += "&authorid=${params?.authorid}";
    }
    if (params?.page != null) {
      query += "&page=${params?.page}";
    }
    if (params?.recommend == true) {
      query += "&recommend=1&order_by=postdatedesc";
    }
    Response<String> response = await httpClient.get("thread.php?$query");
    return TopicListData.fromJson(
        json.decode(response.data ?? "{}")['data'], params?.page);
  }
}

class GetTopicListParams {
  final int? fid;
  final int? authorid;
  final int? page;
  final bool recommend;
  final int? type;

  GetTopicListParams(
      {this.fid,
      this.authorid,
      this.page,
      this.recommend = false,
      this.type = 0});
}
