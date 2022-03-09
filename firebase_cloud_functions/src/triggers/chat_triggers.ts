import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as fieldNames from "../constants/field_names";
import * as strings from "../constants/strings";

const chatItemsDocRefString = "Chat item doc ref";

// Trigger is called whenever a new ChatContentItem doc is added to Firestore. The function updates the timestamp and changes onCloud = true for the document.

exports.onCreateChatItem = functions.firestore.document(chatItemsDocRefString).onCreate(async (snap, context) => {
    try {
        await snap.ref.update({createdAt: admin.firestore.Timestamp.now(), onCloud: true});
    } catch (error) {
        if (error instanceof Error) {
            functions.logger.log(error.message);
        } else {
            functions.logger.log(strings.errorMessage);
        }
    }
});

// Trigger is called whenever ChatContentItem doc is deleted.

exports.onDeleteChatItem = functions.firestore.document(chatItemsDocRefString).onDelete(async (snap, context) => {
    try {
        const chatItemDocData: FirebaseFirestore.DocumentData | undefined = snap.data();
        if (typeof chatItemDocData !== "undefined") {
            const chatItemType: string = chatItemDocData[fieldNames.chatItemTypeField];

            if (chatItemType == "image") { // image storage reference is also deleted
                const chatImageFile = admin.storage().bucket().file(`Image storage file ref`);
                if ((await chatImageFile.exists())[0]) {
                    await chatImageFile.delete();
                }
            }

            if (chatItemType == "video") { // video storage reference also deleted.
                await admin.storage().bucket().deleteFiles({prefix: `Video storage file refs`});
            }
        }
    } catch (error) {
        if (error instanceof Error) {
            functions.logger.log(error.message);
        } else {
            functions.logger.log(strings.errorMessage);
        }
    }
});
