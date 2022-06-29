import 'dart:io';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pj_tracking_app/functions.dart';
import 'package:pj_tracking_app/auth_service.dart';
import 'package:pj_tracking_app/providers.dart';
import 'package:provider/provider.dart';
import 'package:pj_tracking_app/track.dart';
import 'package:pj_tracking_app/urls.dart';
import 'package:collection/collection.dart';
import 'package:pj_tracking_app/subtask.dart';
import 'package:pj_tracking_app/TaskWeight.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class TaskWeightPopup extends StatefulWidget {
  const TaskWeightPopup(
      {Key? key,
      required this.task,
      required this.userId,
      required this.client,
      this.callbacks = const []})
      : super(key: key);

  final Subtask task;
  final http.Client client;
  final int userId;
  final List<Function> callbacks;

  @override
  _TaskWeightPopupState createState() => _TaskWeightPopupState();
}

class _TaskWeightPopupState extends State<TaskWeightPopup> {
  String dropdownValueOne = "Keine Ausführung";
  double rating = 0.0;
  final Map<String, String> dropOptions = {
    "0": "Keine Priorität",
    "1": "Nidrige Priorität",
    "2": "Mittlere Priorität",
    "3": "Hohe Priorität"
  };

  final Map<String, String> menti_do_1 = {
    "0": "Keine Ausführung",
    "1": "Gemeinsam mit dem Arzt",
    "2": "Unter Beobachtung des Arztes",
    "3": "Eigenständig"
  };

  String dropdownValue = "Keine Priorität";

  Color _color = Colors.blue;

  @override
  void initState() {
    super.initState();
    CheckTokenStatus(context);
    retrieveUserTaskWeight(widget.userId, widget.task.id).then((x) {
      if (x == null) return;
      dropdownValue = dropOptions[x.weight.toString()]!;
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();

    Track? currenttrack = context
        .watch<TrackProvider>()
        .tracks
        .firstWhereOrNull((element) => element.task == widget.task.id);
    if (currenttrack == null) return;
    dropdownValueOne = menti_do_1[currenttrack.rating_0.toString()]!;
    rating = currenttrack.rating_1;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ConstrainedBox(
            child: SingleChildScrollView(child: Text(widget.task.description)),
            constraints: BoxConstraints(
              maxHeight: 120,
            ),
          ),
          Container(
            height: 20,
          ),
          // Menti Stats area
          Text(
            "Kompetenzniveau:",
          ),
          TextField(
            enabled: false,
            controller: TextEditingController()..text = dropdownValueOne,
            style: TextStyle(color: Color.fromARGB(255, 156, 156, 156)),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 3, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "sehr unsicher",
                  style: TextStyle(fontSize: 12),
                ),
                Text(
                  "sehr sicher",
                  style: TextStyle(fontSize: 12),
                )
              ],
            ),
          ),
          RatingBar.builder(
            minRating: 1,
            itemCount: 5,
            ignoreGestures: true,
            itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
            initialRating: rating,
            unratedColor: Color.fromARGB(255, 201, 201, 201),
            itemBuilder: (context, _) => Container(
              width: 50,
              height: 50,
              child: Icon(
                Icons.circle,
                color: Color.fromARGB(255, 117, 117, 117),
              ),
            ),
            onRatingUpdate: (_rating) {
              setState(() {
                rating = _rating;
                //_color = dropdownValueOne == "Keine Ausführung" ?
                //  Colors.grey : rating == 0 ?
                //    Colors.grey : Colors.blue;
              });
            },
          ),
          // end Menti stats area
          Container(
            height: 10,
          ),
          DropdownButton<String>(
            itemHeight: 70,
            isExpanded: true,
            value: dropdownValue,
            icon: const Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            style: const TextStyle(color: Colors.deepPurple),
            underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
            ),
            onChanged: (String? newValue) {
              setState(() {
                dropdownValue = newValue!;
                //_color = newValue == "Keine Priorität" ?
                //Colors.grey : Colors.blue;
              });
            },
            items: dropOptions.values
                .toList()
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, overflow: TextOverflow.visible),
              );
            }).toList(),
          ),
        ],
      ),
      actions: <Widget>[
        Center(
          child: Container(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(primary: _color),
              onPressed: () {
                //if (dropdownValue == "Keine Priorität") {
                //  return;
                //}
                getToken().then((token) {
                  final Map<String, String> headers = {
                    "Content-Type": "application/json",
                    HttpHeaders.authorizationHeader: token
                  };
                  final Map<String, String> body = {
                    "weight": dropOptions.keys
                        .firstWhere((x) => dropOptions[x] == dropdownValue),
                    "task": widget.task.id.toString(),
                    "user": widget.userId.toString()
                  };

                  widget.client
                      .post(createTaskWeightUrl,
                          headers: headers, body: json.encode(body))
                      .then((value) {
                    TaskWeight res = TaskWeight.fromMap(
                        json.decode(utf8.decode(value.bodyBytes)));

                    if (widget.callbacks.isNotEmpty) {
                      retrieveSubtasks().then((subtasks) {
                        Iterable<Subtask> stl = subtasks;
                        widget.callbacks.forEach((x) {
                          x(res);
                        });
                      });
                    }
                  });

                  Navigator.of(context).pop();
                });
              },
              child: Container(
                child: Center(child: Text("Eintragen")),
                height: 40,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
