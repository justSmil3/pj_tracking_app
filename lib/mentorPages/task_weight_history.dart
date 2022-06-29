import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pj_app/TaskWeight.dart';
import 'package:pj_app/auth_service.dart';
import 'package:pj_app/providers.dart';
import 'package:pj_app/subtask.dart';
import 'package:pj_app/functions.dart';
import 'package:pj_app/task.dart';
import 'package:http/http.dart' as http;
import 'package:pj_app/urls.dart';
import 'package:pj_app/mentorPages/update_weight_popup.dart';
import 'package:provider/provider.dart';

class TaskWeightHistory extends StatefulWidget {
  const TaskWeightHistory({Key? key, required this.userId}) : super(key: key);
  final int userId;

  @override
  _TaskWeightHistoryState createState() => _TaskWeightHistoryState();
}

class _TaskWeightHistoryState extends State<TaskWeightHistory> {
  List<TaskWeight> weights = [];
  List<Subtask> subtasks = [];
  List<Task> tasks = [];

  @override
  void initState() {
    retrieveSubtasks().then((x) {
      subtasks = x;
      setState(() {});
    });
    retrieveUserWeights(subtasks, widget.userId).then((x) {
      weights = x;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    tasks = context.watch<TaskProvider>().tasks;
    return AlertDialog(
      content: Container(
        width: 300,
        height: 600,
        child: ListView.builder(
            itemCount: weights.length,
            itemBuilder: (BuildContext context, int index) {
              final item = weights[index];
              return Dismissible(
                key: Key(item.id.toString()),
                confirmDismiss: (direction) async {
                  return await showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                                content: Text(
                                    "Sind sie sich sicher, dass  sie die Priorisierung von \"" +
                                        subtasks
                                            .firstWhere(
                                                (x) => x.id == item.task)
                                            .name +
                                        "\" löschen wollen?"),
                                actions: [
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        TextButton(
                                            onPressed: () {
                                              getToken().then((x) =>
                                                  http.Client().delete(
                                                      DeleteWeightsUrl(item.id),
                                                      headers: {
                                                        HttpHeaders
                                                            .authorizationHeader: x
                                                      }));
                                              Navigator.of(context).pop(true);
                                            },
                                            child: Text(
                                              "DELETE",
                                              style:
                                                  TextStyle(color: Colors.red),
                                            )),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                            child: Text("CANCLE")),
                                      ])
                                ],
                              )) ??
                      false;
                },
                child: Center(
                  child: Container(
                    height: 60,
                    width: 400,
                    child: Card(
                      color: chooseColor(
                          subtasks.firstWhere((x) => item.task == x.id).task,
                          tasks,
                          subtasks),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: ListTile(
                          title: Text(subtasks
                              .firstWhere((x) => item.task == x.id)
                              .name),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  UpdateWeightPopup(
                                task: subtasks
                                    .firstWhere((x) => item.task == x.id),
                                weight: item,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }
}
