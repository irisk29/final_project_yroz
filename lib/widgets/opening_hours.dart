import 'package:final_project_yroz/DTOs/BankAccountDTO.dart';
import 'package:final_project_yroz/InternalPaymentGateway/InternalPaymentGateway.dart';
import 'package:flutter/material.dart';
import 'package:final_project_yroz/LogicModels/OpeningTimes.dart';
import 'package:tuple/tuple.dart';

class OpeningHours extends StatefulWidget {
  @override
  State<OpeningHours> createState() => _OpeningHoursState();

  Openings saveOpenHours(){
    return Openings(days: _OpeningHoursState.days);
  }
}

class _OpeningHoursState extends State<OpeningHours> {

  Tuple2<TimeOfDay,TimeOfDay> sunday_times = Tuple2(TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59));
  Tuple2<TimeOfDay,TimeOfDay> monday_times = Tuple2(TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59));
  Tuple2<TimeOfDay,TimeOfDay> tuesday_times = Tuple2(TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59));
  Tuple2<TimeOfDay,TimeOfDay> wednesday_times = Tuple2(TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59));
  Tuple2<TimeOfDay,TimeOfDay> thursday_times = Tuple2(TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59));
  Tuple2<TimeOfDay,TimeOfDay> friday_times = Tuple2(TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59));
  Tuple2<TimeOfDay,TimeOfDay> saturday_times = Tuple2(TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59));

  static late List<OpeningTimes> days;

  late List<bool> showHours;

  _OpeningHoursState(){
    days = [
      new OpeningTimes(day: "Sunday", closed: false, operationHours: sunday_times),
      new OpeningTimes(day: "Monday", closed: false, operationHours: monday_times),
      new OpeningTimes(day: "Tuesday", closed: false, operationHours: tuesday_times),
      new OpeningTimes(day: "Wednesday", closed: false, operationHours: wednesday_times),
      new OpeningTimes(day: "Thursday", closed: false, operationHours: thursday_times),
      new OpeningTimes(day: "Friday", closed: false, operationHours: friday_times),
      new OpeningTimes(day: "Saturday", closed: false, operationHours: saturday_times),
    ];
    showHours = days.map((user) => false).toList();
  }

  void showHour(int index) {
    setState(() {
      showHours[index] = !showHours[index];
    });
  }

  void _selectTime(int index1, int item) async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: item==1 ? days[index1].operationHours.item1 : days[index1].operationHours.item2,
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (newTime != null) {
      setState(() {
        item==1 ? days[index1].operationHours = Tuple2(newTime, days[index1].operationHours.item2)
        : days[index1].operationHours = Tuple2(days[index1].operationHours.item1, newTime);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Container(
      height: deviceSize.height * 0.65,
      child: ListView.builder(
            shrinkWrap: true,
            physics: AlwaysScrollableScrollPhysics(),
            itemBuilder: (ctx, index) {
                  return Column(
                    children: [
                      Card(
                        elevation: 5,
                        margin: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 5,
                        ),
                        child: ListTile(
                            title: Text(days[index].day),
                            isThreeLine: false,
                            trailing: IconButton(
                              icon: !showHours[index]
                                  ? Icon(Icons.expand_more)
                                  : Icon(Icons.expand_less),
                              color: Theme.of(context).primaryColor,
                              onPressed: () => showHour(index),
                            )),
                      ),
                      showHours[index] ?
                      Column(
                        children: [
                          !(days[index].closed) ?
                               Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        _selectTime(index,1);
                                      },
                                      child: Text(days[index].operationHours.item1
                                          .format(context)),
                                    ),
                                    Text('-'),
                                    ElevatedButton(
                                      onPressed: () {
                                        _selectTime(index,2);
                                      },
                                      child: Text(days[index].operationHours.item2
                                          .format(context)),
                                    ),
                                  ],
                      ) : Container(),
                          CheckboxListTile(
                            value: days[index].closed,
                            title: Text("Closed"),
                            controlAffinity: ListTileControlAffinity.leading,
                            onChanged: (isChecked) {
                              setState(() {
                                days[index].closed = isChecked!;
                              });
                            },
                          ),
                        ],
                      )
                      : Container()
                    ],
                  );
                },
                itemCount: days.length,
      ),
    );
  }
}
