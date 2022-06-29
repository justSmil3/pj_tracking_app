import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:pj_app/Colors.dart';
import 'package:pj_app/basicBarChart.dart';
import 'package:pj_app/basicTimeChart.dart';
import 'package:pj_app/basic_pie_chart.dart';
import 'package:pj_app/dualTimeChart.dart';
import 'package:pj_app/functions.dart';
import 'package:pj_app/stat.dart';
import 'package:pj_app/subtask.dart';
import 'package:pj_app/task.dart';
import 'package:pj_app/variables.dart';
import 'package:provider/provider.dart';
import 'package:pj_app/providers.dart';

class StatsPage extends StatefulWidget {
  final http.Client client;
  final int UserId;
  const StatsPage({Key? key, required this.client, this.UserId = -1})
      : super(key: key);

  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  Map<String, double> ratingMap = {};
  Map<String, double> ratingMap2 = {};
  List<List<String>> ratingMap0 = [];
  List<Subtask> subtasks = [];

  List<Stat> stats = [];
  Map<String, double> tmp = {
    "Sehr Unsicher": 20,
    "Unsicher": 40,
    "Ausreichend Sicher": 10,
    "Sicher": 10,
    "Sehr Sicher": 20
  };

  Map<String, double> tmp2 = {
    "Keine Ausführung": 4,
    "Gemeinsam mit dem Arzt": 3,
    "Unter Beobachtung des Arztes": 4,
    "Eigenständig": 1
  };

  @override
  void initState() {
    CheckTokenStatus(context);
  }

  String Relable(String pre) {
    String month = pre.substring(5, 7);
    String day = pre.substring(8, 10);
    String mon = "";
    switch (int.parse(month)) {
      case 1:
        mon = "Jan";
        break;
      case 2:
        mon = "Feb";
        break;
      case 3:
        mon = "Mar";
        break;
      case 4:
        mon = "Apr";
        break;
      case 5:
        mon = "Mai";
        break;
      case 6:
        mon = "Jun";
        break;
      case 7:
        mon = "Jul";
        break;
      case 8:
        mon = "Aug";
        break;
      case 9:
        mon = "Sep";
        break;
      case 10:
        mon = "Oct";
        break;
      case 11:
        mon = "Nov";
        break;
      case 12:
        mon = "Dec";
        break;
      default:
        mon = month;
        break;
    }
    String datelable = day + " " + mon;
    return datelable;
  }

  void SetValues() {
    if (widget.UserId == -1) {
      retrieveStats().then((x) {
        stats = x;
        stats.forEach((stat) {
          String datelable = Relable(stat.date);
          ratingMap0.addAll([
            [datelable, stat.score.toString()]
          ]);
        });
        setState(() {});
      });
    } else {
      retrieveUserStats(widget.UserId).then((x) {
        stats = x;
        stats.forEach((stat) {
          String datelable = Relable(stat.date);
          ratingMap0.addAll([
            [datelable, stat.score.toString()]
          ]);
        });
        setState(() {});
      });
    }
    GetTrackStats(subtasks, context.read<TrackProvider>().tracks).then((x) {
      ratingMap = x;
      setState(() {});
    });
    GetAveragePercentages(subtasks, context.read<TrackProvider>().tracks)
        .then((x) {
      ratingMap2 = x;
      setState(() {});
    });
  }

// 64095645879691605458
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    subtasks = context.watch<SubtaskProvider>().tasks;
    SetValues();
  }

  @override
  void dispose() {
    if (widget.UserId == -1) initialPageCallback();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BoxDecoration mentorBox = BoxDecoration(
      color: Colors.white,
    );

    BoxDecoration mentiBox = BoxDecoration(color: Colors.grey[300]
        //gradient: LinearGradient(
        //colors: [
        //darkPrimaryColor,
        //lightPrimaryColor,
        //],
        //begin: Alignment.topRight,
        //end: Alignment.topLeft,
        //),
        );

    return Container(
      decoration: widget.UserId >= 0 ? mentorBox : mentiBox,
      child: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.transparent,
              child: BasicBarChart(
                data: ratingMap0,
                title: "Score",
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.transparent,
              child: StatefulPieChart(
                dataMap: ratingMap2,
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.transparent,
              child: StatefulPieChart(
                dataMap: ratingMap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
