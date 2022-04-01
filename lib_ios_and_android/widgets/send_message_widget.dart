import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_chat_app/dialogs/dismissible_alert_dialog.dart';
import 'package:firebase_chat_app/models/platform_widget_models.dart';
import 'package:firebase_chat_app/providers/chat_provider.dart';
import 'package:firebase_chat_app/sheets/file_source_sheet.dart';
import 'package:firebase_chat_app/utilities/ui_util.dart';
import 'package:firebase_chat_app/widgets/platform_icon_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

///Widget containing a text field and icon buttons for sending text messages, images and videos.
class SendMessageWidget extends StatefulWidget {
  @override
  _SendMessageWidgetState createState() => _SendMessageWidgetState();
}

class _SendMessageWidgetState
    extends PlatformState<SendMessageWidget, Widget, Widget> {
  late ChatProvider chatProvider;
  late UIUtil uiUtil;
  TextEditingController _textEditingController = TextEditingController();
  String messageContent = ""; // for TEXT message.

  @override
  void initState() {
    chatProvider = Provider.of<ChatProvider>(context, listen: false);
    uiUtil = UIUtil(context);
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Widget _buildSendIconButton() {
    return PlatformIconButton(
      onPressed: () {
        chatProvider.updateReadReceipts();
        if (messageContent.trim().isNotEmpty) {
          //only used for sending text messages.
          FocusScope.of(context).unfocus();
          chatProvider.sendMessage(
            message: messageContent.trim(),
          );
          //reformat text field once message has been sent.
          _textEditingController.clear();
          messageContent = '';
        }
      },
      icon: Platform.isIOS
          ? Icon(
              CupertinoIcons.arrow_up_circle_fill,
              size: uiUtil.iconSize * 1.2,
            )
          : Icon(
              Icons.send,
              size: uiUtil.iconSize,
            ),
    );
  }

  Widget _buildAttachmentIconButton() {
    return PlatformIconButton(
      icon: Icon(
        Platform.isIOS ? CupertinoIcons.plus : Icons.attach_file,
        size: uiUtil.iconSize,
      ),
      onPressed: () async {
        FocusScope.of(context).unfocus();
        chatProvider.updateReadReceipts();
        FileType? fileType;
        if (Platform.isIOS) {
          fileType = await showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return FileSourceSheet();
            },
          );
        } else {
          fileType = await showModalBottomSheet(
            //user picks file source.
            context: context,
            builder: (context) {
              return FileSourceSheet();
            },
          );
        }
        if (fileType != null) {
          //sends file
          final String? message =
              await chatProvider.sendFile(fileType: fileType);
          if (message != null) {
            showDialog(
              context: context,
              builder: (context) => DismissibleAlertDialog(title: message),
            );
          }
        }
      },
    );
  }

  @override
  Widget buildCupertinoWidget(context) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: EdgeInsets.only(top: 4.0),
      decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: CupertinoColors.systemGrey5,
            ),
          ),
          color: CupertinoColors.systemGrey6),
      child: SafeArea(
        child: CupertinoTextField(
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
          onChanged: (value) {
            messageContent = value;
          },
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: CupertinoColors.systemGrey5,
            ),
          ),
          suffix: _buildSendIconButton(),
          prefix: _buildAttachmentIconButton(),
        ),
      ),
    );
  }

  @override
  Widget buildMaterialWidget(context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
                  _buildAttachmentIconButton(),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: _buildSendIconButton(),
          ),
        ],
      ),
    );
  }
}
