import 'package:flutter/material.dart';
import 'package:pj_app/chatpage.dart';
import 'package:pj_app/mentorPages/menti.dart';

import 'package:pj_app/mentorPages/menti_weight_page.dart';
import 'package:pj_app/mentorPages/menti_stats_page.dart';
import 'package:pj_app/mentorPages/menti_chat_page.dart';
import 'package:pj_app/mentorPages/task_weight_history.dart';
import 'package:pj_app/providers.dart';
import 'package:provider/provider.dart';
import 'package:pj_app/statspage.dart';
import 'package:pj_app/subtask.dart';
import 'package:pj_app/trackpage.dart';
import 'package:http/http.dart' as http;
import 'package:pj_app/mentorPages/task_weight_popup.dart';
import 'package:pj_app/variables.dart';

class MentiPage extends StatefulWidget {
  const MentiPage({Key? key, required this.user}) : super(key: key);
  final Menti user;

  @override
  _MentiPageState createState() => _MentiPageState();
}

class _MentiPageState extends State<MentiPage> {
  final controller = PageController(initialPage: 1);

  String appbarTitle = "Mentor Page";

  int previousPageIndex = 1;
  int pageIndex = 1;

  Widget NavbarIconfield(int index, Icon _icon) {
    Widget iconButton = IconButton(
        onPressed: () {
          controller.animateToPage(index,
              duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
        },
        icon: _icon);

    if (pageIndex != index) return iconButton;

    return Stack(
      children: [
        Container(
          width: 60,
          child: RawMaterialButton(
            onPressed: () => controller.jumpToPage(index),
            fillColor: Colors.blueGrey.withOpacity(.3),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
        Positioned(left: 6.5, child: iconButton)
      ],
    );
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    context.read<TaskProvider>().LoadTasks();
    context.read<SubtaskProvider>().LoadSubtasks(mentiId: widget.user.user);
    context.read<TrackProvider>().LoadTracks(user: widget.user.user);
  }

  @override
  Widget build(BuildContext context) {
    appbarTitle = widget.user.name;

    BottomAppBar bottomAppBar = BottomAppBar(
      child: Container(
        height: BottomNavigationBarHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            NavbarIconfield(0, Icon(Icons.note_add)),
            NavbarIconfield(1, Icon(Icons.query_stats)),
            NavbarIconfield(2, Icon(Icons.question_answer)),
          ],
        ),
      ),
    );

    Widget wheightingPageAppbar =
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      IconButton(
        icon: Icon(Icons.assignment),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => TaskWeightHistory(
              userId: widget.user.user,
            ),
          );
        },
      ),
      Text("Priorisierungen Für Menti"),
    ]);

    Widget Function(Subtask) PopupFunction = (task) {
      return TaskWeightPopup(
        task: task,
        userId: widget.user.user,
        client: http.Client(),
      );
    };

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 43,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/'),
            color: Colors.white,
            icon: Icon(Icons.logout),
          ),
        ],
        title: Text(appbarTitle),
      ),
      bottomNavigationBar: bottomAppBar,
      body: PageView(
        controller: controller,
        scrollDirection: Axis.horizontal,
        onPageChanged: (index) {
          previousPageIndex = pageIndex;
          pageIndex = index;
          setState(() {});
        },
        children: [
          //MentiWeightPage(pageController: controller, userId: widget.user.user,),
          // TODO remove client here
          TrackPage(
            client: http.Client(),
            pageController: controller,
            newAppBar: wheightingPageAppbar,
            Popup: PopupFunction,
            MentiID: widget.user.user,
          ),
          StatsPage(client: http.Client(), UserId: widget.user.user),
          ChatPage(
            otherId: widget.user.user,
            bMentor: true,
          )
        ],
      ),
    );
  }
}
