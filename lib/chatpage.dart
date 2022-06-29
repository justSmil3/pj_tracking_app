import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:pj_app/Colors.dart';
import 'package:pj_app/MentiAppBar.dart';
import 'package:flutter/material.dart';
import 'package:pj_app/Message.dart';
import 'package:pj_app/functions.dart';
import 'package:pj_app/urls.dart';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:pj_app/variables.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key, required this.otherId, this.bMentor = false})
      : super(key: key);

  final bool bMentor;
  final int otherId;
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final encrytionkey = enc.Key.fromUtf8("SgVkYp3s6v9yB&E)H+MbQeThWmZq4t7w");
  final iv = enc.IV.fromLength(16);

  List<TextMessage> messages = [];
  TextEditingController controller = TextEditingController();
  Color sendButtonColor = Colors.grey;
  final _controller = StreamController<List<TextMessage>>();
  final ScrollController scon = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );
  int maxIdx = 0;
  bool loaded_all = false;

  @override
  void initState() {
    MentiAppBar = Text("Chat mit deinem Mentor");
    _loadMessages();
    super.initState();
    setState(() {});
    CheckTokenStatus(context);
    Future.delayed(Duration(milliseconds: 500), () {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text(
                  "Es dürfen auf keinen fall Patientendaten über die Chatfunktion geteilt werden!"),
            );
          });
    });
  }

  @override
  void dispose() {
    initialPageCallback();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              _loadMessages();
            },
            child: StreamBuilder(
                stream: _controller.stream,
                builder: (context, snapshot) {
                  return ListView.builder(
                      physics: AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      controller: scon,
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (BuildContext context, int index) {
                        if (index > maxIdx) {
                          maxIdx = index;
                        }
                        if (index == messages.length - 10 && !loaded_all) {
                          _loadMessages(start: messages.length);
                        }
                        // else if (index < messages.length - 100)
                        // {
                        //   _discardMessaages(messages.length - 10);
                        // }

                        return MessageTile(messages[index].Message,
                            messages[index].creator != widget.otherId);
                      });
                }),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(
              offset: Offset(0, 4),
              blurRadius: 32,
              color: secondaryColor.withOpacity(0.08),
            )
          ]),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: TextField(
                            controller: controller,
                            onChanged: (value) {
                              if (value.trim() == "")
                                setState(() {
                                  sendButtonColor = Colors.grey;
                                });
                              else
                                setState(() {
                                  sendButtonColor = primaryColor;
                                });
                            },
                            decoration: InputDecoration(
                              hintText: "Type message",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 3,
                ),
                IconButton(
                  onPressed: () {
                    if (controller.text.trim() == "") return;
                    final encrypter = enc.Encrypter(enc.AES(encrytionkey));
                    String encrypted =
                        encrypter.encrypt(controller.text, iv: iv).base64;
                    sendMessage(encrypted, widget.otherId).then((_) {
                      loaded_all = false;
                      _loadMessages(start: 0, count: maxIdx < 20 ? 20 : maxIdx);
                    });
                    FocusManager.instance.primaryFocus?.unfocus();
                    controller.text = "";
                  },
                  icon: Icon(Icons.send),
                  color: sendButtonColor,
                ),
              ],
            ),
          ),
        )
      ],
    ));
  }

  void _loadMessages({int start = 0, int count = 20}) async {
    final encrypter = enc.Encrypter(enc.AES(encrytionkey));
    retrieveMessages(start, count, widget.bMentor ? widget.otherId : -1)
        .then((x) {
      if (x == null) return;
      x.forEach((v) {
        v.Message =
            encrypter.decrypt(enc.Encrypted.fromBase64(v.Message), iv: iv);
      });
      if (x.length == 0) loaded_all = true;
      if (start == 0) {
        messages = x;
      } else if (x is List<TextMessage>) {
        messages.addAll(x);
      }

      _controller.sink.add(messages);

      setState(() {});
    });
  }

  void _discardMessaages([int end = 20]) async {
    final encrypter = enc.Encrypter(enc.AES(encrytionkey));
    retrieveMessages(0, end).then((x) {
      x.forEach((v) {
        v.Message =
            encrypter.decrypt(enc.Encrypted.fromBase64(v.Message), iv: iv);
      });
      messages = x;
      _controller.sink.add(messages);

      setState(() {});
    });
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final bool isSendByMe;
  MessageTile(this.message, this.isSendByMe);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          left: isSendByMe ? 30 : 24, right: isSendByMe ? 24 : 30),
      margin: EdgeInsets.symmetric(vertical: 8),
      width: MediaQuery.of(context).size.width,
      alignment: isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSendByMe
                ? [primaryColor, darkPrimaryColor]
                : [Colors.black38, Colors.black54],
          ),
          borderRadius: isSendByMe
              ? BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                  bottomLeft: Radius.circular(23))
              : BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                  bottomRight: Radius.circular(23)),
        ),
        child: Text(
          message,
          style: TextStyle(color: Colors.white, fontSize: 17),
        ),
      ),
    );
  }
}
