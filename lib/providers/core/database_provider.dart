import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

final databaseProvider = FutureProvider<Database>((ref) async {
  Directory appDocDir = await getApplicationDocumentsDirectory();
  DatabaseFactory dbFactory = databaseFactoryIo;
  String forumDbPath = [appDocDir.path, 'main.db'].join('/');
  return await dbFactory.openDatabase(forumDbPath);
});
