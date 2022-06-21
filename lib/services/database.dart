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

  static Future<bool> isUserAdmin(User user) async {
    DocumentSnapshot userDocSnapshot = await _users.doc(user.uid).get();
    return (userDocSnapshot.data() as Map<String, dynamic>)['is_admin'];
  }

  static Future<Settings> getSettings() async {
    DocumentSnapshot settingsDoc = await _settings.doc('settings').get();
    return Settings.fromJson(settingsDoc.data() as Map<String, dynamic>);
  }

  static Future<int> getNumUsers() async {
    QuerySnapshot userQuery = await _users.get();
    return userQuery.docs.length;
  }

  static Future<int> getNumClockedIn() async {
    QuerySnapshot userQuery = await _users.get();
    int total = 0;
    for (var docSnap in userQuery.docs) {
      if (docSnap.get('in_timestamp') != null) {
        total++;
      }
    }
    return total;
  }

  static Future<List<TimeRequest>> getTimeRequests() async {
    List<TimeRequest> requests = [];
    QuerySnapshot requestsSnap = await _timeRequests.get();

    for (QueryDocumentSnapshot requestDoc in requestsSnap.docs) {
      Map<String, dynamic> requestJson =
          requestDoc.data() as Map<String, dynamic>;

      if (!requestJson.containsKey('prevHours')) {
        num prevHours = await getHoursFromDate(
            requestJson['user'], requestJson['changeDate'].toDate());
        requestJson.putIfAbsent('prevHours', () => prevHours);
      }

      requests.add(TimeRequest.fromJson(requestJson));
    }

    return requests;
  }

  static Future<void> deleteTimeRequest(TimeRequest request) async {
    QuerySnapshot querySnapshot = await _timeRequests
        .where('user', isEqualTo: request.uid)
        .where('changeDate', isEqualTo: Timestamp.fromDate(request.requestDate))
        .where('newHours', isEqualTo: request.newHours)
        .get();
    await _timeRequests.doc(querySnapshot.docs[0].id).delete();
  }

  static Future<void> approveTimeRequest(TimeRequest request) async {
    DocumentReference userDoc = _users.doc(request.uid);
    CollectionReference timecardCollection = userDoc.collection('timecard');
    DocumentReference dateDoc = timecardCollection.doc(
        '${request.requestDate.year}-${request.requestDate.month}-${request.requestDate.day}');
    dateDoc.update({'hours': request.newHours});
    await deleteTimeRequest(request);
  }

  static Future<num> getHoursFromDate(String uid, DateTime date) async {
    DocumentReference userDoc = _users.doc(uid);
    CollectionReference timecardCollection = userDoc.collection('timecard');
    DocumentReference inDateDoc =
        timecardCollection.doc('${date.year}-${date.month}-${date.day}');
    DocumentSnapshot inDateDocSnapshot = await inDateDoc.get();
    num prevHours = 0;
    if (inDateDocSnapshot.exists) {
      prevHours = (inDateDocSnapshot.data() as Map<String, dynamic>)['hours'];
    }
    return prevHours;
  }
}

class Settings {
  final String permissionCode;
  final bool leaderboardEnabled;

  Settings.fromJson(Map<String, dynamic> json)
      : this.permissionCode = json['permission_code'],
        this.leaderboardEnabled = json['show_leaderboard'];
}

class TimeRequest {
  final String uid;
  final String userName;
  final DateTime requestDate;
  final num prevHours;
  final num newHours;

  TimeRequest.fromJson(Map<String, dynamic> json)
      : this.uid = json['user'],
        this.userName = json['name'],
        this.requestDate = json['changeDate'].toDate(),
        this.prevHours = json['prevHours'],
        this.newHours = json['newHours'];

  Map<String, dynamic> toJson() {
    return {
      'user': this.uid,
      'name': this.userName,
      'changeDate': this.requestDate,
      'prevHours': this.prevHours,
      'newHours': this.newHours,
    };
  }
}
