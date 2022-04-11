import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class OpeningTimes {
  final String day;
  bool closed;
  Tuple2<TimeOfDay,TimeOfDay> operationHours;

  OpeningTimes({
    required this.day,
    required this.closed,
    required this.operationHours
  });
}

class Openings{
  List<OpeningTimes> days;

  Openings({
    required this.days,
  });
}
