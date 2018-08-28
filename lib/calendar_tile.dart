import 'package:flutter/material.dart';
import 'package:date_utils/date_utils.dart';

import 'package:flutter_calendar/tick.dart';
import 'package:flutter_calendar/tick_scroller.dart';

class CalendarTile extends StatelessWidget {
  final VoidCallback onDateSelected;
  final DateTime date;
  final String dayOfWeek;
  final bool isDayOfWeek;
  final bool isSelected;
  final TextStyle dayOfWeekStyles;
  final TextStyle dateStyles;
  final TextStyle selectedStyle;
  final TextStyle todayStyle;
  final Widget child;
  final TicksBuilder ticksBuilder;
  
  // if provided a color with an alpha <= 0 the color will be disabled
  Color todayColor;  // defaults to primary color
  Color selectedColor;  // defaults to accent color

  bool get isToday => Utils.isSameDay(date, DateTime.now());

  CalendarTile({
    this.onDateSelected,
    this.date,
    this.child,
    this.dateStyles,
    this.selectedStyle = const TextStyle(color: Colors.white),
    this.todayStyle = const TextStyle(color: Colors.white),
    this.dayOfWeek,
    this.dayOfWeekStyles,
    this.isDayOfWeek: false,
    this.isSelected: false,
    this.ticksBuilder,
    this.todayColor,
    this.selectedColor,
  });

  Widget renderDateOrDayOfWeek(BuildContext context) {
    todayColor ??= Theme.of(context).primaryColor;
    selectedColor ??= Theme.of(context).accentColor;
    if (isDayOfWeek) {
      return InkWell(
        child: Container(
          alignment: Alignment.center,
          child: Text(
            dayOfWeek,
            style: dayOfWeekStyles,
          ),
        ),
      );
    } else {
      return InkWell(
        onTap: onDateSelected,
        child: Container(
          decoration: isSelected && selectedColor.alpha > 0
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  color: selectedColor,
                )
              : isToday && todayColor.alpha > 0
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    color: todayColor,
                  )
                : BoxDecoration(),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                Utils.formatDay(date).toString(),
                style: isSelected ? selectedStyle : isToday ? todayStyle : dateStyles,
                textAlign: TextAlign.center,
              ),
              ticksBuilder != null
                ? TickScroller(
                  ticks: ticksBuilder(context, date),
                )
                : null,
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (child != null) {
      return child;
    }
    return Container(
      child: renderDateOrDayOfWeek(context),
    );
  }
}
