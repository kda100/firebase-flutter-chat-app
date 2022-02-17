import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:video_thumbnail/video_thumbnail.dart';

///class containing helpers to use for File objects.

class FileHelper {
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

  ///takes in a video files path, to generate a video thumbnail,
  ///using a snapshot of the 1st second of videos frame.
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
