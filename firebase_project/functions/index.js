const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

const db = admin.firestore();

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

exports.updateTotalOnUpdate = functions.firestore
    .document('users/{userId}/timecard/{docId}')
    .onUpdate((change, context) => {
        const user = context.params.userId;
        const newValue = change.after.data().hours;
        const prevValue = change.before.data().hours;

        const delta = newValue - prevValue;

        const userDoc = db.doc('users/' + user);
        return userDoc.get().then(snap => {
            const prevTotal = snap.data().total_hours;
            userDoc.update({ total_hours: prevTotal + delta });
        });
    });

exports.updateTotalOnDelete = functions.firestore
    .document('users/{userId}/timecard/{docId}')
    .onDelete((snap, context) => {
        const user = context.params.userId;
        const prevHours = snap.data().hours;

        const userDoc = db.doc('users/' + user);
        return userDoc.get().then(snap => {
            const prevTotal = snap.data().total_hours;
            if (prevTotal > prevHours) {
                userDoc.update({ total_hours: prevTotal - prevHours });
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
