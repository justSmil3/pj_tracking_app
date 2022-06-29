import 'dart:async';
import 'dart:io';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:pj_tracking_app/Colors.dart';
import 'package:pj_tracking_app/basic_pie_chart.dart';
import 'package:pj_tracking_app/providers.dart';
import 'package:pj_tracking_app/stat.dart';
import 'package:pj_tracking_app/subtask.dart';
import 'package:pj_tracking_app/TaskWeight.dart';
import 'package:pj_tracking_app/variables.dart';
import 'task.dart';
import 'package:pj_tracking_app/urls.dart';
import 'package:pj_tracking_app/trackpage.dart';
import 'dart:convert';
import 'package:pj_tracking_app/functions.dart';
import 'package:pj_tracking_app/trackpopup.dart';
import 'package:pj_tracking_app/auth_service.dart';
import 'package:pj_tracking_app/basicstatchart.dart';
import 'package:pj_tracking_app/track.dart';
import 'package:pj_tracking_app/MentiAppBar.dart';
import 'package:provider/provider.dart';

import 'package:pj_tracking_app/auth_service.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key, required this.controller, required this.secondCon})
      : super(key: key);
  final PageController controller;
  final PageController secondCon;

  @override
  State<MainPage> createState() => _MainPage();
}

class _MainPage extends State<MainPage> {
  http.Client client = http.Client();
  List<Subtask> subtasks = [];
  List<Subtask> unratedSubtasks = [];
  List<Task> tasks = [];
  List<TaskWeight> weights = [];
  List<Subtask> weightedTasks = [];
  List<Stat> stats = [];
  Map<String, double> ratingMap = {};

  double percent = 0.5;
  int averageRating = 3;

  Map<int, String> ratings = {
    1: "Sehr Unsicher",
    2: "Unsicher",
    3: "Ausreichend Sicher",
    4: "Sicher",
    5: "Sehr Sicher",
  };

  final _controller = StreamController<List<Subtask>>();

  @override
  void initState() {
    super.initState();
    MentiAppBar = Text("PJ App");
    SetValues();
    initialPageCallback = () => LandOnPage();
    setState(() {});
    CheckTokenStatus(context);
  }

  void LandOnPage() {
    Future.delayed(Duration.zero, () {
      Widget abbbar = Text("PJ App");
      setAppBar(abbbar);
      SetValues();
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void SetValues() {
    if (!mounted) return;
    subtasks = context.read<SubtaskProvider>().tasks;
    GetTrackStats(subtasks, context.read<TrackProvider>().tracks).then((x) {
      setState(() {});
      GetAverageTrackStats(subtasks, context.read<TrackProvider>().tracks)
          .then((_value) {
        unratedSubtasks = _value.subtasks;
      });
      ratingMap = x;
      setState(() {});

      (() {});
      retrieveWeights(subtasks).then((value) {
        weightedTasks = value;
        weightedTasks.addAll(unratedSubtasks);
        setState(() {});
        _controller.sink.add(weightedTasks);
      });
      retrieveStats().then((X) {
        stats = X;
        setState(() {});
      });
    });
  }

  _setupLists() async {}

  //_retrieveTasks() async {
  //  tasks = [];
  //  http.Response response = ((await client.get(tasksUrl, headers: {HttpHeaders.authorizationHeader: getToken()})));
  //  List res = json.decode(utf8.decode(response.bodyBytes));
  //  res.forEach((element) {
  //    tasks.add(Task.fromMap(element));
  //  });
  //  setState(() {});
  //}

  // TODO research if this cant be done server side

  Function deleteWeight(Subtask task) {
    // TODO this can be done with less server calls
    return (track) {
      retrieveWeights(subtasks, getWeights: true).then((weights) {
        int? idx;
        TaskWeight? w;
        for (int i = 0; i < weights.length; i++) {
          if (weights[i].task == task.id) idx = weights[i].id;
          w = weights[i];
        }

        getToken().then((token) {
          final Map<String, String> body = {
            "track": track.id.toString(),
            "score": w!.weight.toString()
          };
          final Map<String, String> headers = {
            "Content-Type": "application/json",
            HttpHeaders.authorizationHeader: token
          };
          http.Client()
              .post(addWeightsUrl, headers: headers, body: json.encode(body));

          http.delete(DeleteWeightsUrl(idx!),
              headers: {HttpHeaders.authorizationHeader: token});

          SetValues;
          setState(() {});
          //retrieveSubtasks(context).then((value){subtasks = value; setState((){});});
          //retrieveTasks(context).then((value){ tasks = value; setState(() {});((){});
          //retrieveWeights(context, subtasks).then((value){weightedTasks = value; weightedTasks.addAll(unratedSubtasks); setState((){});});});
          //print(weightedTasks);
        });
      });
    };
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    tasks = context.watch<TaskProvider>().tasks;
    subtasks = context.watch<SubtaskProvider>().tasks;
    SetValues();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: ColumnSuper(innerDistance: -20.0, invert: true, children: [
        Container(
            height: 250,
            width: MediaQuery.of(context).size.width - 10,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              //gradient: LinearGradient(
              //  colors: [
              //    lightPrimaryColor,
              //    darkPrimaryColor,
              //  ],
              //  begin: Alignment.bottomLeft,
              //  end: Alignment.bottomRight,
              //),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  offset: Offset(0.0, 4.0), //(x,y)
                  blurRadius: 5.0,
                ),
              ],
            ),
            child: StatefulPieChart(
              dataMap: ratingMap,
            )),
        Container(
          height: MediaQuery.of(context).size.height - 240,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: RefreshIndicator(
            onRefresh: () async {
              SetValues();
            },
            child: Padding(
              padding: EdgeInsets.all(0.0),
              child: StreamBuilder(
                  stream: _controller.stream,
                  builder: (context, snapshot) {
                    return ListView.builder(
                        itemCount: weightedTasks.length,
                        itemBuilder: (BuildContext context, int index) {
                          Widget rv = Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(1.0),
                              ),
                              Center(
                                child: Container(
                                  height: 70,
                                  width:
                                      MediaQuery.of(context).size.width * .98,
                                  child: Card(
                                    color: chooseColor(
                                        weightedTasks[index].task,
                                        tasks,
                                        subtasks),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Center(
                                      child: ListTile(
                                        title: Text(weightedTasks[index].name),
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) =>
                                                TrackPopup(
                                              title: weightedTasks[index].name,
                                              description: weightedTasks[index]
                                                  .description,
                                              taskId: weightedTasks[index].id,
                                              callbacks: [
                                                deleteWeight(
                                                    weightedTasks[index])
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                          Widget result = index == 0
                              ? Column(
                                  children: [
                                    Container(
                                      height: 30,
                                    ),
                                    rv
                                  ],
                                )
                              : rv;
                          return result;
                        });
                  }),
            ),
          ),
        ),
      ]),
    );
  }
}


//CircularPercentIndicator(
//radius: MediaQuery.of(context).size.width / 2.3,
//lineWidth: 13.0,
//percent: percent,
//footer: Text(ratings[averageRating]!),
//center: Text((percent * 100).toInt().toString() + "%",
//style: TextStyle(
//fontSize: 25
//),
//),
//progressColor: lightSecondaryColor,
//circularStrokeCap: CircularStrokeCap.round,
//)