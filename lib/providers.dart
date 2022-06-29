import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pj_app/functions.dart';
import 'package:pj_app/subtask.dart';
import 'package:pj_app/task.dart';
import 'package:pj_app/track.dart';
import 'package:provider/provider.dart';

class TaskProvider with ChangeNotifier, DiagnosticableTreeMixin {
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  void LoadTasks() {
    retrieveTasks().then((x) {
      _tasks = x;
      notifyListeners();
    });
  }

  /// Makes `Counter` readable inside the devtools by listing all of its properties
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<List<Task>>('tasks', tasks));
  }
}

class SubtaskProvider with ChangeNotifier, DiagnosticableTreeMixin {
  List<Subtask> _tasks = [];

  List<Subtask> get tasks => _tasks;

  void LoadSubtasks({int mentiId = -1}) {
    retrieveSubtasks(mentiId: mentiId).then((x) {
      _tasks = x;
      notifyListeners();
    });
  }

  /// Makes `Counter` readable inside the devtools by listing all of its properties
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<List<Subtask>>('tasks', tasks));
  }
}

class TrackProvider with ChangeNotifier, DiagnosticableTreeMixin {
  List<Track> _tracks = [];

  List<Track> get tracks => _tracks;

  void LoadTracks({int user = -1}) {
    retrieveTracks(user: user).then((x) {
      _tracks = x;
      notifyListeners();
    });
  }

  /// Makes `Counter` readable inside the devtools by listing all of its properties
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<List<Track>>('tasks', tracks));
  }
}
