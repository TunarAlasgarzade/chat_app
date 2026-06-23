import 'package:audioplayers/audioplayers.dart';
import 'package:chat_app/components/message_options_sheet.dart';
import 'package:intl/intl.dart';
import 'package:chat_app/components/chat_bubble.dart';
import 'package:chat_app/components/my_textfield.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverID; 
  final String receiverName;

   const ChatPage({
    super.key, 
    required this.receiverEmail,
    required this.receiverID,
    required this.receiverName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool _isFirstLoad = true;
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _previousMessageCount = 0;
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  FocusNode myFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // scroll down logic when keyboard pops up
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 500), () => scrollDown());
      }
    });

    // scroll down logic when screen opens
    Future.delayed(const Duration(milliseconds: 500), () => scrollDown());

    // mark as read when screen opens
    _chatService.markAsRead(widget.receiverID);
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // scroll controller function
  void scrollDown() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent, 
        duration: const Duration(seconds: 1), 
        curve: Curves.fastLinearToSlowEaseIn,
      );
    }
  }

  // send message logic
  void sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      await _chatService.sendMessage(widget.receiverID, _messageController.text);
      _messageController.clear();
    }
    scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: StreamBuilder<bool>(
          stream: _chatService.isAccountDeleted(widget.receiverID),
          builder: (context, snapshot) {
            bool isDeleted = snapshot.data ?? false;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.receiverName),
                if (isDeleted)
                  const Text(
                    "This account has been deleted",
                    style: TextStyle(fontSize: 12),
                  ),
              ],
            );
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_downward),
            onPressed: scrollDown,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildUserInput(),
        ],
      ),
    );
  }

  // build message list widget
  Widget _buildMessageList() {
    String senderID = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiverID, senderID), 
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text("Error");
        if (snapshot.connectionState == ConnectionState.waiting) return const Text("Loading..");

        int currentCount = snapshot.data!.docs.length;
        if (currentCount != _previousMessageCount) {
        _chatService.markAsRead(widget.receiverID);
        _previousMessageCount = currentCount;
        
        if (_isFirstLoad) {
          _isFirstLoad = false;
        } else {
          final lastMessage = snapshot.data!.docs.last;
          final lastMessageData = lastMessage.data() as Map<String, dynamic>;
          final String lastSenderID = lastMessageData['senderID'];
          if (lastSenderID != senderID) {
            _audioPlayer.play(AssetSource('sounds/message.mp3'));
          }
        }
      }

        return ListView(
          controller: _scrollController,
          children: snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  // build message item widget
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // checks alignment
    bool isCurrentUser = data['senderID'] == _authService.getCurrentUser()!.uid; 
    var alignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    // formatted timestamps
    DateTime dateTime = (data['timestamp'] as Timestamp).toDate();
    String formattedTime = DateFormat('HH:mm').format(dateTime);

    // mark as read
    bool isRead = data['isRead'] ?? false;

    return GestureDetector(
      onLongPress: isCurrentUser ? () {
        showModalBottomSheet(
          context: context,
          builder: (context) => MessageOptionsSheet(
            receiverID: widget.receiverID,
            messageID: doc.id,
          ),
        );
      } : null,
      child: Container(
        alignment: alignment,
        child: Column(
          crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            ChatBubble(message: data["message"], isCurrentUser: isCurrentUser, isRead: isRead,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              child: Text(
                formattedTime,
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            )
          ],
        )
      ),
    );
  }

  // build user input widget
  Widget _buildUserInput() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 7,
        top: 7,
      ),
      child: Row(
        children: [
          Expanded(
            child: MyTextField(
              hintText: "Type a message", 
              obscureText: false, 
              controller: _messageController,
              focusNode: myFocusNode,
            ),
          ),
          Container(
            decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
            margin: const EdgeInsets.only(right: 9),
            child: IconButton(
              onPressed: sendMessage, 
              icon: const Icon(Icons.arrow_upward, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}