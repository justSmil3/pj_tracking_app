import 'package:flutter/material.dart';
import 'package:pj_tracking_app/stat.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class BasicBarChart extends StatelessWidget {
  final List<List<String>> data;
  final String title;

  BasicBarChart({required this.data, this.title = ""});
  @override
  Widget build(BuildContext context) {
    List<charts.Series<List<String>, String>> series = [
      charts.Series(
          id: "developers",
          data: data,
          domainFn: (List<String> date, _) => date[0],
          measureFn: (List<String> date, _) => int.parse(date[1]),
          colorFn: (_, __) => charts.ColorUtil.fromDartColor(Color(0xff9D8DF1)))
    ];

    return IgnorePointer(
      child: SizedBox(
          height: 150,
          child: charts.BarChart(
            series,
            animate: true,
            behaviors: [
              charts.ChartTitle(
                title,
                behaviorPosition: charts.BehaviorPosition.top,
                titleOutsideJustification: charts.OutsideJustification.start,
                innerPadding: 18,
              ),
            ],
          )),
    );
  }
}
