import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Database {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _users =
      FirebaseFirestore.instance.collection('users');
  static final CollectionReference _timeRequests =
      FirebaseFirestore.instance.collection('timeRequests');
  static final CollectionReference _settings =
      FirebaseFirestore.instance.collection('settings');

  static Future<bool> addUserIfNotExists(User user, int teamNumber) async {
    DocumentReference userDoc = _users.doc(user.uid);
    DocumentSnapshot userSnap = await userDoc.get();

    if (!userSnap.exists) {
      userDoc.set({
        'name': user.displayName,
        'team': teamNumber,
        'in_timestamp': null,
        'total_hours': 0,
        'is_admin': false,
      });
      return true;
    }
    return false;
  }

  static Future<bool> validatePermission(String permissionCode) async {
    DocumentSnapshot settingsDoc = await _settings.doc('settings').get();
    return (settingsDoc.data() as Map<String, Object?>)['permission_code'] ==
        permissionCode;
  }
}
