import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCWo4I8nfVqX4jUgxuN4vjtiFlbUwtcWCo",
    authDomain: "find-your-doctor-3afaf.firebaseapp.com",
    projectId: "find-your-doctor-3afaf",
    storageBucket: "find-your-doctor-3afaf.firebasestorage.app",
    messagingSenderId: "984896098065",
    appId: "1:984896098065:web:84c88ac1684064752446b0",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyDJISIOG1YnzGg1TJKVwQJbeujkbXpIT0Q",
    appId: "1:984896098065:android:abcdef1234567890",
    messagingSenderId: "984896098065",
    projectId: "find-your-doctor-3afaf",
    storageBucket: "find-your-doctor-3afaf.firebasestorage.app",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyDJISIOG1YnzGg1TJKVwQJbeujkbXpIT0Q",
    appId: "1:984896098065:ios:abcdef1234567890",
    messagingSenderId: "984896098065",
    projectId: "find-your-doctor-3afaf",
    storageBucket: "find-your-doctor-3afaf.firebasestorage.app",
    iosBundleId: "com.example.findYourDoctor",
  );
}