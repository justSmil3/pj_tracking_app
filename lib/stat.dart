class Stat {
  int id;
  String date;
  int score;

//<editor-fold desc="Data Methods">

  Stat({
    required this.id,
    required this.date,
    required this.score,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Stat &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          date == other.date &&
          score == other.score);

  @override
  int get hashCode => id.hashCode ^ date.hashCode ^ score.hashCode;

  @override
  String toString() {
    return 'Stat{' + ' id: $id,' + ' date: $date,' + ' score: $score,' + '}';
  }

  Stat copyWith({
    int? id,
    String? date,
    int? score,
  }) {
    return Stat(
      id: id ?? this.id,
      date: date ?? this.date,
      score: score ?? this.score,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'date': this.date,
      'score': this.score,
    };
  }

  factory Stat.fromMap(Map<String, dynamic> map) {
    return Stat(
      id: map['id'] as int,
      date: map['date'] as String,
      score: map['score'] as int,
    );
  }

//</editor-fold>
}
