class CloseCall {
  final int level;
  final String message;

  const CloseCall({required this.level, required this.message});

  bool get hasCloseCall => level > 0;

  String get stars => '★' * level + '☆' * (3 - level);
}
