import 'dart:async';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:pj_app/Colors.dart';

class BasicPieChart extends StatelessWidget {
  final Map<String, double> dataMap;
  const BasicPieChart({Key? key, required this.dataMap}): super(key: key);
  @override
  Widget build(BuildContext context) {
    return PieChart(dataMap: dataMap);
  }
}

class StatefulPieChart extends StatefulWidget {

  final Map<String, double> dataMap;

  const StatefulPieChart({Key? key, required this.dataMap}): super(key: key);

  @override
  _StatefulPieChartState createState() => _StatefulPieChartState();
}

class _StatefulPieChartState extends State<StatefulPieChart> {
  final _controller = StreamController<Map<String, double>>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _controller.stream,
        builder: (context, snapshot) {
          if (widget.dataMap.isEmpty) {
            /*return Center(
              child: CircularProgressIndicator(

                color: Colors.redAccent,
                backgroundColor: Colors.blueGrey,
                strokeWidth: 12,
              ),
            );*/
            return Container();
          }
          else {
            return PieChart(
                dataMap: widget.dataMap,
                colorList: secondaryShaddow,
                legendOptions: LegendOptions(
                  showLegendsInRow: false,
                  legendPosition: LegendPosition.right,
                  showLegends: true,
                  legendShape: BoxShape.circle,
                  legendTextStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                chartValuesOptions: ChartValuesOptions(
                  showChartValueBackground: false,
                  showChartValues: true,
                  showChartValuesInPercentage: true,
                  showChartValuesOutside: false,
                  decimalPlaces: 0,
                  chartValueStyle: TextStyle(
                    color: Colors.white,
                  )
              ),
            );
          }
        }
    );
  }
}
