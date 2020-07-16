import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Database {
  final Firestore firestore = Firestore.instance;

  Future<void> addUser(FirebaseUser user, int teamNumber) async {
    CollectionReference users = firestore.collection('users');
    DocumentReference userDoc = users.document(user.uid);
    return await userDoc.setData({
      'name': user.displayName,
      'team': teamNumber,
      'in_timestamp': null,
      'total_hours': 0
    });
  }

  Future<int> getTeamNumber(FirebaseUser user) async {
    CollectionReference users = firestore.collection('users');
    DocumentSnapshot userDocSnapshot = await users.document(user.uid).get();
    return userDocSnapshot.data['team'];
  }

  Future<void> clockInUser(FirebaseUser user) async {
    CollectionReference users = firestore.collection('users');
    DocumentReference userDoc = users.document(user.uid);
    return await userDoc.setData({'in_timestamp': Timestamp.now()});
  }

  Future<void> clockOutUser(FirebaseUser user) async {
    CollectionReference users = firestore.collection('users');
    DocumentSnapshot userDocSnapshot = await users.document(user.uid).get();
    //TODO
  }
}
