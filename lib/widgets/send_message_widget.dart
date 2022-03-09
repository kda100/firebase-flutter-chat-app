import 'package:firebase_chat_app/bottom_sheets/file_source_bottom_sheet.dart';
import 'package:firebase_chat_app/dialogs/dismissible_alert_dialog.dart';
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
                        messageContent = value;
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
                        final FileType? fileType = await showModalBottomSheet(
                          //user picks file source.
                          context: context,
                          builder: (context) {
                            return FileSourceBottomSheet();
                          },
                        );
                        if (fileType != null) {
                          //sends file
                          final String? message =
                              await chatProvider.sendFile(fileType: fileType);
                          if (message != null) {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  DismissibleAlertDialog(title: message),
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
            onPressed: () async {
              if (messageContent.trim().isNotEmpty) {
                //only used for sending text messages.
                FocusScope.of(context).unfocus();
                chatProvider.updateReadReceipts();
                chatProvider.sendMessage(
                  message: messageContent.trim(),
                );
                //reformat text field once message has been sent.
                _textEditingController.clear();
                messageContent = '';
              }
            },
            icon: Icon(
              Icons.send,
            ),
          ),
        ],
      ),
    );
  }
}
