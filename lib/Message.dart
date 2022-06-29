class TextMessage {
  int user;
  int creator;
  String Message;
  String created;

//<editor-fold desc="Data Methods">

  TextMessage({
    required this.user,
    required this.creator,
    required this.Message,
    required this.created,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TextMessage &&
          runtimeType == other.runtimeType &&
          user == other.user &&
          creator == other.creator &&
          Message == other.Message &&
          created == other.created);

  @override
  int get hashCode =>
      user.hashCode ^ creator.hashCode ^ Message.hashCode ^ created.hashCode;

  @override
  String toString() {
    return 'TextMessage{' +
        ' user: $user,' +
        ' creator: $creator,' +
        ' Message: $Message,' +
        ' created: $created,' +
        '}';
  }

  TextMessage copyWith({
    int? user,
    int? creator,
    String? Message,
    String? created,
  }) {
    return TextMessage(
      user: user ?? this.user,
      creator: creator ?? this.creator,
      Message: Message ?? this.Message,
      created: created ?? this.created,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user': this.user,
      'creator': this.creator,
      'Message': this.Message,
      'created': this.created,
    };
  }

  factory TextMessage.fromMap(Map<String, dynamic> map) {
    return TextMessage(
      user: map['user'] as int,
      creator: map['creator'] as int,
      Message: map['Message'] as String,
      created: map['created'] as String,
    );
  }

//</editor-fold>
}
