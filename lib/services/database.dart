import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Database {
  final Firestore firestore = Firestore.instance;
  final CollectionReference users = Firestore.instance.collection('users');

  Future<void> addUser(FirebaseUser user, int teamNumber) async {
    DocumentReference userDoc = users.document(user.uid);
    return userDoc.setData({
      'name': user.displayName,
      'team': teamNumber,
      'in_timestamp': null,
      'total_hours': 0
    });
  }

  Future<int> getTeamNumber(FirebaseUser user) async {
    DocumentSnapshot userDocSnapshot = await users.document(user.uid).get();
    return userDocSnapshot.data['team'];
  }

  Future<void> clockInUser(FirebaseUser user) async {
    DocumentReference userDoc = users.document(user.uid);
    return userDoc.setData({'in_timestamp': Timestamp.now()}, merge: true);
  }

  Future<double> clockOutUser(FirebaseUser user) async {
    Timestamp inTime = await getInTimestamp(user);
    if (inTime != null) {
      int dSeconds = Timestamp.now().seconds - inTime.seconds;
      DocumentReference userDoc = users.document(user.uid);
      DocumentSnapshot userDocSnapshot = await userDoc.get();
      double hours = dSeconds / 60.0 / 60.0;
      await userDoc.setData({
        'in_timestamp': null,
        'total_hours': userDocSnapshot.data['total_hours'] + hours
      }, merge: true);
      await addHoursToUserDay(user, hours, inTime);
      return hours;
    }
    return 0;
  }

  Future<Timestamp> getInTimestamp(FirebaseUser user) async {
    DocumentReference userDoc = users.document(user.uid);
    DocumentSnapshot userDocSnapshot = await userDoc.get();
    Timestamp inTime = userDocSnapshot.data['in_timestamp'];
    return inTime;
  }

  Future<void> addHoursToUserDay(
      FirebaseUser user, double hours, Timestamp inTime) async {
    DocumentReference userDoc = users.document(user.uid);
    CollectionReference timecardCollection = userDoc.collection('timecard');
    DateTime inDate = inTime.toDate();
    DocumentReference inDateDoc = timecardCollection
        .document('${inDate.year}-${inDate.month}-${inDate.day}');
    DocumentSnapshot inDateDocSnapshot = await inDateDoc.get();
    double prevHours = 0;
    if (inDateDocSnapshot.exists) {
      prevHours = inDateDocSnapshot.data['hours'];
    }
    return inDateDoc.setData({'hours': prevHours + hours}, merge: true);
  }
}
