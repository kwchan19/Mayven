const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.chatNotifications = functions.https.onCall((data, context) => {
  const title = data.title;
  const payloadMsg = data.message;
  const memberList = data.membersList;

  functions.logger.log("Member List:", memberList);
  for (let i = 0; i < memberList.count; i++) {
    const memberName = memberList[i];
    const message = {
      notification: {
        title: title,
        body: payloadMsg,
      },
      topic: memberName,
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
  }
});
