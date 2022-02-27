import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:video_thumbnail/video_thumbnail.dart';

///class containing helpers to use for File objects.

class FileHelper {
  static const maxMediaSizeMegaBytes = 200;

  ///checks if media file is below a threshold.
  static Future<bool> checkMediaBytes(File file) async {
    final int fileSize = await file.length();
    if (fileSize > maxMediaSizeMegaBytes * 1000000) return false;
    return true;
  }

  ///takes in a fileType object and returns a single file object (image or video)
  static Future<File?> getChatMediaItem({required FileType fileType}) async {
    FilePickerResult? filePickerResult =
        await FilePicker.platform.pickFiles(type: fileType);
    String? filePath = filePickerResult?.files.single.path;
    if (filePath != null) {
      return File(filePath);
    }
    return null;
  }

  ///takes in a video file's path, to generate a video thumbnail,
  ///using a snapshot of the 1st second of video's frame.
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
