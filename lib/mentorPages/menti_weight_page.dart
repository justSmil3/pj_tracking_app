import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pj_app/providers.dart';
import 'package:pj_app/task.dart';
import 'package:pj_app/subtask.dart';
import 'package:pj_app/functions.dart';
import 'package:http/http.dart' as http;
import 'package:pj_app/mentorPages/task_weight_history.dart';
import 'package:pj_app/mentorPages/task_weight_popup.dart';
import 'package:provider/provider.dart';

class MentiWeightPage extends StatefulWidget {
  const MentiWeightPage(
      {Key? key, required this.pageController, required this.userId})
      : super(key: key);
  final PageController pageController;
  final int userId;

  @override
  _MentiWeightPageState createState() => _MentiWeightPageState();
}

class _MentiWeightPageState extends State<MentiWeightPage> {
  List<Task> tasks = [];
  List<Subtask> subtasks = [];
  Color color = Colors.white;
  final _controller = StreamController<List<Subtask>>();
  //final _controller = StreamController<List<statobject>>();

  @override
  void initState() {
    setState(() {});
    retrieveSortetSubtasks().then((x) {
      subtasks = x;
      setState(() {});
      _controller.sink.add(subtasks);
    });
    CheckTokenStatus(context);
  }

  @override
  Widget build(BuildContext context) {
    tasks = context.watch<TaskProvider>().tasks;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.assignment),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) => TaskWeightHistory(
                userId: widget.userId,
              ),
            );
          },
        ),
        title: Text("Priorisierungen Für Menti"),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 8,
        shape: CircularNotchedRectangle(),
        child: Container(
          height: 45,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                width: 80,
                height: 40,
                child: Card(
                  color: Colors.black12,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Icon(Icons.note_add),
                ),
              ),
              IconButton(
                icon: Icon(Icons.query_stats),
                onPressed: () {
                  widget.pageController.jumpToPage(1);
                },
              ),
              IconButton(
                icon: Icon(Icons.question_answer),
                onPressed: () {
                  widget.pageController.jumpToPage(2);
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showSearch(
              context: context,
              delegate: TaskSearch(tasks: subtasks, UserId: widget.userId));
        },
        child: const Icon(Icons.search),
        backgroundColor: Colors.grey,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: StreamBuilder(
        stream: _controller.stream,
        builder: (context, snapshot) {
          if (subtasks.length < 1) {
            return Center(
              child: SizedBox(
                width: 150,
                height: 150,
                child: CircularProgressIndicator(
                  color: Colors.redAccent,
                  backgroundColor: Colors.blueGrey,
                  strokeWidth: 12,
                ),
              ),
            );
          }
          return Container(
            child: ListView.builder(
              itemCount: subtasks.length,
              itemBuilder: (BuildContext context, int index) {
                return _WeightTask(index);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _WeightTask(int index) {
    Color _color = chooseColor(subtasks[index].task, tasks, subtasks);

    Widget card = Container(
        height: 70,
        width: 400,
        child: Card(
          color: _color,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: ListTile(
              title: Text(subtasks[index].name),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => TaskWeightPopup(
                    task: subtasks[index],
                    userId: widget.userId,
                    client: http.Client(),
                  ),
                );
              },
            ),
          ),
        ));

    if (index > 0) {
      if (subtasks[index].task != subtasks[index - 1].task) {
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 20),
            ),
            Center(
              child: Container(
                height: 30,
                width: 380,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    tasks.firstWhere((x) => x.id == subtasks[index].task).name,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 20,
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
              width: 380,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  tasks.firstWhere((x) => x.id == subtasks[index].task).name,
                  style: TextStyle(
                    fontSize: 20,
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
  int UserId;

  TaskSearch({required this.tasks, required this.UserId});

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
    Subtask currentTask = tasks.firstWhere((x) => x.name == query);
    return TaskWeightPopup(
      task: currentTask,
      client: http.Client(),
      userId: UserId,
    );
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
