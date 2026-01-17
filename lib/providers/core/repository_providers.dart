import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/repository/forum_repository.dart';
import 'package:flutter_nga/data/repository/message_repository.dart';
import 'package:flutter_nga/data/repository/topic_repository.dart';
import 'package:flutter_nga/data/repository/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final forumRepositoryProvider = Provider<ForumRepository>((ref) {
  return Data().forumRepository;
});

final topicRepositoryProvider = Provider<TopicRepository>((ref) {
  return Data().topicRepository;
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return Data().userRepository;
});

final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return Data().messageRepository;
});
