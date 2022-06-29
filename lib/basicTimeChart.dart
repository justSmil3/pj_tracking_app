import 'package:flutter/material.dart';
import 'package:pj_tracking_app/stat.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class BasicTimeChart extends StatelessWidget {
  final List<Stat> data;
  final String title;
  BasicTimeChart({Key? key, required this.data, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<charts.Series<Stat, DateTime>> series = [
      charts.Series(
          id: "developers",
          data: data,
          domainFn: (Stat stat, _) => DateTime.parse(stat.date),
          measureFn: (Stat stat, _) => stat.score)
    ];

    return IgnorePointer(
      child: SizedBox(
          height: 150,
          child: charts.TimeSeriesChart(
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
