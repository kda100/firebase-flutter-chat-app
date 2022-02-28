import 'package:firebase_chat_app/bottom_sheets/file_source_bottom_sheet.dart';
import 'package:firebase_chat_app/dialogs/dismissible_alert_dialog.dart';
import 'package:firebase_chat_app/models/file_response.dart';
import 'package:firebase_chat_app/providers/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

///Widget containing a text field and icon buttons for sending text messages, images and videos.

class SendMessageWidget extends StatefulWidget {
  @override
  _SendMessageWidgetState createState() => _SendMessageWidgetState();
}

class _SendMessageWidgetState extends State<SendMessageWidget> {
  TextEditingController _textEditingController = TextEditingController();
  String messageContent = ""; // for TEXT message.
  double _textFieldContainerHeight =
      50; //container height for text field increases when more text is written.

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
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
                          //listens for changes in the string and adjusts size of text field container in response.
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
                        final FileResponse? fileResponse =
                            await showModalBottomSheet(
                          //user picks file source.
                          context: context,
                          builder: (context) {
                            return FileSourceBottomSheet(
                              importImage: () {
                                return chatProvider.getFilePath(
                                    fileType: FileType.image);
                              },
                              importVideo: () {
                                return chatProvider.getFilePath(
                                  fileType: FileType.video,
                                );
                              },
                            );
                          },
                        );
                        if (fileResponse != null) {
                          if (fileResponse.filePath != null) {
                            chatProvider.sendFile(fileResponse: fileResponse);
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) => DismissibleAlertDialog(
                                  title: fileResponse.message!),
                            );
                          }
                        }
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
                    //only used for sending text messages.
                    FocusScope.of(context).unfocus();
                    chatProvider.updateReadReceipts();
                    chatProvider.sendMessage(
                      message: messageContent.trim(),
                    );
                    setState(() {
                      //reformat text field once message has been sent.
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
