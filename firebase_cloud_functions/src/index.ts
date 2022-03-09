import * as admin from "firebase-admin";

admin.initializeApp();

module.exports = {
    ...require("./triggers/chat_triggers"),
};
