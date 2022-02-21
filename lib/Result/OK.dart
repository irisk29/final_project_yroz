import 'ResultInterface.dart';

class Ok<T> implements ResultInterface<T> {
  String message;
  T value;

  Ok(String message, T value) {
    this.message = message;
    this.value = value;
  }

  bool getTag() {
    return true;
  }

  String getMessage() {
    return this.message;
  }

  T getValue() {
    return this.value;
  }
}
