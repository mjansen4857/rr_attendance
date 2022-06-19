import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Database {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _users = _firestore.collection('users');
  static final CollectionReference _timeRequests =
      _firestore.collection('timeRequests');
  static final CollectionReference _settings =
      _firestore.collection('settings');

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

  static Future<Settings> getSettings() async {
    DocumentSnapshot settingsDoc = await _settings.doc('settings').get();
    return Settings.fromJson(settingsDoc.data() as Map<String, dynamic>);
  }
}

class Settings {
  final String permissionCode;
  final bool leaderboardEnabled;

  Settings.fromJson(Map<String, dynamic> json)
      : this.permissionCode = json['permission_code'],
        this.leaderboardEnabled = json['show_leaderboard'];
}
