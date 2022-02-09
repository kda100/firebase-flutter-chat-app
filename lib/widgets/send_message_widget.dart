import 'package:firebase_chat_app/alert_dialogs/dismissible_alert_dialog.dart';
import 'package:firebase_chat_app/bottom_sheets/file_source_bottom_sheet.dart';
import 'package:firebase_chat_app/helpers/chats_media_storage_bucket_helper.dart';
import 'package:firebase_chat_app/helpers/file_helper.dart';
import 'package:firebase_chat_app/helpers/permissions_helper.dart';
import 'package:firebase_chat_app/models/chat_content_item_type.dart';
import 'package:firebase_chat_app/providers/chat_provider.dart';
import 'package:firebase_chat_app/screens/chat_media_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class SendMessageWidget extends StatefulWidget {
  @override
  _SendMessageWidgetState createState() => _SendMessageWidgetState();
}

class _SendMessageWidgetState extends State<SendMessageWidget> {
  TextEditingController _textEditingController = TextEditingController();
  String messageContent = "";
  ChatContentItemType chatContentItemType = ChatContentItemType.TEXT;
  double _textFieldContainerHeight = 50;

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Future<File?> _getMediaFile({
    required FileType fileType,
  }) async {
    final hasStoragePermission = await PermissionsHelper.permissionRequest(
        context: context, permissions: [Permission.storage]);
    if (hasStoragePermission) {
      final pickedMediaFile =
          await FileHelper.getChatMediaMessage(fileType: fileType);
      if (pickedMediaFile != null) {
        final bool isValidChatMediaFile =
            await ChatsMediaStorageBucketHelper.checkMediaBytes(
                pickedMediaFile);
        if (isValidChatMediaFile) {
          if (fileType == FileType.image) {
            chatContentItemType = ChatContentItemType.IMAGE;
          } else if (fileType == FileType.video) {
            chatContentItemType = ChatContentItemType.VIDEO;
          }
          final shouldSend = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return ChatMediaPreviewScreen(
                  isStorage: false,
                  chatContentItemType: chatContentItemType,
                  mediaPath: pickedMediaFile.path,
                );
              },
            ),
          );
          if (shouldSend) {
            return pickedMediaFile;
          } else
            await pickedMediaFile.delete();
        } else {
          await pickedMediaFile.delete();
          await showDialog(
            context: context,
            builder: (context) => DismissibleAlertDialog(
              title:
                  "Media must not exceed ${ChatsMediaStorageBucketHelper.maxMediaSizeMegaBytes}MB",
            ),
          );
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final ChatProvider chatProvider =
        Provider.of<ChatProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              height: _textFieldContainerHeight,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.15),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onTap: () {
                        chatProvider.updateReadReceipts();
                      },
                      controller: _textEditingController,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(300),
                      ],
                      textCapitalization: TextCapitalization.sentences,
                      expands: true,
                      autocorrect: true,
                      enableSuggestions: true,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: 'Type your message',
                        border: InputBorder.none,
                      ),
                      cursorColor: Theme.of(context).primaryColor,
                      onChanged: (value) {
                        setState(() {
                          print(MediaQuery.of(context).size.width);
                          if (value.length >
                                  MediaQuery.of(context).size.width * 0.106 ||
                              value.split("\n").length > 1) {
                            _textFieldContainerHeight = 100;
                          } else {
                            _textFieldContainerHeight = 50;
                          }
                          messageContent = value;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: IconButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        chatProvider.updateReadReceipts();
                        final File? pickedMediaFile =
                            await showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return FileTypeBottomSheet
                                .buildMediaFileTypeBottomSheet(
                                    context: context,
                                    importImage: () {
                                      return _getMediaFile(
                                        fileType: FileType.image,
                                      );
                                    },
                                    importVideo: () {
                                      return _getMediaFile(
                                        fileType: FileType.video,
                                      );
                                    });
                          },
                        );
                        if (pickedMediaFile != null) {
                          final String pickedMediaPath = pickedMediaFile.path;
                          if (chatContentItemType ==
                              ChatContentItemType.VIDEO) {
                            final File? thumbnail =
                                await FileHelper.genVideoThumbnail(
                                    videoPath: pickedMediaFile.path);
                            chatProvider.sendChatContentItem(
                                chatContentItemType: chatContentItemType,
                                content: [pickedMediaPath, thumbnail?.path]);
                          } else {
                            chatProvider.sendChatContentItem(
                                chatContentItemType: chatContentItemType,
                                content: pickedMediaPath);
                          }
                        }
                        chatContentItemType = ChatContentItemType.TEXT;
                      },
                      icon: Icon(
                        Icons.attach_file_outlined,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            alignment: Alignment.bottomRight,
            constraints: BoxConstraints(),
            onPressed: messageContent.trim().isEmpty
                ? null
                : () async {
                    FocusScope.of(context).unfocus();
                    chatProvider.updateReadReceipts();
                    chatProvider.sendChatContentItem(
                      content: messageContent.trim(),
                      chatContentItemType: chatContentItemType,
                    );
                    setState(() {
                      _textEditingController.clear();
                      _textFieldContainerHeight = 50;
                      messageContent = '';
                    });
                  },
            disabledColor: Theme.of(context).iconTheme.color?.withOpacity(0.50),
            icon: Icon(
              Icons.send,
            ),
          ),
        ],
      ),
    );
  }
}
