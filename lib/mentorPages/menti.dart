class Menti {
  int id;
  int mentor;
  int user;
  String name;

//<editor-fold desc="Data Methods">

  Menti({
    required this.id,
    required this.mentor,
    required this.user,
    required this.name,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Menti &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          mentor == other.mentor &&
          user == other.user &&
          name == other.name);

  @override
  int get hashCode =>
      id.hashCode ^ mentor.hashCode ^ user.hashCode ^ name.hashCode;

  @override
  String toString() {
    return 'Menti{' +
        ' id: $id,' +
        ' mentor: $mentor,' +
        ' user: $user,' +
        ' name: $name,' +
        '}';
  }

  Menti copyWith({
    int? id,
    int? mentor,
    int? user,
    String? name,
  }) {
    return Menti(
      id: id ?? this.id,
      mentor: mentor ?? this.mentor,
      user: user ?? this.user,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'mentor': this.mentor,
      'user': this.user,
      'name': this.name,
    };
  }

  factory Menti.fromMap(Map<String, dynamic> map) {
    return Menti(
      id: map['id'] as int,
      mentor: map['mentor'] as int,
      user: map['user'] as int,
      name: map['name'] as String,
    );
  }

//</editor-fold>
}