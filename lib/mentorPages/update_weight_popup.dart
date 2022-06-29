import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pj_app/TaskWeight.dart';
import 'package:pj_app/subtask.dart';
import 'package:pj_app/urls.dart';
import 'package:pj_app/auth_service.dart';
import 'package:http/http.dart' as http;

class UpdateWeightPopup extends StatefulWidget {
  const UpdateWeightPopup({Key? key, required this.weight, required this.task}) : super(key: key);
  final TaskWeight weight;
  final Subtask task;

  @override
  _UpdateWeightPopupState createState() => _UpdateWeightPopupState();
}

class _UpdateWeightPopupState extends State<UpdateWeightPopup> {

  final Map<String, String> dropOptions = {
    "0": "Keine Priorität",
    "1": "Nidrige Priorität",
    "2": "Mittlere Priorität",
    "3": "Hohe Priorität"
  };

  final weightController = TextEditingController();
  Color _color = Colors.blue;
  int UserId = 0;
  String dropdownValue = "Keine Priorität";

  @override
  void initState(){
    UserId = widget.weight.user;
    weightController.text = widget.weight.weight.toString();
    setState((){});
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
              maxHeight: 170,
            ),
          ),
          Container(
            height: 15,
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
                _color = newValue == "Keine Priorität" ?
                Colors.grey : Colors.blue;
              });
            },
            items: dropOptions.values.toList()
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
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: [

                TextButton(
                  onPressed: (){
                    getToken().then((x) => http.Client().delete(
                        DeleteWeightsUrl(widget.weight.id), headers: {HttpHeaders.authorizationHeader: x}));

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
                  style: TextButton.styleFrom(
                    primary: _color,
                  ),
                  onPressed: () {
                    if (dropdownValue == "Keine Priorität") {
                      return;
                    }
                    getToken().then((x){
                      final Map<String, String> headers = {
                        "Content-Type" : "application/json",
                        HttpHeaders.authorizationHeader: x};
                      final Map<String, String> body = {
                        "weight": dropOptions.keys.firstWhere((
                                    x) => dropOptions[x] == dropdownValue),
                        "task": widget.task.id.toString(),
                        "user": UserId.toString()
                      };
                      http.Client().put(
                          updateWeightUrl(widget.weight.id),
                          headers: headers,
                          body: json.encode(body)
                      );
                    });
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: Text("Save"),
                ),
              ]
          ),
        ),
      ],
    );
  }
}
