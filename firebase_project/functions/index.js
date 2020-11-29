const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

const db = admin.firestore();

exports.resetHours = functions.https.onCall(async (data, context) => {
    var users = db.collection('users');
    return users.get().then((snap) => {
        snap.forEach((userDoc) => {
            if (userDoc.exists) {
                var batch = db.batch();
                batch.update(userDoc.ref, 'total_hours', 0.0);
                userDoc.ref.collection('timecard').get().then((snap) => {
                    snap.forEach((doc) => {
                        if (doc.exists) batch.delete(doc.ref);
                    });
                    batch.commit();
                });
            }
        });
    });
});

exports.clockOutAll = functions.pubsub.schedule('0 0 * * *')
    .timeZone('America/New_York')
    .onRun((context) => {
        // This will run every day at midnight eastern
        var users = db.collection('users');
        var query = users.where('in_timestamp', '!=', null);
        return query.get().then((snap) => {
            var batch = db.batch();
            snap.forEach((doc) => {
                var name = doc.get('name');
                console.log('Forcibly clocking out ' + name);
                batch.update(doc.ref, 'in_timestamp', null);
            });
            batch.commit();
        });
    });

exports.updateTotalOnDelete = functions.firestore
    .document('users/{userId}/timecard/{docId}')
    .onDelete((snap, context) => {
        const user = context.params.userId;
        const delHours = snap.data().hours;

        const userDoc = db.doc('users/' + user);
        return userDoc.get().then(snap => {
            const prevTotal = snap.data().total_hours;
            if (prevTotal > delHours) {
                userDoc.update({ total_hours: prevTotal - delHours });
            } else {
                userDoc.update({ total_hours: 0.0 });
            }
        });
    });

exports.updateTotalOnCreate = functions.firestore
    .document('users/{userId}/timecard/{docId}')
    .onCreate((snap, context) => {
        const user = context.params.userId;
        const newHours = snap.data().hours;

        const userDoc = db.doc('users/' + user);
        return userDoc.get().then(snap => {
            const prevTotal = snap.data().total_hours;
            userDoc.update({ total_hours: prevTotal + newHours });
        });
    });
