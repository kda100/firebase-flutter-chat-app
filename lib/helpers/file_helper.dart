import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:video_thumbnail/video_thumbnail.dart';

class FileHelper {
  static Future<File?> getChatMediaItem({required FileType fileType}) async {
    FilePickerResult? filePickerResult =
        await FilePicker.platform.pickFiles(type: fileType);
    String? filePath = filePickerResult?.files.single.path;
    if (filePath != null) {
      return File(filePath);
    }
    return null;
  }

  static Future<File?> genVideoThumbnail({required String videoPath}) async {
    String? thumbnailFilePath = await VideoThumbnail.thumbnailFile(
      video: videoPath,
      imageFormat: ImageFormat.JPEG,
    );
    if (thumbnailFilePath != null) {
      return File(thumbnailFilePath);
    }
    return null;
  }
}
