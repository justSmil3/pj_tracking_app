import 'subtask.dart';
class Track {
  // TODO work on text choices
  int id;
  int task;
  String rating_0;
  double rating_1;
  int score;
  String created;
  String updated;

//<editor-fold desc="Data Methods">

  Track({
    required this.id,
    required this.task,
    required this.rating_0,
    required this.rating_1,
    required this.score,
    required this.created,
    required this.updated,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Track &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          task == other.task &&
          rating_0 == other.rating_0 &&
          rating_1 == other.rating_1 &&
          score == other.score &&
          created == other.created &&
          updated == other.updated);

  @override
  int get hashCode =>
      id.hashCode ^
      task.hashCode ^
      rating_0.hashCode ^
      rating_1.hashCode ^
      score.hashCode ^
      created.hashCode ^
      updated.hashCode;

  @override
  String toString() {
    return 'Track{' +
        ' id: $id,' +
        ' task: $task,' +
        ' rating_0: $rating_0,' +
        ' rating_1: $rating_1,' +
        ' score: $score,' +
        ' created: $created,' +
        ' updated: $updated,' +
        '}';
  }

  Track copyWith({
    int? id,
    int? task,
    String? rating_0,
    double? rating_1,
    int? score,
    String? created,
    String? updated,
  }) {
    return Track(
      id: id ?? this.id,
      task: task ?? this.task,
      rating_0: rating_0 ?? this.rating_0,
      rating_1: rating_1 ?? this.rating_1,
      score: score ?? this.score,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'task': this.task,
      'rating_0': this.rating_0,
      'rating_1': this.rating_1,
      'score': this.score,
      'created': this.created,
      'updated': this.updated,
    };
  }

  factory Track.fromMap(Map<String, dynamic> map) {
    return Track(
      id: map['id'] as int,
      task: map['task'] as int,
      rating_0: map['rating_0'] as String,
      rating_1: map['rating_1'] as double,
      score: map['score'] as int,
      created: map['created'] as String,
      updated: map['updated'] as String,
    );
  }

//</editor-fold>
}