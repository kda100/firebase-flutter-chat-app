import 'package:file_picker/file_picker.dart';
import 'package:firebase_chat_app/services/file_services.dart';

///model representing the response when user attempts to pick a file from their device

class FileResponse {
  String? filePath; //URI of file
  String? message; //may contain important information from the request
  FileType? fileType; //fileType user has requested.

  FileResponse.success({required this.filePath, required this.fileType});

  FileResponse.accessDenied()
      : message =
            "Storage permission is required to do this, please grant permission in your device's App Management settings.";

  FileResponse.sizeExceeded()
      : message =
            "Media must not exceed ${FileServices.maxMediaSizeMegaBytes}MB";
}
