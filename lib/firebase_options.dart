// Firebase 配置入口（模板实现）。
//
// 没有提供配置时返回 null，App 会自动退回本地演示鉴权。两种接入方式：
//   1. 执行 `flutterfire configure`：会用真实参数覆盖本文件；
//   2. 启动时传参：--dart-define=FIREBASE_API_KEY=... 等（见 README）。

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

abstract final class DefaultFirebaseOptions {
  static FirebaseOptions? get currentPlatform {
    const String apiKey = String.fromEnvironment('FIREBASE_API_KEY');
    const String appId = String.fromEnvironment('FIREBASE_APP_ID');
    const String projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
    const String senderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
    const String authDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
    const String storageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');

    if (apiKey.isEmpty || appId.isEmpty || projectId.isEmpty) {
      return null;
    }

    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: senderId,
      projectId: projectId,
      authDomain: authDomain.isEmpty ? '$projectId.firebaseapp.com' : authDomain,
      storageBucket:
          storageBucket.isEmpty ? '$projectId.appspot.com' : storageBucket,
    );
  }
}
