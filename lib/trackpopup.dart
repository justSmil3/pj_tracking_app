import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:pj_app/auth_service.dart';
import 'package:pj_app/functions.dart';
import 'package:pj_app/providers.dart';
import 'package:pj_app/subtask.dart';
import 'package:pj_app/urls.dart';
import 'package:pj_app/track.dart';
import 'package:provider/provider.dart';

class TrackPopup extends StatefulWidget {
  const TrackPopup(
      {Key? key,
      required this.title,
      required this.description,
      required this.taskId,
      this.callbacks = const []})
      : super(key: key);

  final String title;
  final String description;
  final int taskId;
  final List<Function> callbacks;

  @override
  _TrackPopupState createState() => _TrackPopupState();
}

class _TrackPopupState extends State<TrackPopup> {
  String dropdownValueOne = "Keine Ausführung";
  double rating = 0;
  Color _color = Colors.blue;
  final client = http.Client();

  final Map<String, String> dropOptions = {
    "0": "Keine Ausführung",
    "1": "Gemeinsam mit dem Arzt",
    "2": "Unter Beobachtung des Arztes",
    "3": "Eigenständig"
  };

  @override
  void initState() {
    super.initState();
    CheckTokenStatus(context);
    retrieveTaskTrack(widget.taskId).then((x) {
      if (x == null) return;
      dropdownValueOne = dropOptions[x.rating_0.toString()]!;
      rating = x.rating_1;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ConstrainedBox(
            child: SingleChildScrollView(
                child: Text(
              widget.description,
              style: TextStyle(color: Colors.black54),
            )),
            constraints: BoxConstraints(
              maxHeight: 120,
            ),
          ),
          Container(
            height: 10,
          ),
          Text(
            "Kompetenzniveau",
          ),
          DropdownButton<String>(
            itemHeight: 70,
            isExpanded: true,
            value: dropdownValueOne,
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
                dropdownValueOne = newValue!;
                //_color = newValue == "Keine Ausführung" ?
                //  Colors.grey : rating == 0 ?
                //    Colors.grey : Colors.blue;
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
            itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
            initialRating: rating,
            itemBuilder: (context, _) => Container(
              width: 50,
              height: 50,
              child: Icon(
                Icons.circle,
                color: Colors.blueAccent,
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
        ],
      ),
      actions: <Widget>[
        Center(
          child: Container(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(primary: _color),
              onPressed: () {
                //if(dropdownValueOne == "Keine Ausführung" || rating == 0)
                //  return;
                getToken().then((token) {
                  final Map<String, String> headers = {
                    "Content-Type": "application/json",
                    HttpHeaders.authorizationHeader: token
                  };
                  final String task = widget.title;
                  final String rating_0 = dropOptions.keys
                      .firstWhere((x) => dropOptions[x] == dropdownValueOne);
                  final String rating_1 = rating.toString();
                  final Map<String, String> body = {
                    "task": task,
                    "rating_0": rating_0,
                    "rating_1": rating_1,
                  };

                  client
                      .post(createTrackUrl,
                          headers: headers, body: json.encode(body))
                      .then((value) {
                    Track res = Track.fromMap(
                        json.decode(utf8.decode(value.bodyBytes)));
                    print(res);
                    print(res);

                    if (widget.callbacks.isNotEmpty) {
                      retrieveSubtasks().then((subtasks) {
                        Iterable<Subtask> stl = subtasks;
                        Subtask currentSubtask =
                            stl.firstWhere((x) => x.name == task);
                        widget.callbacks.forEach((x) {
                          x(res);
                        });
                      });
                    }
                  });

                  Navigator.of(context).pop();
                  context.read<SubtaskProvider>().LoadSubtasks();
                  context.read<TrackProvider>().LoadTracks();
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
