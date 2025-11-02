import 'dart:async';

import 'package:hive/hive.dart';

import '../../../core/data/hive/hive_boxes.dart';
import '../../../core/data/hive/hive_manager.dart';
import '../../../core/domain/repositories/auth_repository.dart';
import '../../../core/models/user.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl() : _manager = HiveManager.instance;

  final HiveManager _manager;

  @override
  Future<User?> getCurrentUser() async {
    final metaBox = Hive.box(HiveBoxes.meta);
    final currentId = metaBox.get('current_user_id') as String?;
    if (currentId == null) {
      return null;
    }
    return _manager.box<User>(HiveBoxes.users).get(currentId);
  }

  @override
  Future<void> setCurrentUser(String userId) async {
    final metaBox = Hive.box(HiveBoxes.meta);
    await metaBox.put('current_user_id', userId);
  }

  @override
  Stream<User?> watchCurrentUser() async* {
    final metaBox = Hive.box(HiveBoxes.meta);
    final controller = StreamController<User?>();

    void emit() {
      final id = metaBox.get('current_user_id') as String?;
      controller.add(id == null
          ? null
          : _manager.box<User>(HiveBoxes.users).get(id));
    }

    emit();
    final subscription = metaBox.watch(key: 'current_user_id').listen((_) => emit());
    controller.onCancel = () {
      subscription.cancel();
    };
    yield* controller.stream;
  }
}
