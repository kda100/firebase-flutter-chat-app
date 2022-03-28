import 'package:firebase_chat_app/constants/strings.dart';
import 'package:firebase_chat_app/models/responses/chat_response.dart';
import 'package:firebase_chat_app/providers/chat_provider.dart';
import 'package:firebase_chat_app/widgets/chat_item_widgets/chat_item_holder.dart';
import 'package:firebase_chat_app/widgets/fixed_profile_pic_widget.dart';
import 'package:firebase_chat_app/widgets/send_message_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_chat_app/models/platform_widget_models.dart';

///main screen where all messages will be displayed and where user will be able to send different
///types of messages.

class ChatScreen extends StatefulWidget {
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState
    extends PlatformState<ChatScreen, CupertinoPageScaffold, Scaffold>
    with WidgetsBindingObserver {
  late ChatProvider chatProvider;
  late Future<void> setUpChatData;

  @override
  void initState() {
    chatProvider = Provider.of<ChatProvider>(context, listen: false);
    setUpChatData = chatProvider.setUpChatData();
    WidgetsBinding.instance?.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    chatProvider
        .updateReadReceipts(); //updates read receipts when app changes state.
  }

  Widget _buildTitle() {
    return Text(Strings.appName);
  }

  Widget _buildScreenBody(BuildContext context) {
    final ChatProvider chatProvider = Provider.of<ChatProvider>(
      context,
      listen: false,
    );
    return FutureBuilder(
      future: setUpChatData,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator.adaptive(),
          );
        } else {
          if (snap.hasError) {
            print(snap.error);
            return Center(
              child: Text(
                'An error has occurred',
                style: Theme.of(context).textTheme.bodyText1,
              ),
            );
          } else {
            return Column(
              children: [
                Expanded(
                  child: Selector<ChatProvider, ChatResponse>(
                    //updates (rebuilds) a message has been sent, received or deleted.
                    selector: (context, chatProvider) =>
                        chatProvider.chatResponse,
                    builder: (context, chatResponse, _) {
                      if (chatResponse.chatResponseStatus ==
                          ChatResponseStatus.LOADING) {
                        //chat messages are loading.
                        return Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      }
                      if (chatResponse.chatResponseStatus ==
                          ChatResponseStatus.ERROR) {
                        //error in getting chat messages.
                        return Center(
                          child: Text(
                            chatResponse.message,
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        );
                      }
                      return ListView.builder(
                        //produces list of chat content item views with the most recent messages at the bottom of list.
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        reverse: true,
                        itemCount: chatProvider.chatItemsCount,
                        itemBuilder: (context, index) {
                          return ChatItemHolder(
                            chatItemView:
                                chatProvider.getChatItemView(index: index),
                          );
                        },
                      );
                    },
                  ),
                ),
                SendMessageWidget()
              ],
            );
          }
        }
      },
    );
  }

  @override
  CupertinoPageScaffold buildCupertinoWidget(context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        padding: EdgeInsetsDirectional.zero,
        leading: Padding(
          padding: const EdgeInsets.all(4.0),
          child: FixedProfilePicWidget(),
        ),
        middle: _buildTitle(),
      ),
      child: _buildScreenBody(
        context,
      ),
    );
  }

  @override
  Scaffold buildMaterialWidget(context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FixedProfilePicWidget(),
        ),
        title: _buildTitle(),
      ),
      body: _buildScreenBody(context),
    );
  }
}
