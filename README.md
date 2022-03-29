# Firebase Flutter Chat App

This repository contains all the code for a one-to-one chat app developed using Flutter and Firebase Cloud Firestore. It has the capability of sending written messages, videos and images. It can accurately keep track of the timestamps and read receipts for each message. It also grants users the ability to delete messages they have sent. This can be applied to your app by providing a firebase collection reference where all messages will be stored and a storage reference where all images and videos will be stored.

Please find in this respository the Dart code used for the Flutter UI and the Typescript code used for Firebase Cloud Function triggers.


Recently added an additional lib folder "lib_ios_and_android" which contains the flutter code that can be used in both Android and IOS devices to give a more native feel for both devices.

![ios_sending_a_text_message](https://user-images.githubusercontent.com/65980399/160703421-1aca5770-31d8-4f54-a879-42e034b20062.gif)
