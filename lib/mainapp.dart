import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pj_tracking_app/MentiAppBar.dart';
import 'package:pj_tracking_app/functions.dart';
import 'package:pj_tracking_app/mainpage.dart';
import 'package:pj_tracking_app/providers.dart';
import 'package:pj_tracking_app/subtask.dart';
import 'package:pj_tracking_app/trackpage.dart';
import 'package:pj_tracking_app/mainpageview.dart';
import 'package:pj_tracking_app/chatpage.dart';
import 'package:pj_tracking_app/urls.dart';
import 'package:pj_tracking_app/variables.dart';
import 'package:pj_tracking_app/trackhistory.dart';
import 'package:pj_tracking_app/trackpopup.dart';
import 'package:provider/provider.dart';

import 'task.dart';

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  http.Client client = http.Client();
  List<Task> tasks = [];
  int previousPageIndex = 1;
  int pageIndex = 1;
  int mentorId = -1;

  @override
  void initState() {
    GetMentorID().then((value) {
      mentorId = value;
      setState(() {});
    });
    setAppBar = (Widget newAppBar) {
      MentiAppBar = newAppBar;
      setState(() {});
    };
    context.read<TaskProvider>().LoadTasks();
    context.read<SubtaskProvider>().LoadSubtasks();
    context.read<TrackProvider>().LoadTracks();
    super.initState();
  }

  void _deleteNote(int id) async {
    client.delete(deleteTrackUrl(id));
    tasks = context.watch<TaskProvider>().tasks;
    setState(() {});
  }

  final controller = PageController(initialPage: 1, keepPage: false);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

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
  Widget build(BuildContext context) {
    PageController secondController = PageController();
    AppBar appbar = AppBar(
      toolbarHeight: AppBarHeight,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontFamily: 'Montserrat',
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.pushNamed(context, '/'),
          color: Colors.black,
          icon: Icon(Icons.logout),
        ),
      ],
      title: GetMentiAppAppbar(),
    );

    BottomAppBar bottomAppBar = BottomAppBar(
      child: Container(
        height: BottomNavigationBarHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            NavbarIconfield(0, Icon(Icons.task)),
            NavbarIconfield(1, Icon(Icons.home)),
            NavbarIconfield(2, Icon(Icons.question_answer)),
          ],
        ),
      ),
    );

    actualAppBarHeight = appbar.preferredSize.height;

    MainPageView mpv = MainPageView(
        mainCon: controller,
        callback: (value) {
          return secondController = value;
        });

    Widget trackPageAppBar =
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      //IconButton(
      //  icon: Icon(
      //    Icons.history,
      //    color: Colors.black,
      //  ),
      //  onPressed: () => {
      //    showDialog(
      //      context: context,
      //      builder: (BuildContext context) => TrackHistory(),
      //    )
      //  },
      //),
      Text("Dein EPA Stand"),
    ]);

    return WillPopScope(
      onWillPop: () async {
        controller.jumpToPage(previousPageIndex);
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: appbar,
        bottomNavigationBar: bottomAppBar,
        body: PageView(
          controller: controller,
          onPageChanged: (index) {
            previousPageIndex = pageIndex;
            pageIndex = index;
            setState(() {});
          },
          children: [
            TrackPage(
              client: client,
              pageController: controller,
              newAppBar: trackPageAppBar,
              Popup: (Subtask task) => TrackPopup(
                title: task.name,
                description: task.description,
                taskId: task.id,
              ),
            ),
            mpv,
            ChatPage(
              otherId: mentorId,
            ),
          ],
        ),
      ),
    );
  }
}
