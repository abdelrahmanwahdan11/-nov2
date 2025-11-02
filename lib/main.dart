import 'package:flutter/material.dart';

import 'app.dart';
import 'application/services/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ServiceLocator.instance.init();
  runApp(const SahaApp());
}
