import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_nga/data/data.dart';

void backgroundSyncBlockInfoTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    // This task has exceeded its allowed running-time.
    // You must stop what you're doing and immediately .finish(taskId)
    print("[BackgroundFetch] Headless task timed-out: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }
  print('[BackgroundFetch] Headless event received.');
  // Do your work here...
  try {
    final blockInfo = await Data().userRepository.getBlockInfo();
  } catch (err) {
    debugPrint(err.toString());
  }
  BackgroundFetch.finish(taskId);
}
