import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pj_tracking_app/Message.dart';
import 'package:pj_tracking_app/TaskWeight.dart';
import 'package:pj_tracking_app/auth_service.dart';
import 'package:pj_tracking_app/loginpage.dart';
import 'package:pj_tracking_app/mentorPages/menti.dart';
import 'package:pj_tracking_app/providers.dart';
import 'package:pj_tracking_app/task.dart';
import 'package:pj_tracking_app/subtask.dart';
import 'package:http/http.dart' as http;
import 'package:pj_tracking_app/track.dart';
import 'package:pj_tracking_app/stat.dart';
import 'dart:convert';

import 'package:pj_tracking_app/urls.dart';
import 'package:pj_tracking_app/variables.dart';
import 'package:pj_tracking_app/Colors.dart';

Future<bool> Function() popScopeCallback = () => Future.value(false);

Color chooseColor(int taskid, List<Task> ctasks, List<Subtask> tasks) {
  if (ctasks.isEmpty) return Color.fromARGB(0, 0, 0, 0);
  Task task = ctasks.firstWhere((x) => x.id == taskid);
  Color result = Color.fromARGB(100, 122, 127, 204);
  if (task.name ==
          "Amnese, Untersuchung" || // TODO there is a typo, its not Amnese but Anamnese typo is in the database
      task.name == "Diagnostik-Planung" ||
      task.name == "Auswertung Diagnostik" ||
      task.name == "Therapieplanung") {
    //result = Color.fromARGB(255, 191, 195, 255); // was 100 before
    result = secondaryShaddow[0];
  } else if (task.name == "Ärztliche Prozeduren") {
    //result = Color.fromARGB(255, 255, 220, 204);
    result = secondaryShaddow[1];
  } else if (task.name == "Aufklärungsgespräche" ||
      task.name == "Patientengespräch") {
    //result = Color.fromARGB(255, 178, 223, 255);
    result = secondaryShaddow[2];
  } else if (task.name == "Patientenvorstellung" ||
      task.name == "Übergabe" ||
      task.name == "Arztbrief") {
    //result = Color.fromARGB(255, 255, 234, 135);
    result = secondaryShaddow[3];
  } else if (task.name == "Soforthilfe und Notruf") {
    //result = Color.fromARGB(255, 166, 255, 244);
    result = secondaryShaddow[4];
  }
  return result;
}

void CheckTokenStatus(BuildContext context) async {
  String token = await getToken();
  if (token == "logout") {
    Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage()));
  }
}

Future retrieveTasks() async {
  List<Task> tasks = [];
  String token = await getToken();
  http.Response response = ((await http.Client().get(tasksUrl, headers: {
    HttpHeaders.authorizationHeader: token
  }))); //Todo write urls file
  List res = json.decode(utf8.decode(response.bodyBytes));
  res.forEach((element) {
    tasks.add(Task.fromMap(element));
  });
  return tasks;
}

Future retrieveSubtasks({int mentiId = -1}) async {
  List<Subtask> subtasks = [];
  String token = await getToken();
  Uri url = mentiId == -1 ? subtasksUrl : mentiSubtaskUrl(mentiId);
  http.Response response = ((await http.Client()
      .get(url, headers: {HttpHeaders.authorizationHeader: token})));
  List res = json.decode(utf8.decode(response.bodyBytes));
  res.forEach((element) {
    subtasks.add(Subtask.fromMap(element));
  });
  return subtasks;
}

Future retrieveSortetSubtasks() async {
  List<Subtask> subtasks = [];
  String token = await getToken();
  http.Response response = ((await http.Client().get(SubtaskOrderedByTaskUrl,
      headers: {HttpHeaders.authorizationHeader: token})));
  List res = json.decode(utf8.decode(response.bodyBytes));
  res.forEach((element) {
    subtasks.add(Subtask.fromMap(element));
  });
  return subtasks;
}

Future retrieveTracks({user = -1}) async {
  List<Track> tracks = [];
  String token = await getToken();
  Uri url = user == -1 ? tracksUrl : mentiTrackUrl(user);
  http.Response response = ((await http
      .get(url, headers: {HttpHeaders.authorizationHeader: token})));
  List res = json.decode(utf8.decode(response.bodyBytes));
  res.forEach((element) {
    tracks.add(Track.fromMap(element));
  });
  return tracks;
}

class ATS {
  Map<String, double> values;
  List<Subtask> subtasks;
  ATS(this.values, this.subtasks);
}

