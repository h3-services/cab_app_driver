import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.windows:
        throw UnsupportedError('Firebase not supported on Windows');
      default:
        throw UnsupportedError('Firebase not configured for this platform');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: '1:YOUR_APP_ID:web:YOUR_WEB_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'your-project-id',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA-v_-srdK2n6H0_62z_8wXfRaUXf5FQ6s',
    appId: '1:933171482600:android:e52cc3cbc51ddc4e379e5d',
    messagingSenderId: '933171482600',
    projectId: 'cabbooking-e2da4',
    storageBucket: 'cabbooking-e2da4.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: '1:YOUR_APP_ID:ios:YOUR_IOS_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'your-project-id',
    iosBundleId: 'com.example.cabbokking',
  );
}
