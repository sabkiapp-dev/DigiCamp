class Utils {
  Utils._();

  static List<List<T>> generateBatch<T>(List<T> list, int batchSize) {
    final b = list.length ~/ batchSize;

    return [
      for (var i = 0; i < b; i++)
        list.sublist(i * batchSize, (i + 1) * batchSize),
      if (b * batchSize < list.length) list.sublist(b * batchSize, list.length)
    ];
  }
}
