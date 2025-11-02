import '../../models/user.dart';

abstract class AuthRepository {
  Future<User?> getCurrentUser();
  Stream<User?> watchCurrentUser();
  Future<void> setCurrentUser(String userId);
}
