const functions = require("firebase-functions");
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendNotification = functions.firestore.document('message/{groupId1}/{groupId2}/{message}').onCreate(
    (snap, context) => {
        console.log('----------------------->Function Started<-----------------------');
        const doc = snap.data()
        console.log(data)
    }
);