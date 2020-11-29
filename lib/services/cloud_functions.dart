import 'package:cloud_functions/cloud_functions.dart';

class CloudFunctions {
  static Future<void> resetHours() async {
    HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('resetHours');
    return callable();
  }
}
