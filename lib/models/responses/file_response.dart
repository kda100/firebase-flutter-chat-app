import 'package:file_picker/file_picker.dart';
import 'package:firebase_chat_app/services/file_services.dart';

///model representing the response when user attempts to pick a file from their device

class FileResponse {
  String? _filePath; //URI of file
  String? _message; //may contain important information from the request
  FileType? _fileType; //fileType user has requested.

  FileResponse.success({required String filePath, required FileType fileType})
      : _filePath = filePath,
        _fileType = fileType;

  FileResponse.accessDenied()
      : _message =
            "Storage permission is required to do this, please grant permission in your device's App Management settings.";

  FileResponse.sizeExceeded()
      : _message =
            "Media must not exceed ${FileServices.maxMediaSizeMegaBytes}MB";
  String? get message => _message;

  FileType? get fileType => _fileType;

  String? get filePath => _filePath;
}