class TrackFiles {
  List<Track> tracks;
  List<int> TracksOnSubtasks;
  List<Subtask> unratedSubtasks;
  TrackFiles(this.tracks, this.TracksOnSubtasks, this.unratedSubtasks);
}

Future _GetTrackAnalysis(List<Subtask> subtasks, List<Track> _tracks) async {
  List<Track> tracks = [];
  List<int> TracksOnSubtasks = [];
  List<Subtask> unratedSubtasks = [];
  List<Subtask> ratedSubtasks = [];
  _tracks.forEach((_track) {
    if (TracksOnSubtasks.contains(_track.task)) {
      Track tmp_track = tracks.firstWhere((x) => x.task == _track.task);
      int newr0 = int.parse(_track.rating_0);
      int oldr0 = int.parse(tmp_track.rating_0);
      if (oldr0 < newr0) {
        tracks.remove(tmp_track);
        tracks.add(_track);
      } else if (oldr0 == newr0) {
        int oldr1 = tmp_track.rating_1.toInt();
        int newr1 = _track.rating_1.toInt();
        if (newr1 > oldr1) {
          tracks.remove(tmp_track);
          tracks.add(_track);
        }
      }
    } else {
      TracksOnSubtasks.add(_track.task);
      tracks.add(_track);
    }
  });

  unratedSubtasks.clear();
  subtasks.forEach((st) {
    if (!TracksOnSubtasks.contains(st.id))
      unratedSubtasks.add(st);
    else
      ratedSubtasks.add(st);
  });
  unratedSubtasks.addAll(ratedSubtasks);
  TrackFiles file = TrackFiles(tracks, TracksOnSubtasks, unratedSubtasks);
  return file;
}

Future retrieveTrackedSubtasks(List<Subtask> subtasks,
    {int userID = -1}) async {
  List<Subtask> alreadyTrackedSubtasks = [];
  if (subtasks.length <= 0) return alreadyTrackedSubtasks;
  List<Track> tracks = [];
  String token = await getToken();
  Uri url = userID == -1 ? tracksUrl : mentiTrackUrl(userID);
  http.Response response = ((await http
      .get(url, headers: {HttpHeaders.authorizationHeader: token})));
  List res = json.decode(utf8.decode(response.bodyBytes));
  res.forEach((element) {
    Track _track = Track.fromMap(element);
    if (_track.rating_0 != "0" && _track.rating_1 != 0.0)
      alreadyTrackedSubtasks
          .add(subtasks.firstWhere((x) => _track.task == x.id));
  });
  return alreadyTrackedSubtasks;
}

Future GetTrackStats(List<Subtask> subtasks, List<Track> _tracks) async {
  TrackFiles file = await _GetTrackAnalysis(subtasks, _tracks);

  List<Track> tracks = file.tracks;
  List<int> TracksOnSubtasks = file.TracksOnSubtasks;
  List<Subtask> unratedSubtasks = file.unratedSubtasks;

  // the notdone is only nessesary due to migragtion between tracking options that allowed previous
  // tracks to be done without performing the actual task
  double notdone = 0;
  double gemeinsam = 0;
  double beobachtung = 0;
  double eigen = 0;

  tracks.forEach((x) {
    String rating = x.rating_0;
    if (rating == "0")
      notdone++;
    else if (rating == "1")
      gemeinsam++;
    else if (rating == "2")
      beobachtung++;
    else if (rating == "3") eigen++;
  });

  Map<String, double> trackStats = {
    "Keine Ausführung": unratedSubtasks.length.toDouble() + notdone,
    "Gemeinsam mit dem Arzt": gemeinsam,
    "Unter Beobachtung des Arztes": beobachtung,
    "Eigenständig": eigen
  };

  return trackStats;
}

Future GetAveragePercentages(
    List<Subtask> subtasks, List<Track> _tracks) async {
  TrackFiles file = await _GetTrackAnalysis(subtasks, _tracks);
  List<Track> tracks = file.tracks;
  List<int> TracksOnSubtasks = file.TracksOnSubtasks;
  List<Subtask> unratedSubtasks = file.unratedSubtasks;
  double sehr_unsicher = 0;
  double unsicher = 0;
  double ausreichend = 0;
  double sicher = 0;
  double sehr_sicher = 0;

  tracks.forEach((track) {
    if (track.rating_0 == "0") return;
    double rating = track.rating_1;
    if (rating == 1.0) {
      sehr_unsicher += 1;
    } else if (rating == 2.0) {
      unsicher += 1;
    } else if (rating == 3.0) {
      ausreichend += 1;
    } else if (rating == 4.0) {
      sicher += 1;
    } else if (rating == 5.0) {
      sehr_sicher += 1;
    }
  });

  Map<String, double> returnMap = {
    "Sehr Unsicher": sehr_unsicher,
    "Unsicher": unsicher,
    "Ausreichend Sicher": ausreichend,
    "Sicher": sicher,
    "Sehr Sicher": sehr_sicher
  };

  return returnMap;
}

