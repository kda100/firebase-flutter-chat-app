import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as fieldNames from "../constants/fieldNames";
import * as strings from "../constants/strings";

const chatContentsDocRefString = "Your Collection Reference";

exports.onCreateChatContentItem = functions.firestore.document(chatContentsDocRefString).onCreate(async (snap, context) => {
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

exports.onDeleteChatContentItem = functions.firestore.document(chatContentsDocRefString).onDelete(async (snap, context) => {

    try {
        const chatContentItemDocData: FirebaseFirestore.DocumentData | undefined = snap.data();
        if (typeof chatContentItemDocData !== "undefined") {
            const chatContentItemType: string = chatContentItemDocData[fieldNames.chatContentItemTypeField];

            if (chatContentItemType == "image") {
                const chatImageFile = admin.storage().bucket().file("Your file location");
                if ((await chatImageFile.exists())[0]) {
                    await chatImageFile.delete();
                }
            }

            if (chatContentItemType == "video") {
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
