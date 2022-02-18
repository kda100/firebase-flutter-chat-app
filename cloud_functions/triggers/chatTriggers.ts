import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as fieldNames from "../constants/fieldNames";
import * as strings from "../constants/strings";

const chatContentItemsDocRefString = "Your Collection Reference";

//Trigger is called whenever a new ChatContentItem doc is added to Firestore. The function updates the timestamp and changes onCloud = true for the document.

exports.onCreateChatContentItem = functions.firestore.document(chatContentItemsDocRefString).onCreate(async (snap, context) => {
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

//Trigger is called whenever ChatContentItem doc is deleted.

exports.onDeleteChatContentItem = functions.firestore.document(chatContentItemsDocRefString).onDelete(async (snap, context) => {

    try {
        const chatContentItemDocData: FirebaseFirestore.DocumentData | undefined = snap.data();
        if (typeof chatContentItemDocData !== "undefined") {
            const chatContentItemType: string = chatContentItemDocData[fieldNames.chatContentItemTypeField];

            if (chatContentItemType == "image") { //image storage reference is also deleted
                const chatImageFile = admin.storage().bucket().file("Your file location");
                if ((await chatImageFile.exists())[0]) {
                    await chatImageFile.delete();
                }
            }

            if (chatContentItemType == "video") { //video storage reference also deleted.
                await admin.storage().bucket().deleteFiles({prefix: "Your folder location"});
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