Future GetAverageTrackStats(List<Subtask> subtasks, List<Track> _tracks) async {
  TrackFiles file = await _GetTrackAnalysis(subtasks, _tracks);
  List<Track> tracks = file.tracks;
  List<int> TracksOnSubtasks = file.TracksOnSubtasks;
  List<Subtask> unratedSubtasks = file.unratedSubtasks;
  int addedRating = 0;
  tracks.forEach((track) {
    addedRating += track.rating_1.toInt();
  });
  double averageRating = (addedRating / tracks.length);
  double percent = tracks.length / subtasks.length;

  Map<String, double> returnMap = {
    "average": averageRating,
    "percent": percent
  };
  ATS returns = new ATS(returnMap, unratedSubtasks);
  return returns;
}

Future retrieveWeights(List<Subtask> subtasks,
    {bool getWeights = false}) async {
  List<TaskWeight> weights = [];
  List<Subtask> weightedTasks = [];
  String token = await getToken();
  http.Response response = ((await http.Client().get(CountedWeightsUrl(3),
      headers: {HttpHeaders.authorizationHeader: token})));

  var res = json.decode(utf8.decode(response.bodyBytes));

  if (!(res is List)) return;

  res.forEach((element) {
    weights.add(TaskWeight.fromMap(element));
  });

  // TODO make a null check
  if (subtasks.isNotEmpty) {
    weights.forEach((element) {
      Subtask task = subtasks.firstWhere((x) => x.id == element.task);
      weightedTasks.add(task);
    });
  } else {
    List<Subtask> st;
    retrieveSubtasks().then((x) {
      st = x;
      weights.forEach((element) {
        Subtask task = st.firstWhere((x) => x.id == element.task);
        weightedTasks.add(task);
      });
    });
  }

  // TODO fix this, returning two different types in one functino is just ugly
  // but it will do for now
  if (!getWeights)
    return weightedTasks;
  else
    return weights;
}

int counttimes = 0;
Future retrieveStats() async {
  counttimes += 1;
  print(counttimes);
  List<Stat> stats = [];
  String token = await getToken();
  http.Response response = ((await http.get(CountedStatsUrl(5),
      headers: {HttpHeaders.authorizationHeader: token})));
  List res = json.decode(utf8.decode(response.bodyBytes));
  res.forEach((element) {
    stats.add(Stat.fromMap(element));
  });
  return stats;
}

Future retrieveWStats() async {
  List<Stat> stats = [];
  String token = await getToken();
  http.Response response = ((await http.get(CountedWStatsUrl(5),
      headers: {HttpHeaders.authorizationHeader: token})));
  List res = json.decode(utf8.decode(response.bodyBytes));
  if (res.isEmpty) return stats;
  res.forEach((element) {
    stats.add(Stat.fromMap(element));
  });
  return stats;
}

Future retrieveUStats() async {
  List<Stat> stats = [];
  String token = await getToken();
  http.Response response = ((await http.get(CountedUStatsUrl(5),
      headers: {HttpHeaders.authorizationHeader: token})));
  List res = json.decode(utf8.decode(response.bodyBytes));
  res.forEach((element) {
    stats.add(Stat.fromMap(element));
  });
  return stats;
}

Future retrieveMenti() async {
  List<Menti> menti = [];
  String token = await getToken();
  http.Response response = await http
      .get(mentiUrl, headers: {HttpHeaders.authorizationHeader: token});
  List res = json.decode(utf8.decode(response.bodyBytes));
  res.forEach((element) {
    menti.add(Menti.fromMap(element));
  });
  return menti;
}

Future retrieveUserStats(int UserId) async {
  List<Stat> stats = [];
  String token = await getToken();
  http.Response response = ((await http.get(CountedUserStatsUrl(UserId, 5),
      headers: {HttpHeaders.authorizationHeader: token})));
  List res = json.decode(utf8.decode(response.bodyBytes));
  res.forEach((element) {
    stats.add(Stat.fromMap(element));
  });
  return stats;
}

