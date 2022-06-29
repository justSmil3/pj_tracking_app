import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pj_tracking_app/MentiAppBar.dart';
import 'package:pj_tracking_app/functions.dart';
import 'package:pj_tracking_app/mainpage.dart';
import 'package:pj_tracking_app/providers.dart';
import 'package:pj_tracking_app/statspage.dart';
import 'package:pj_tracking_app/urls.dart';
import 'package:provider/provider.dart';

import 'auth_service.dart';
import 'note.dart';
import 'task.dart';

typedef ConValue = PageController Function(PageController);

class MainPageView extends StatefulWidget {
  const MainPageView({Key? key, required this.mainCon, required this.callback})
      : super(key: key);
  final PageController mainCon;
  final ConValue callback;

  @override
  State<MainPageView> createState() => _MainPageViewState();
}

class _MainPageViewState extends State<MainPageView> {
  http.Client client = http.Client();
  List<Task> tasks = [];

  @override
  void initState() {
    setState(() {});
    super.initState();
  }

  void _deleteNote(int id) async {
    client.delete(deleteTrackUrl(id));
    setState(() {});
  }

  final controller = PageController(initialPage: 1);

  @override
  void dispose() {
    print("mainpagepageview got disposed");
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    print("test");
    controller.previousPage(
      duration: Duration(milliseconds: 200),
      curve: Curves.linear,
    );
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    tasks = context.watch<TaskProvider>().tasks;
    final pageView = PageView(
      controller: controller,
      scrollDirection: Axis.vertical,
      children: [
        StatsPage(
          client: client,
        ),
        MainPage(controller: widget.mainCon, secondCon: controller),
      ],
    );

    widget.callback(controller);
    return pageView;
  }
}
