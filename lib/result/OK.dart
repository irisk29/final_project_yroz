import 'ResultInterface.dart';

class Ok<T> implements ResultInterface<T> {
  String message;
  T value;

  Ok(this.message, this.value) {}

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
