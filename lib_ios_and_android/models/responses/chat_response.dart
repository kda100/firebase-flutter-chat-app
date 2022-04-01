enum ChatResponseStatus {
  LOADING,
  ERROR,
  SUCCESS,
}

///Response object used when updates to messages in chat respository have been made
///This class is used to communicate to Chat Provider and Chat Screen that a change
///has been made to messages.

class ChatResponse {
  final ChatResponseStatus chatResponseStatus;
  String _message = ""; //message to display to chat screen.

  ChatResponse.loading() : chatResponseStatus = ChatResponseStatus.LOADING;

  ChatResponse.update() : chatResponseStatus = ChatResponseStatus.SUCCESS;

  ChatResponse.error()
      : chatResponseStatus = ChatResponseStatus.ERROR,
        _message = "An error has occurred";

  String get message => _message;
}
