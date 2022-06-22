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

  static Future<UserInfo> getUserInfo(User user) async {
    DocumentSnapshot userDocSnapshot = await _users.doc(user.uid).get();
    return UserInfo.fromJson(userDocSnapshot.data() as Map<String, dynamic>);
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

  static Future<void> updateUserName(User user, String name) async {
    await user.updateDisplayName(name);

    DocumentReference userDoc = _users.doc(user.uid);
    return userDoc.update({'name': name});
  }

  static Future<void> updateUserTeam(User user, int teamNumber) async {
    DocumentReference userDoc = _users.doc(user.uid);
    return userDoc.update({'team': teamNumber});
  }

  static Future<void> addHoursToUserDay(
      User user, num hours, DateTime inTime) async {
    DocumentReference userDoc = _users.doc(user.uid);
    CollectionReference timecardCollection = userDoc.collection('timecard');
    DocumentReference inDateDoc =
        timecardCollection.doc('${inTime.year}-${inTime.month}-${inTime.day}');
    DocumentSnapshot inDateDocSnapshot = await inDateDoc.get();
    double prevHours = 0;
    if (inDateDocSnapshot.exists) {
      prevHours = (inDateDocSnapshot.data() as Map<String, dynamic>)['hours'];
      return inDateDoc.update({'hours': prevHours + hours});
    }
    return inDateDoc.set({'hours': hours});
  }

  static Future<void> clockInUser(User user) async {
    DocumentReference userDoc = _users.doc(user.uid);
    await addHoursToUserDay(user, 0, DateTime.now());
    return userDoc.update({'in_timestamp': Timestamp.now()});
  }

  static Future<void> clockOutUser(User user) async {
    Timestamp? inTime = (await getUserInfo(user)).inTime;
    if (inTime != null) {
      int dSeconds = Timestamp.now().seconds - inTime.seconds;
      DocumentReference userDoc = _users.doc(user.uid);
      double hours = dSeconds / 60.0 / 60.0;
      await userDoc.update({
        'in_timestamp': null,
      });
      await addHoursToUserDay(user, hours, inTime.toDate());
    }
  }

  static Future<List<TimeCard>> getTimecards(User user) async {
    DocumentReference userDoc = _users.doc(user.uid);
    CollectionReference timecardCollection = userDoc.collection('timecard');
    QuerySnapshot timecardDocs = await timecardCollection.get();

    List<TimeCard> timeCards = [];
    for (QueryDocumentSnapshot doc in timecardDocs.docs) {
      timeCards
          .add(TimeCard(doc.id, (doc.data() as Map<String, dynamic>)['hours']));
    }

    return timeCards;
  }
}

class Settings {
  final String permissionCode;
  final bool leaderboardEnabled;
  final bool statsEnabled;
  final String resetPassword;

  Settings.fromJson(Map<String, dynamic> json)
      : this.permissionCode = json['permission_code'],
        this.leaderboardEnabled = json['show_leaderboard'],
        this.statsEnabled = json['show_stats'],
        this.resetPassword = json['reset_password'];
}

class UserInfo {
  final Timestamp? inTime;
  final bool isAdmin;
  final String name;
  final int team;
  final num totalHours;

  UserInfo.fromJson(Map<String, dynamic> json)
      : this.inTime = json['in_timestamp'],
        this.isAdmin = json['is_admin'],
        this.name = json['name'],
        this.team = json['team'],
        this.totalHours = json['total_hours'];
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

class TimeCard {
  final String docId;
  final num hours;

  const TimeCard(this.docId, this.hours);
}
