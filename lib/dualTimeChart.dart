import 'package:flutter/material.dart';
import 'package:pj_app/stat.dart';
import 'package:pj_app/track.dart';
import 'package:pj_app/auth_service.dart';
import 'package:pj_app/functions.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class DualTimeChart extends StatefulWidget {
  final String title;
  const DualTimeChart({Key? key, required this.title}) : super(key: key);

  @override
  _DualTimeChartState createState() => _DualTimeChartState();
}

class _DualTimeChartState extends State<DualTimeChart> {
  List<int> wStatsScore = [];
  List<int> uStatsScore = [];
  List<Stat> wStats = [];
  List<Stat> uStats = [];

  @override
  void initState() {
    super.initState();
    retrieveWStats().then((x) {
      wStats = x;
      setState(() {});
    });
    retrieveUStats().then((x) {
      uStats = x;
      setState(() {});
    });

    /// TODO somehow w and u stats are swapped, chnaging lable will do it for now however maybe
    /// I should consider changing this on the server sometimg
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    charts.Series<Stat, DateTime> series1 = charts.Series(
        id: "Unpriorisierte Aufgaben",
        data: wStats,
        domainFn: (Stat stat, _) => DateTime.parse(stat.date),
        measureFn: (Stat stat, _) => stat.score);

    charts.Series<Stat, DateTime> series2 = charts.Series(
        id: "Priorisierte Aufgaben",
        data: uStats,
        domainFn: (Stat stat, _) => DateTime.parse(stat.date),
        measureFn: (Stat stat, _) => stat.score);

    List<charts.Series<Stat, DateTime>> series = [series1, series2];
    return IgnorePointer(
      child: SizedBox(
          height: 150,
          child: charts.TimeSeriesChart(
            series,
            animate: true,
            behaviors: [
              charts.SeriesLegend(
                position: charts.BehaviorPosition.bottom,
              ),
              charts.ChartTitle(
                widget.title,
                behaviorPosition: charts.BehaviorPosition.top,
                titleOutsideJustification: charts.OutsideJustification.start,
                innerPadding: 18,
              ),
            ],
          )),
    );
  }
}
