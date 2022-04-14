import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class OpeningTimes {
  final String day;
  bool closed;
  Tuple2<TimeOfDay, TimeOfDay> operationHours;

  OpeningTimes(
      {required this.day, required this.closed, required this.operationHours});

  OpeningTimes clone() {
    return new OpeningTimes(
        day: this.day,
        closed: this.closed,
        operationHours:
            new Tuple2(this.operationHours.item1, this.operationHours.item2));
  }
}

class Openings {
  List<OpeningTimes> days;

  Openings({
    required this.days,
  });

  Openings clone() {
    return new Openings(days: List.from(this.days.map((e) => e.clone())));
  }
}
