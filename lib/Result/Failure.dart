import 'ResultInterface.dart';

class Failure<T> implements ResultInterface<T> {
  String message;
  T value;

  Failure(String message, T value) {
    this.message = message;
    this.value = value;
  }

  bool getTag() {
    return false;
  }

  String getMessage() {
    return this.message;
  }

  T getValue() {
    return this.value;
  }
}
