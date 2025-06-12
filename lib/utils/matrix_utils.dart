class MatrixUtils {
  static List<List<int>> create2DMatrix(
    int rows,
    int columns, {
    int initialValue = -1,
  }) {
    return List.generate(
      rows,
      (_) => List.generate(columns, (_) => initialValue),
    );
  }

  static List<List<int>> generate2DMatrix(
    int rows,
    int columns,
    int Function(int, int) generator,
  ) {
    return List.generate(
      rows,
      (r) => List.generate(columns, (c) => generator(r, c)),
    );
  }
}
