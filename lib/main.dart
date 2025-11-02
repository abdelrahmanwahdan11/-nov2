import 'package:flutter/material.dart';
import 'src/app.dart';
import 'src/core/state/app_state.dart';
import 'src/core/state/app_scope.dart';
import 'src/core/storage/local_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = await LocalStore.create();
  final state = AppState(store: store);
  await state.bootstrap();
  runApp(AppScope(state: state, child: const SahaApp()));
}
