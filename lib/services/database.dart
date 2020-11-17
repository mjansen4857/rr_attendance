import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Database {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference timeRequests =
      FirebaseFirestore.instance.collection('timeRequests');
  final CollectionReference settings =
      FirebaseFirestore.instance.collection('settings');

  Future<bool> addUserIfNotExists(User user, int teamNumber) async {
    DocumentReference userDoc = users.doc(user.uid);
    DocumentSnapshot userSnap = await userDoc.get();
    if (!userSnap.exists) {
      userDoc.set({
        'name': user.displayName,
        'team': teamNumber,
        'in_timestamp': null,
        'total_hours': 0,
        'is_admin': false
      });
      return true;
    }
    return false;
  }

  Future<bool> validatePermission(String permissionCode) async {
    DocumentSnapshot settingsDoc = await settings.doc('settings').get();
    return settingsDoc.data()['permission_code'] == permissionCode;
  }

  Future<int> getTeamNumber(User user) async {
    DocumentSnapshot userDocSnapshot = await users.doc(user.uid).get();
    return userDocSnapshot.data()['team'];
  }

  Future<bool> isUserAdmin(User user) async {
    DocumentSnapshot userDocSnapshot = await users.doc(user.uid).get();
    return userDocSnapshot.data()['is_admin'];
  }

  Future<void> clockInUser(User user) async {
    DocumentReference userDoc = users.doc(user.uid);
    await addHoursToUserDay(user, 0, Timestamp.now());
    return userDoc.update({'in_timestamp': Timestamp.now()});
  }

  Future<double> clockOutUser(User user) async {
    Timestamp inTime = await getInTimestamp(user);
    if (inTime != null) {
      int dSeconds = Timestamp.now().seconds - inTime.seconds;
      DocumentReference userDoc = users.doc(user.uid);
      double hours = dSeconds / 60.0 / 60.0;
      await userDoc.update({
        'in_timestamp': null,
      });
      await addHoursToUserDay(user, hours, inTime);
      return hours;
    }
    return 0;
  }

  Future<Timestamp> getInTimestamp(User user) async {
    DocumentReference userDoc = users.doc(user.uid);
    DocumentSnapshot userDocSnapshot = await userDoc.get();
    Timestamp inTime = userDocSnapshot.data()['in_timestamp'];
    return inTime;
  }

  Future<void> addHoursToUserDay(
      User user, double hours, Timestamp inTime) async {
    DocumentReference userDoc = users.doc(user.uid);
    CollectionReference timecardCollection = userDoc.collection('timecard');
    DateTime inDate = inTime.toDate();
    DocumentReference inDateDoc =
        timecardCollection.doc('${inDate.year}-${inDate.month}-${inDate.day}');
    DocumentSnapshot inDateDocSnapshot = await inDateDoc.get();
    double prevHours = 0;
    if (inDateDocSnapshot.exists) {
      prevHours = inDateDocSnapshot.data()['hours'];
      return inDateDoc.update({'hours': prevHours + hours});
    }
    return inDateDoc.set({'hours': hours});
  }

  Future<QuerySnapshot> getTimecardDocs(User user) async {
    DocumentReference userDoc = users.doc(user.uid);
    CollectionReference timecardCollection = userDoc.collection('timecard');
    return timecardCollection.get();
  }

  Future<QuerySnapshot> getTimeRequests() async {
    return timeRequests.get();
  }

  Future<void> addTimeRequest(
      User user, DateTime changeDate, double newHours) async {
    await timeRequests.add({
      'user': user.uid,
      'name': user.displayName,
      'changeDate': changeDate,
      'newHours': newHours,
    });
  }

  Future<void> deleteTimeRequest(
      String uid, DateTime date, String hours) async {
    QuerySnapshot querySnapshot = await timeRequests
        .where('user', isEqualTo: uid)
        .where('changeDate', isEqualTo: Timestamp.fromDate(date))
        .where('newHours', isEqualTo: double.parse(hours))
        .get();
    await timeRequests.doc(querySnapshot.docs[0].id).delete();
  }

  Future<void> approveTimeRequest(
      String uid, DateTime date, String hours) async {
    DocumentReference userDoc = users.doc(uid);
    CollectionReference timecardCollection = userDoc.collection('timecard');
    DocumentReference dateDoc =
        timecardCollection.doc('${date.year}-${date.month}-${date.day}');
    dateDoc.update({'hours': double.parse(hours)});
    await deleteTimeRequest(uid, date, hours);
  }

  Future<double> getTotalHours(User user) async {
    DocumentReference userDoc = users.doc(user.uid);
    DocumentSnapshot userDocSnapshot = await userDoc.get();
    return userDocSnapshot.data()['total_hours'].toDouble();
  }

  Future<QuerySnapshot> getAllUserDocsFromTeam(int team) async {
    QuerySnapshot querySnapshot = await users
        .where('team', isEqualTo: team)
        .where('total_hours', isGreaterThanOrEqualTo: 0.1)
        .orderBy('total_hours', descending: true)
        .get();
    return querySnapshot;
  }
}
