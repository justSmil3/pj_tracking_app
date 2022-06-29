import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:pj_tracking_app/urls.dart';
import 'package:pj_tracking_app/auth_service.dart';

///Todo redo button on trackhistory does not work in here <- solution for this would prob be to create a new
///model for the deleted tracks but thats something to do for when user and user authentification are working

class UpdateTrackPopup extends StatefulWidget {
  const UpdateTrackPopup({
    Key? key,
    required this.title,
    required this.description,
    required this.client,
    required this.taskid,
    required this.trackid,
    required this.first,
    required this.second,
  }) : super(key: key);

  final String title;
  final int taskid;
  final String description;
  final http.Client client;
  final String first;
  final int second;
  final int trackid;

  @override
  _UpdateTrackPopupState createState() => _UpdateTrackPopupState();
}

class _UpdateTrackPopupState extends State<UpdateTrackPopup> {
  String dropdownValueOne = "Keine Ausführung";
  String UserSecurity = "";
  int currentRating = 1;

  final Map<String, String> userSecurityStates = {
    "1": "sehr unsicher",
    "2": "unsicher",
    "3": "mäßig",
    "4": "sicher",
    "5": "sehr sicher"
  };

  @override
  void initState() {
    // TODO: implement initState
    int rating = widget.second;
    if (widget.first != "")
      dropdownValueOne = dropOptions[widget.first].toString();
    if (widget.second == 0 || widget.second > 5) rating = 3;
    UserSecurity = userSecurityStates[rating.toString()].toString();
    currentRating = rating;
    setState(() {});
    super.initState();
  }

  final Map<String, String> dropOptions = {
    "0": "Keine Ausführung",
    "1": "Gemeinsam mit dem Arzt",
    "2": "Unter Beobachtung des Arztes",
    "3": "Eigenständig"
  };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ConstrainedBox(
            child: SingleChildScrollView(child: Text(widget.description)),
            constraints: BoxConstraints(
              maxHeight: 170,
            ),
          ),
          Container(
            height: 15,
          ),
          Text("Kompetenzniveau"),
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
          Text(UserSecurity),
          Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
          RatingBar.builder(
            minRating: 1,
            initialRating: currentRating.toDouble(),
            maxRating: 5,
            itemCount: 5,
            itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
            itemBuilder: (context, _) => Container(
              width: 50,
              height: 50,
              child: Icon(
                Icons.circle,
                color: Colors.blueAccent,
              ),
            ),
            onRatingUpdate: (rating) {
              setState(() {
                currentRating = rating.toInt();
                UserSecurity =
                    userSecurityStates[rating.toInt().toString()].toString();
              });
            },
          ),
        ],
      ),
      actions: <Widget>[
        Center(
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            TextButton(
              onPressed: () {
                getToken().then((x) => widget.client.delete(
                    deleteTrackUrl(widget.trackid),
                    headers: {HttpHeaders.authorizationHeader: x}));

                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text(
                "Delete",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                //Todo implement api push here
                getToken().then((x) {
                  final Map<String, String> headers = {
                    "Content-Type": "application/json",
                    HttpHeaders.authorizationHeader: x
                  };
                  final String task = widget.taskid.toString();
                  final String rating_0 = dropOptions.keys
                      .firstWhere((x) => dropOptions[x] == dropdownValueOne);
                  final String rating_1 = currentRating.toString();
                  final Map<String, String> body = {
                    "task": task,
                    "rating_0": rating_0,
                    "rating_1": rating_1
                  };
                  widget.client.put(updateTrackUrl(widget.trackid),
                      headers: headers, body: json.encode(body));
                });
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text("Save"),
            ),
          ]),
        ),
      ],
    );
  }
}
