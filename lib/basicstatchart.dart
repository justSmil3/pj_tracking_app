import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:pj_app/stat.dart';

class BasicStatChart extends StatelessWidget {
  final List<Stat> data;


  BasicStatChart({required this.data});
  @override
  Widget build(BuildContext context) {
    List<charts.Series<Stat, String>> series = [
      charts.Series(
          id: "developers",
          data: data,
          domainFn: (Stat stat, _) => stat.date,
          measureFn: (Stat stat, _) => stat.score
      )
    ];

    return Container(
      height: 300,
      padding: EdgeInsets.all(25),
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Column(
          children: <Widget>[
            Text(
              "Personal Progress",
            ),
            Expanded(
              child: charts.BarChart(series, animate: true),
            )
          ],
        ),
      ),
    );
  }

}