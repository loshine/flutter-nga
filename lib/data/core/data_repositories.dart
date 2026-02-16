import 'package:dio/dio.dart';
import 'package:sembast/sembast.dart';

import 'package:flutter_nga/data/repository/expression_repository.dart';
import 'package:flutter_nga/data/repository/forum_repository.dart';
import 'package:flutter_nga/data/repository/message_repository.dart';
import 'package:flutter_nga/data/repository/resource_repository.dart';
import 'package:flutter_nga/data/repository/topic_repository.dart';
import 'package:flutter_nga/data/repository/user_repository.dart';

class DataRepositories {
  DataRepositories({
    required Database database,
    required Dio dio,
  })  : emoticonRepository = EmoticonDataRepository(),
        forumRepository = ForumDataRepository(database, dio),
        messageRepository = MessageDataRepository(dio),
        resourceRepository = ResourceDataRepository(),
        topicRepository = TopicDataRepository(database, dio),
        userRepository = UserDataRepository(database, dio);

  final EmoticonRepository emoticonRepository;
  final ForumRepository forumRepository;
  final MessageRepository messageRepository;
  final ResourceRepository resourceRepository;
  final TopicRepository topicRepository;
  final UserRepository userRepository;
}
