import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Database {
  final Firestore firestore = Firestore.instance;
  final CollectionReference users = Firestore.instance.collection('users');
  final CollectionReference timeRequests =
      Firestore.instance.collection('timeRequests');

  Future<void> addUser(FirebaseUser user, int teamNumber) async {
    DocumentReference userDoc = users.document(user.uid);
    return userDoc.setData({
      'name': user.displayName,
      'team': teamNumber,
      'in_timestamp': null,
      'total_hours': 0,
      'is_admin': false
    });
  }

  Future<int> getTeamNumber(FirebaseUser user) async {
    DocumentSnapshot userDocSnapshot = await users.document(user.uid).get();
    return userDocSnapshot.data['team'];
  }

  Future<bool> isUserAdmin(FirebaseUser user) async {
    DocumentSnapshot userDocSnapshot = await users.document(user.uid).get();
    return userDocSnapshot.data['is_admin'];
  }

  Future<void> clockInUser(FirebaseUser user) async {
    DocumentReference userDoc = users.document(user.uid);
    await addHoursToUserDay(user, 0, Timestamp.now());
    return userDoc.setData({'in_timestamp': Timestamp.now()}, merge: true);
  }

  Future<double> clockOutUser(FirebaseUser user) async {
    Timestamp inTime = await getInTimestamp(user);
    if (inTime != null) {
      int dSeconds = Timestamp.now().seconds - inTime.seconds;
      DocumentReference userDoc = users.document(user.uid);
      double hours = dSeconds / 60.0 / 60.0;
      await userDoc.setData({
        'in_timestamp': null,
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

  Future<QuerySnapshot> getTimecardDocs(FirebaseUser user) async {
    DocumentReference userDoc = users.document(user.uid);
    CollectionReference timecardCollection = userDoc.collection('timecard');
    return timecardCollection.getDocuments();
  }

  Future<QuerySnapshot> getTimeRequests() async {
    return timeRequests.getDocuments();
  }

  Future<void> addTimeRequest(
      FirebaseUser user, String changeDate, double newHours) async {
    await timeRequests.add({
      'user': user.uid,
      'name': user.displayName,
      'changeDate': changeDate,
      'newHours': newHours,
    });
  }

  Future<double> getTotalHours(FirebaseUser user) async {
    DocumentReference userDoc = users.document(user.uid);
    DocumentSnapshot userDocSnapshot = await userDoc.get();
    return userDocSnapshot.data['total_hours'].toDouble();
  }

  Future<QuerySnapshot> getAllUserDocsFromTeam(int team) async {
    QuerySnapshot querySnapshot =
        await users.where('team', isEqualTo: team).getDocuments();
    return querySnapshot;
  }
}
