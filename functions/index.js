const functions = require("firebase-functions");
const admin = require('firebase-admin');
admin.initializeApp();
var apn = require("apn");

 // Create and Deploy Your First Cloud Functions
// https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
// admin.firestore().collection("users").doc(data.userId).delete();
// admin.firestore().collection("usersStatus").doc(data.userId).delete();

exports.deleteProfile =
    functions.https.onCall((data, context) => {

        admin.auth().deleteUser(data.uid).then(() => {

            console.log("user deleted successfully");
        }).catch(error => {
            console.log("error deleting in user");
        })
    });

exports.sendNotification =
    functions.https.onCall((data, context) => {
        console.log("--------------------functions---------------------------");


        let provider = new apn.Provider(
            {
                token: {
                    key: "AuthKey_D9627K52MN.p8",
                    keyId: "D9627K52MN",
                    teamId: "784P73UHN5",
                    cert: "VOIP.pem"
                },
                production: false
            });

        let notification = new apn.Notification();
        console.log("--------------------functions notification---------------------------");
        notification.payload = {
            "id": data['id'],
            "callerId": data.callerId,
            "handle": "Incoming call",
            "callerName": data.callerName,
            "isVideo": data.isVideo,
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
            "aps": {
                 "alert": {
                    "id": data['id'],
                    "callerId":  data['callerId'],
                    "handle": "Incoming call",
                    "callerName": data.callerName,
                    "isVideo": data.isVideo,
                    "click_action": "FLUTTER_NOTIFICATION_CLICK",
                },
                'content-available': 1,
 }
        };
        notification.pushType = "voip";
        notification.topic = "com.names.io.voip";
        notification.expiry = 0;
        notification.priority = 5;
        console.log("--------------------functions 5---------------------------");
  provider.send(notification, data.token).then((err, result) => {
            if (err) return console.log(JSON.stringify(err));
            return console.log(JSON.stringify(result))
        });
    });