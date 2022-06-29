import 'task.dart';

class Subtask {
  int id;
  int task;
  String name;
  String description;
  int scoreadd;
  String classes;

//<editor-fold desc="Data Methods">

  Subtask(
      {required this.id,
      required this.task,
      required this.name,
      required this.description,
      required this.scoreadd,
      required this.classes});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subtask &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          task == other.task &&
          name == other.name &&
          description == other.description &&
          scoreadd == other.scoreadd &&
          classes == other.classes);

  @override
  int get hashCode =>
      id.hashCode ^
      task.hashCode ^
      name.hashCode ^
      description.hashCode ^
      scoreadd.hashCode ^
      classes.hashCode;

  @override
  String toString() {
    return 'Subtask{' +
        ' id: $id,' +
        ' task: $task,' +
        ' name: $name,' +
        ' description: $description,' +
        ' scoreadd: $scoreadd,' +
        ' classes: $classes,' +
        '}';
  }

  Subtask copyWith({
    int? id,
    int? task,
    String? name,
    String? description,
    int? scoreadd,
    String? classes,
  }) {
    return Subtask(
      id: id ?? this.id,
      task: task ?? this.task,
      name: name ?? this.name,
      description: description ?? this.description,
      scoreadd: scoreadd ?? this.scoreadd,
      classes: classes ?? this.classes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'task': this.task,
      'name': this.name,
      'description': this.description,
      'scoreadd': this.scoreadd,
      'classes': this.classes,
    };
  }

  factory Subtask.fromMap(Map<String, dynamic> map) {
    return Subtask(
      id: map['id'] as int,
      task: map['task'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
      scoreadd: map['scoreadd'] as int,
      classes: map['classes'] as String,
    );
  }

//</editor-fold>
}
