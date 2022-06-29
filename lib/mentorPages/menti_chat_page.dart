import 'package:flutter/material.dart';

class MentiChatPage extends StatefulWidget {
  const MentiChatPage({Key? key, required this.pageController})
      : super(key: key);
  final PageController pageController;

  @override
  _MentiChatPageState createState() => _MentiChatPageState();
}

class _MentiChatPageState extends State<MentiChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("chat"),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 8,
        shape: CircularNotchedRectangle(),
        child: Container(
          height: 45,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.note_add),
                onPressed: () {
                  widget.pageController.jumpToPage(0);
                },
              ),
              IconButton(
                icon: Icon(Icons.query_stats),
                onPressed: () {
                  widget.pageController.jumpToPage(1);
                },
              ),
              Container(
                width: 80,
                height: 40,
                child: Card(
                  color: Colors.black12,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Icon(Icons.question_answer),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
