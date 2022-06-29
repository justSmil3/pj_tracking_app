class Task{
  int id;
  String name;
  String description;

//<editor-fold desc="Data Methods">

  Task({
    required this.id,
    required this.name,
    required this.description,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description);

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ description.hashCode;

  @override
  String toString() {
    return 'Task{' +
        ' id: $id,' +
        ' name: $name,' +
        ' description: $description,' +
        '}';
  }

  Task copyWith({
    int? id,
    String? name,
    String? description,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'description': this.description,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
    );
  }

//</editor-fold>
}