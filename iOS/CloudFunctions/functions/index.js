const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.webhookNew = functions.https.onCall((data, context) => {
  const topic = data.docId;
  const title = data.title;
  const payloadMsg = data.message;

  const message = {
    notification: {
      title: title,
      body: payloadMsg,
    },
    topic: topic,
    apns: {
      payload: {
        aps: {
          badge: "1",
        },
      },
    },
  };

  // Send a message to devices subscribed to the provided topic.
  admin.messaging().send(message)
      .then((response) => {
        // Response is a message ID string.
        console.log("Successfully sent message:", response);
      })
      .catch((error) => {
        console.log("Error sending message:", error);
      });
});
