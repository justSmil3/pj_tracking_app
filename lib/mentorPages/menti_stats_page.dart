// import 'package:flutter/material.dart';
// import 'package:pj_tracking_app/basicBarChart.dart';
// import 'package:pj_tracking_app/basicTimeChart.dart';
// import 'package:pj_tracking_app/functions.dart';
// import 'package:pj_tracking_app/mentorPages/dual_time_chart.dart';
// import 'package:pj_tracking_app/stat.dart';

// class MentiStatsPage extends StatefulWidget {
//   const MentiStatsPage(
//       {Key? key,
//       required this.pageController,
//       required this.UserId,
//       required this.title})
//       : super(key: key);
//   final PageController pageController;
//   final int UserId;
//   final String title;

//   @override
//   _MentiStatsPageState createState() => _MentiStatsPageState();
// }

// class _MentiStatsPageState extends State<MentiStatsPage> {
//   List<Stat> stats = [];

//   @override
//   void initState() {
//     retrieveUserStats(widget.UserId).then((x) {
//       stats = x;
//       setState(() {});
//     });
//     CheckTokenStatus(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: Text(widget.title),
//       ),
//       bottomNavigationBar: BottomAppBar(
//         elevation: 8,
//         shape: CircularNotchedRectangle(),
//         child: Container(
//           height: 45,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               IconButton(
//                 icon: Icon(Icons.note_add),
//                 onPressed: () {
//                   widget.pageController.jumpToPage(0);
//                 },
//               ),
//               Container(
//                 width: 80,
//                 height: 40,
//                 child: Card(
//                   color: Colors.black12,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20)),
//                   child: Icon(Icons.query_stats),
//                 ),
//               ),
//               IconButton(
//                 icon: Icon(Icons.question_answer),
//                 onPressed: () {
//                   widget.pageController.jumpToPage(2);
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Container(
//               color: Colors.white,
//               child: BasicBarChart(
//                 data: stats,
//                 title: "Score",
//               ),
//             ),
//           ),
//           Expanded(
//             child: Container(
//               color: Colors.white,
//               child: BasicTimeChart(
//                 data: stats,
//                 title: "Verlauf",
//               ),
//             ),
//           ),
//           Expanded(
//             child: Container(
//               color: Colors.white,
//               child: DualUserTimeChart(
//                 UserId: widget.UserId,
//                 title: "Priorisierung vs Normal",
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
