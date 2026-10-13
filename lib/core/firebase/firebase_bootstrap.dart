import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

/// 初始化 Firebase；没有配置就返回 false，App 会退回本地演示鉴权。
abstract final class FirebaseBootstrap {
  static bool _ready = false;

  static bool get isReady => _ready;

  static Future<bool> initialize() async {
    try {
      final FirebaseOptions? options = DefaultFirebaseOptions.currentPlatform;
      if (options == null) {
        debugPrint('未检测到 Firebase 配置，使用本地演示鉴权');
        _ready = false;
        return false;
      }
      await Firebase.initializeApp(options: options);
      _ready = true;
    } catch (error) {
      debugPrint('Firebase 初始化失败，使用本地演示鉴权：$error');
      _ready = false;
    }
    return _ready;
  }
}
