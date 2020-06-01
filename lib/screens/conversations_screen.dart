import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flash_chat/models/conversation.dart';
import 'package:flash_chat/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ConversationsScreen extends StatefulWidget {
  static const String routeName = 'conversationsScreen';

  @override
  _ConversationsScreenState createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final UserService _userService = UserService.instance;

  List<Conversation> userConversations;
  bool showSpinner = false;

  @override
  void initState() {
    super.initState();
    getUserConversations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      body: ModalProgressHUD(
          child: userConversations != null
              ? userConversations.isNotEmpty
                  ? ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: userConversations.length,
                      itemBuilder: (context, index) {
                        final conversation = userConversations[index];
                        return UserConversationsList(
                            conversation: conversation);
                      })
                  : Center(
                      child: TypewriterAnimatedTextKit(
                      text: ['no conversations'],
                      speed: Duration(milliseconds: 50),
                      totalRepeatCount: 1,
                      textStyle: TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.w900,
                      ),
                    ))
              : Container(),
          inAsyncCall: showSpinner),
    );
  }

  void getUserConversations() async {
    displaySpinner();

    List<Conversation> userConversationsList = [];

    try {
      final currentUser = await _userService.getCurrentUser();
      userConversationsList =
          await _userService.getUserConversations(currentUser.email);
    } catch (e) {
      print(e);
    } finally {
      hideSpinner();
    }

    setState(() {
      userConversations = userConversationsList;
    });
  }

  void displaySpinner() {
    setState(() {
      showSpinner = true;
    });
  }

  void hideSpinner() {
    setState(() {
      showSpinner = false;
    });
  }
}

class UserConversationsList extends StatelessWidget {
  final Conversation conversation;

  const UserConversationsList({this.conversation});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(0),
        child: Card(
          color: Colors.transparent,
          child: Row(children: <Widget>[
            Expanded(
                child: ListTile(
              title: Text(
                  conversation.otherUser.firstName +
                      ' ' +
                      conversation.otherUser.lastName,
                  style: TextStyle(fontSize: 20)),
              subtitle: Text(conversation.lastMessage.messageText,
                  style: TextStyle(fontSize: 15),
                  overflow: TextOverflow.ellipsis),
            )),
            Expanded(
                child: ListTile(
              title: Text(
                  timestampToPrintableDate(
                      conversation.lastMessage.messageTimestamp),
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 15)),
              subtitle: Text(''),
            )),
          ]),
        ));
  }

  String timestampToPrintableDate(int timestamp) {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

    final DateFormat dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return dateFormat.format(dateTime);
  }
}
