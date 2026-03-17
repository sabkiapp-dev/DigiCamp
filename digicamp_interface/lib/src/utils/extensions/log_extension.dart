import 'dart:developer' as dev;

extension Logger on Object {
  void log() {
    dev.log(toString());
  }
}
