import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pj_app/Colors.dart';
import 'package:pj_app/basicBarChart.dart';
import 'package:pj_app/basic_pie_chart.dart';
import 'package:pj_app/mentorPages/menti.dart';
import 'package:pj_app/functions.dart';
import 'package:pj_app/providers.dart';
import 'package:pj_app/stat.dart';
import 'package:provider/provider.dart';

class statobject {
  final int mentiID;
  final Map<String, double> stats;
  const statobject(this.mentiID, this.stats);
}

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  List<Menti> menti = [];
  List<statobject> stats = [];
  Map<int, int> unreadMessages = {};
  final _controller = StreamController<List<statobject>>();

  Widget UnreadMessagesDisplay(mentiID) {
    int? count = unreadMessages[mentiID];
    if (count != null && count > 0) {
      return Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.redAccent,
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: TextStyle(color: Colors.white),
            ),
          ));
    }
    return Container();
  }

  void _setValues() {
    retrieveMenti().then((x) {
      menti = x;
      stats.clear();
      retrieveSubtasks().then((y) {
        for (int i = 0; i < menti.length; i++) {
          retrieveUnreadMessagesCount(menti[i].user).then((count) {
            unreadMessages.addAll({menti[i].user: count});
            retrieveTracks(user: menti[i].user).then((_tracks) {
              GetTrackStats(y, _tracks).then((y) {
                statobject res = new statobject(menti[i].user, y);
                stats.add(res);
                setState(() {});
                _controller.sink.add(stats);
              });
            });
          });
        }
      });
    });
    CheckTokenStatus(context);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _setValues();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 5,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/'),
            color: Colors.black,
            icon: Icon(Icons.logout),
          ),
        ],
        title: Text(
          'PJ APP Mentor HUB',
          style: TextStyle(color: Colors.black),
        ),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _setValues();
        },
        child: StreamBuilder(
            stream: _controller.stream,
            builder: (context, snapshot) {
              if (stats.length < menti.length) {
                return Center(
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      backgroundColor: Colors.blueGrey,
                      strokeWidth: 12,
                    ),
                  ),
                );
              }
              return ListView.builder(
                itemCount: menti.length,
                itemBuilder: (BuildContext context, int index) {
                  return Center(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(10.0),
                          ),
                          GestureDetector(
                            child: Card(
                              elevation: 0,
                              color: Colors.black26,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child: Container(
                                child: Column(
                                  children: [
                                    Container(
                                      height: 10,
                                    ),
                                    Row(children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .08,
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .8,
                                        child: Text(
                                          menti[index].name,
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ),
                                      UnreadMessagesDisplay(menti[index].user)
                                    ]),
                                    Container(
                                      width: 350,
                                      child: StatefulPieChart(
                                          dataMap: stats
                                              .firstWhere((x) =>
                                                  x.mentiID ==
                                                  menti[index].user)
                                              .stats),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                  '/mentorMentiPage',
                                  arguments: menti[index]);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
      ),
    );
  }
}
