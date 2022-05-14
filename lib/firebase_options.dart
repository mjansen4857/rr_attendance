// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBYLpFbmLH5O6b8UMjsXzs3VI9mR_izdhE',
    appId: '1:853905520563:android:261bca9babd5b6dba6fdc6',
    messagingSenderId: '853905520563',
    projectId: 'rr-attendance-4fe28',
    databaseURL: 'https://rr-attendance-4fe28.firebaseio.com',
    storageBucket: 'rr-attendance-4fe28.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAiXHow-7C6-hxyz5CSmsFHMqxJ8q6vEzM',
    appId: '1:853905520563:ios:0c8146122d6ce0a3a6fdc6',
    messagingSenderId: '853905520563',
    projectId: 'rr-attendance-4fe28',
    databaseURL: 'https://rr-attendance-4fe28.firebaseio.com',
    storageBucket: 'rr-attendance-4fe28.appspot.com',
    androidClientId: '853905520563-9th1gppm7laba6bdcjl89lbsgq4dhpts.apps.googleusercontent.com',
    iosClientId: '853905520563-n8am7kouuhuecab6stim4c9t909am69c.apps.googleusercontent.com',
    iosBundleId: 'com.example.rrAttendance',
  );
}
