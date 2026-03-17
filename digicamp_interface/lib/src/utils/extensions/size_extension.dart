import 'package:flutter/material.dart';

extension SizeExtension on BuildContext {
  double sw([double fraction = 1]) => MediaQuery.of(this).size.width * fraction;

  double sh([double fraction = 1]) =>
      MediaQuery.of(this).size.height * fraction;
}
