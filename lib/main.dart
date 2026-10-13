import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'core/firebase/firebase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 没配好时返回 false，鉴权会退回本地演示实现。
  final bool firebaseReady = await FirebaseBootstrap.initialize();
  configureDependencies(firebaseReady: firebaseReady);

  runApp(const CryptoApp());
}
