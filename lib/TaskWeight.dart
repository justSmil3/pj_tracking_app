class TaskWeight {
  int id;
  int weight;
  int task;
  int user;

//<editor-fold desc="Data Methods">

  TaskWeight({
    required this.id,
    required this.weight,
    required this.task,
    required this.user,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskWeight &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          weight == other.weight &&
          task == other.task &&
          user == other.user);

  @override
  int get hashCode =>
      id.hashCode ^ weight.hashCode ^ task.hashCode ^ user.hashCode;

  @override
  String toString() {
    return 'TaskWeight{' +
        ' id: $id,' +
        ' weight: $weight,' +
        ' task: $task,' +
        ' user: $user,' +
        '}';
  }

  TaskWeight copyWith({
    int? id,
    int? weight,
    int? task,
    int? user,
  }) {
    return TaskWeight(
      id: id ?? this.id,
      weight: weight ?? this.weight,
      task: task ?? this.task,
      user: user ?? this.user,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'weight': this.weight,
      'task': this.task,
      'user': this.user,
    };
  }

  factory TaskWeight.fromMap(Map<String, dynamic> map) {
    return TaskWeight(
      id: map['id'] as int,
      weight: map['weight'] as int,
      task: map['task'] as int,
      user: map['user'] as int,
    );
  }

//</editor-fold>
}
