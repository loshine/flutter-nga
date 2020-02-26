class ToggleLikeReaction {
  const ToggleLikeReaction(this.message, this.countChange)
      : assert(message != null),
        assert(countChange != null);

  Map<String, dynamic> toJson() {
    return {'0': message, '1': countChange};
  }

  factory ToggleLikeReaction.fromJson(Map map) {
    return ToggleLikeReaction(map['0'], map['1']);
  }

  final String message;
  final int countChange;
}