Future retrieveWUserStats(int UserId) async {
  List<Stat> stats = [];
  String token = await getToken();
  http.Response response = ((await http.get(CountedWUserStatsUrl(UserId, 5),
      headers: {HttpHeaders.authorizationHeader: token})));
  List res = json.decode(utf8.decode(response.bodyBytes));
  res.forEach((element) {
    stats.add(Stat.fromMap(element));
  });
  return stats;
}

Future retrieveUUserStats(int UserId) async {
  List<Stat> stats = [];
  String token = await getToken();
  http.Response response = ((await http.get(CountedUUserStatsUrl(UserId, 5),
      headers: {HttpHeaders.authorizationHeader: token})));
  List res = json.decode(utf8.decode(response.bodyBytes));
  res.forEach((element) {
    stats.add(Stat.fromMap(element));
  });
  return stats;
}

Future retrieveUserWeights(List<Subtask> subtasks, int UserId) async {
  List<TaskWeight> weights = [];
  String token = await getToken();
  http.Response response = ((await http.Client().get(WeightsOfUserUrl(UserId),
      headers: {HttpHeaders.authorizationHeader: token})));

  var res = json.decode(utf8.decode(response.bodyBytes));

  if (!(res is List)) return;

  res.forEach((element) {
    weights.add(TaskWeight.fromMap(element));
  });

  return weights;
}

Future retrieveUserTaskWeight(int UserId, int TaskId) async {
  TaskWeight weight;
  String token = await getToken();
  http.Response response = ((await http.Client().get(
      WeightsOfUserByTaskUrl(UserId, TaskId),
      headers: {HttpHeaders.authorizationHeader: token})));

  var res = json.decode(utf8.decode(response.bodyBytes));

  if (res['error'] != null) return null;

  weight = TaskWeight.fromMap(res);

  return weight;
}

Future retrieveTaskTrack(int TaskId) async {
  Track track;
  String token = await getToken();
  http.Response response = ((await http.Client().get(trackByTaskUrl(TaskId),
      headers: {HttpHeaders.authorizationHeader: token})));

  var res = json.decode(utf8.decode(response.bodyBytes));

  if (res['error'] != null) return null;

  track = Track.fromMap(res);

  return track;
}

Future retrieveMessages(int start, int count, [int mentiId = -1]) async {
  List<TextMessage> messages = [];

  String token =
      await getToken(); // I Just hope i get away with not checking for a token in here

  Uri url = mentiId == -1
      ? GetMessages(start, count)
      : GetMentiMessages(mentiId, start, count);
  http.Response response;
  response = await http.Client()
      .get(url, headers: {HttpHeaders.authorizationHeader: token});
  print(utf8.decode(response.bodyBytes));
  String jsonfile = utf8.decode(response.bodyBytes);
  if (jsonfile.isNotEmpty) {
    var res = json.decode(jsonfile);
    if (!(res is List)) return [];

    res.forEach((x) {
      messages.add(TextMessage.fromMap(x));
    });

    return messages;
  }
  return [];
}

Future retrieveUnreadMessagesCount(int mentiID) async {
  String token = await getToken();
  http.Response response;
  var jres = await http.Client().get(GetUnreadMessagesCount(mentiID),
      headers: {HttpHeaders.authorizationHeader: token});
  response = jres;

  var res = json.decode(utf8.decode(response.bodyBytes));
  res = json.decode(res);

  return res["count"];
}

Future sendMessage(String message, int receiverID) async {
  final Map<String, dynamic> body = {"message": message, "user": receiverID};

  String token =
      await getToken(); // checking here would be kinda dump the way i
  // handle it currently but not checking could cause trouble in the future

  final Map<String, String> headers = {
    "Content-Type": "application/json",
    HttpHeaders.authorizationHeader: token
  };

  http.Client().post(sendMessageUrl, headers: headers, body: json.encode(body));
  return "success";
}

Future GetMentorID() async {
  String token = await getToken();

  http.Response response = ((await http.Client()
      .get(getMentorIdUrl, headers: {HttpHeaders.authorizationHeader: token})));
  Map<String, dynamic> res = json.decode(json.decode(utf8.decode(response
      .bodyBytes))); // that is so scetchy but honestly otherwise it just wont work so idc

  return res["result"];
}
