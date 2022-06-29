import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:pj_app/Colors.dart';
import 'package:pj_app/MentiAppBar.dart';
import 'package:pj_app/providers.dart';
import 'package:pj_app/subtask.dart';
import 'package:pj_app/trackpopup.dart';
import 'package:provider/provider.dart';
import 'package:pj_app/task.dart';
import 'package:pj_app/urls.dart';
import 'package:pj_app/functions.dart';
import 'package:pj_app/variables.dart';

class TrackPage extends StatefulWidget {
  final PageController pageController;
  final http.Client client;
  final Widget newAppBar;
  final Widget Function(Subtask) Popup;
  final int MentiID;
  const TrackPage({
    Key? key,
    required this.client,
    required this.pageController,
    required this.newAppBar,
    required this.Popup,
    this.MentiID = -1,
  }) : super(key: key);

  @override
  _TrackPageState createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {
  TextEditingController controller = TextEditingController();
  List<Subtask> tasks = [];
  List<Subtask> trackedTask = [];
  List<Task> ctasks = [];
  final _controller = StreamController<List<Subtask>>();

  @override
  void initState() {
    MentiAppBar = widget.newAppBar;

    setState(() {});
    super.initState();
    CheckTokenStatus(context);
  }

  @override
  void dispose() {
    initialPageCallback();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    ctasks = context.watch<TaskProvider>().tasks;
    tasks = context.watch<SubtaskProvider>().tasks;
    _controller.sink.add(tasks);
    retrieveTrackedSubtasks(tasks, userID: widget.MentiID).then((tracked_taks) {
      trackedTask = tracked_taks;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () async {
                    context
                        .read<SubtaskProvider>()
                        .LoadSubtasks(mentiId: widget.MentiID);
                  },
                  child: StreamBuilder(
                      stream: _controller.stream,
                      builder: (context, snapshot) {
                        if (tasks.length < 1) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: Colors.redAccent,
                              backgroundColor: Colors.blueGrey,
                              strokeWidth: 12,
                            ),
                          );
                        }
                        return ListView.builder(
                            shrinkWrap: true,
                            itemCount: tasks.length,
                            itemBuilder: (BuildContext context, int index) {
                              return _TrackTask(index);
                            });
                      }),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).size.height / 3.5,
                  right: MediaQuery.of(context).size.width / 2 - 25,
                  child: Container(
                    width: 50,
                    height: 50,
                    child: FloatingActionButton(
                      backgroundColor: lightSecondaryColor,
                      onPressed: () {
                        showSearch(
                            context: context,
                            delegate: TaskSearch(
                                client: widget.client,
                                tasks: tasks,
                                Popup: widget.Popup));
                      },
                      child: Icon(
                        Icons.search,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget DoneIcon(Subtask task) {
    if (trackedTask.contains(task)) {
      return Icon(
        Icons.check_circle,
        color: Colors.green[300],
        size: 25,
      );
    }
    return Container();
  }

  Widget _TrackTask(int index) {
    Widget card = Center(
      child: Container(
        height: 70,
        width: MediaQuery.of(context).size.width,
        child: Card(
          color: chooseColor(tasks[index].task, ctasks, tasks),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tasks[index].name,
                    style: TextStyle(fontSize: 12, fontFamily: 'Montserrat'),
                  ),
                  DoneIcon(tasks[index]),
                ],
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => widget.Popup(tasks[index]),
                );
              },
            ),
          ),
        ),
      ),
    );
    if (index > 0) {
      if (tasks[index].task != tasks[index - 1].task) {
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 20),
            ),
            Center(
              child: Container(
                height: 30,
                width: MediaQuery.of(context).size.width * .96,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    ctasks.firstWhere((x) => x.id == tasks[index].task).name,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: "Montserrat",
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            card,
          ],
        );
      }
    } else {
      return Column(
        children: [
          Center(
            child: Container(
              height: 30,
              width: MediaQuery.of(context).size.width * .96,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  ctasks.firstWhere((x) => x.id == tasks[index].task).name,
                  style: TextStyle(
                    fontFamily: "Montserrat",
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          card,
        ],
      );
    }
    return card;
  }
}

class TaskSearch extends SearchDelegate<String> {
  List<Subtask> tasks = [];
  final http.Client client;
  final Widget Function(Subtask) Popup;

  TaskSearch({
    required this.client,
    required this.tasks,
    required this.Popup,
  });

  final List<Subtask> recentTasks = [];

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = "";
          },
          icon: Icon(Icons.clear))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, "");
      },
      icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    Subtask idx = tasks.firstWhere((x) => x.name == query);
    return Popup(idx);
    // return Container(
    //   height: 100,
    //   width: 100,
    //   child: Card(
    //     color: Colors.red,
    //     shape: StadiumBorder(),
    //     child: Center(
    //       child: Text(query),
    //     ),
    //   ),
    // );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Subtask> suggestionList = tasks;
    if (query.isNotEmpty) {
      suggestionList = tasks
          .where((element) =>
              element.name.toLowerCase().startsWith(query.toLowerCase()))
          .toList();
      suggestionList.addAll(tasks.where((element) =>
          element.description.toLowerCase().contains(query.toLowerCase())));
    }

    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        onTap: () {
          query = suggestionList[index].name;
          showResults(context);
        },
        leading: Icon(Icons.task),
        title: RichText(
          text: TextSpan(
            text: suggestionList[index].name.substring(0, query.length),
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            children: [
              TextSpan(
                text: suggestionList[index].name.substring(query.length),
                style: TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.normal),
              )
            ],
          ),
        ),
      ),
      itemCount: suggestionList.length,
    );
  }
}
