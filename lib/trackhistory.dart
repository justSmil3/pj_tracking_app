import 'package:flutter/material.dart';
import 'package:pj_app/providers.dart';
import 'package:pj_app/task.dart';
import 'package:pj_app/track.dart';
import 'package:pj_app/subtask.dart';
import 'package:pj_app/updatetrackpopup.dart';
import 'dart:convert';
import 'package:pj_app/urls.dart';
import 'package:pj_app/updatetrackpopup.dart';
import 'package:http/http.dart' as http;
import 'package:pj_app/functions.dart';
import 'package:pj_app/auth_service.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class TrackHistory extends StatefulWidget {
  const TrackHistory({Key? key}) : super(key: key);

  @override
  _TrackHistoryState createState() => _TrackHistoryState();
}

class _TrackHistoryState extends State<TrackHistory> {
  final client = http.Client();

  @override
  void initState() {
    retrieveTracks().then((x) {
      tracks = x;
      setState(() {});
    });
    retrieveSubtasks().then((x) {
      tasks = x;
      setState(() {});
    });
    setState(() {});

    super.initState();
  }

  List<Track> tracks = [];
  List<Track> deletedTracks = [];
  List<Subtask> tasks = [];
  List<Task> ctasks = [];

  @override
  Widget build(BuildContext context) {
    ctasks = context.watch<TaskProvider>().tasks;
    return AlertDialog(
      actions: [
        IconButton(
            onPressed: () {
              if (deletedTracks.isEmpty) return;
              Track tmp = deletedTracks.first;
              deletedTracks.removeAt(0);

              final Map<String, String> headers = {
                "Content-Type": "application/json"
              };
              final Map<String, String> body = {
                "task": tasks.firstWhere((x) => x.id == tmp.task).name,
                "rating_0": tmp.rating_0,
                "rating_1": tmp.rating_1.toString()
              };

              client.post(createTrackUrl,
                  headers: headers, body: json.encode(body));

              Navigator.pop(context);
              showDialog(
                  context: context,
                  builder: (BuildContext context2) => TrackHistory());
              //setState(() {});
            },
            icon: Icon(Icons.redo)),
      ],
      content: Container(
        width: 300,
        height: 600,
        child: ListView.builder(
            itemCount: tracks.length,
            itemBuilder: (BuildContext context, int index) {
              final item = tracks[index];
              return Dismissible(
                key: Key(item.id.toString()),
                confirmDismiss: (direction) async {
                  return await showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                                content: Text(
                                    "Sind sie sich sicher, dass  sie den Track von \"" +
                                        tasks
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
                                              deletedTracks.add(item);

                                              getToken().then((x) =>
                                                  client
                                                      .delete(
                                                          deleteTrackUrl(
                                                              item.id),
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
                          tasks
                              .firstWhere((x) => tracks[index].task == x.id)
                              .task,
                          ctasks,
                          tasks),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: ListTile(
                          title: Text(tasks
                              .firstWhere((x) => tracks[index].task == x.id)
                              .name),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  UpdateTrackPopup(
                                title: tasks
                                    .firstWhere(
                                        (x) => tracks[index].task == x.id)
                                    .name,
                                description: tasks
                                    .firstWhere(
                                        (x) => tracks[index].task == x.id)
                                    .description,
                                client: client,
                                taskid: tracks[index].task,
                                first: tracks[index].rating_0,
                                second: tracks[index].rating_1.toInt(),
                                trackid: tracks[index].id,
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
