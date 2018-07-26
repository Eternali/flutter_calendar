import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import 'package:flutter_calendar/calendar_tile.dart';
import 'package:flutter_calendar/date_utils.dart';

typedef DayBuilder(BuildContext context, DateTime day);

class Calendar extends StatefulWidget {
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<Tuple2<DateTime, DateTime>> onSelectedRangeChange;
  final bool isExpandable;
  final DayBuilder dayBuilder;
  final bool showChevronsToChangeRange;
  final bool showTodayAction;
  final bool showCalendarPickerIcon;
  final DateTime initialCalendarDateOverride;

  Calendar({
    this.onDateSelected,
    this.onSelectedRangeChange,
    this.isExpandable: false,
    this.dayBuilder,
    this.showTodayAction: true,
    this.showChevronsToChangeRange: true,
    this.showCalendarPickerIcon: true,
    this.initialCalendarDateOverride
  });

  @override
  _CalendarState createState() => _CalendarState();

}

class _CalendarState extends State<Calendar> {
  final calendarUtils = DateUtils();
  DateTime today = DateTime.now();
  List<DateTime> selectedMonthsDays;
  Iterable<DateTime> selectedWeeksDays;
  DateTime _selectedDate;
  Tuple2<DateTime, DateTime> selectedRange;
  String currentMonth;
  bool isExpanded = false;
  String displayMonth;

  DateTime get selectedDate => _selectedDate;

  void initState() {
    super.initState();
    if(widget.initialCalendarDateOverride != null) today = widget.initialCalendarDateOverride;
    selectedMonthsDays = DateUtils.daysInMonth(today);
    var firstDayOfCurrentWeek = DateUtils.firstDayOfWeek(today);
    var lastDayOfCurrentWeek = DateUtils.lastDayOfWeek(today);
    selectedWeeksDays = DateUtils
        .daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek)
        .toList()
        .sublist(0, 7);
    _selectedDate = today;
    displayMonth = DateUtils.formatMonth(DateUtils.firstDayOfWeek(today));
  }

  Widget get nameAndIconRow {
    var leftInnerIcon;
    var rightInnerIcon;
    var leftOuterIcon;
    var rightOuterIcon;

    if (widget.showCalendarPickerIcon) {
      rightInnerIcon = IconButton(
        onPressed: () => selectDateFromPicker(),
        icon: Icon(Icons.calendar_today),
      );
    } else {
      rightInnerIcon = Container();
    }

    if (widget.showChevronsToChangeRange) {
      leftOuterIcon = IconButton(
        onPressed: isExpanded ? previousMonth : previousWeek,
        icon: Icon(Icons.chevron_left),
      );
      rightOuterIcon = IconButton(
        onPressed: isExpanded ? nextMonth : nextWeek,
        icon: Icon(Icons.chevron_right),
      );
    } else {
      leftOuterIcon = Container();
      rightOuterIcon = Container();
    }

    if (widget.showTodayAction) {
      leftInnerIcon = InkWell(
        child: Text('Today'),
        onTap: resetToToday,
      );
    } else {
      leftInnerIcon = Container();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        leftOuterIcon ?? Container(),
        leftInnerIcon ?? Container(),
        Text(
          displayMonth,
          style: TextStyle(
            fontSize: 20.0,
          ),
        ),
        rightInnerIcon ?? Container(),
        rightOuterIcon ?? Container(),
      ],
    );
  }

  Widget get calendarGridView {
    return Container(
      // child: PageView.builder(
      //   itemCount: 12,  // months
      //   itemBuilder: (BuildContext context, int page) {
      //     return GridView.count(
      //       shrinkWrap: true,
      //       crossAxisCount: 7,
      //       childAspectRatio: 1.5,
      //       crossAxisSpacing: 0.0,
      //       mainAxisSpacing: 0.0,
      //       children: calendarBuilder(),
      //     );
      //   },
      // ),
      child: GestureDetector(
        onHorizontalDragStart: (gestureDetails) => beginSwipe(gestureDetails),
        onHorizontalDragUpdate: (gestureDetails) =>
            getDirection(gestureDetails),
        onHorizontalDragEnd: (gestureDetails) => endSwipe(gestureDetails),
        child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 7,
          childAspectRatio: 1.5,
          mainAxisSpacing: 0.0,
          padding: EdgeInsets.only(bottom: 0.0),
          children: calendarBuilder(),
        ),
      ),
    );
  }

  List<Widget> calendarBuilder() {
    List<Widget> dayWidgets = [];
    List<DateTime> calendarDays =
        isExpanded ? selectedMonthsDays : selectedWeeksDays;

    DateUtils.weekdays.forEach(
      (day) {
        dayWidgets.add(
          CalendarTile(
            isDayOfWeek: true,
            dayOfWeek: day,
          ),
        );
      },
    );

    bool monthStarted = false;
    bool monthEnded = false;

    calendarDays.forEach(
      (day) {
        if (monthStarted && day.day == 01) {
          monthEnded = true;
        }

        if (DateUtils.isFirstDayOfMonth(day)) {
          monthStarted = true;
        }

        if (this.widget.dayBuilder != null) {
          dayWidgets.add(
            CalendarTile(
              child: this.widget.dayBuilder(context, day),
            ),
          );
        } else {
          dayWidgets.add(
            CalendarTile(
              onDateSelected: () => handleSelectedDateAndUserCallback(day),
              date: day,
              dateStyles: configureDateStyle(Theme.of(context).textTheme, monthStarted, monthEnded),
              selectedStyles: TextStyle(color: Colors.white),
              isSelected: DateUtils.isSameDay(selectedDate, day),
            ),
          );
        }
      },
    );
    return dayWidgets;
  }

  TextStyle configureDateStyle(TextTheme base, monthStarted, monthEnded) {
    TextStyle dateStyles;
    if (isExpanded) {
      dateStyles = monthStarted && !monthEnded
          ? base.body1
          : base.body1.copyWith(color: base.body1.color.withAlpha(180));
    } else {
      dateStyles = base.body1;
    }
    return dateStyles;
  }

  Widget get expansionButtonRow {
    if (widget.isExpandable) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(DateUtils.fullDayFormat(selectedDate)),
          IconButton(
            iconSize: 20.0,
            padding: EdgeInsets.all(0.0),
            onPressed: toggleExpanded,
            icon: isExpanded
                ? Icon(Icons.arrow_drop_up)
                : Icon(Icons.arrow_drop_down),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          nameAndIconRow,
          ExpansionCrossFade(
            collapsed: calendarGridView,
            expanded: calendarGridView,
            isExpanded: isExpanded,
          ),
          expansionButtonRow
        ],
      ),
    );
  }

  void resetToToday() {
    today = DateTime.now();
    var firstDayOfCurrentWeek = DateUtils.firstDayOfWeek(today);
    var lastDayOfCurrentWeek = DateUtils.lastDayOfWeek(today);

    setState(() {
      _selectedDate = today;
      selectedWeeksDays = DateUtils
          .daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek)
          .toList();
      displayMonth = DateUtils.formatMonth(DateUtils.firstDayOfWeek(today));
    });

    _launchDateSelectionCallback(today);
  }

  void nextMonth() {
    setState(() {
      today = DateUtils.nextMonth(today);
      var firstDateOfNewMonth = DateUtils.firstDayOfMonth(today);
      var lastDateOfNewMonth = DateUtils.lastDayOfMonth(today);
      updateSelectedRange(firstDateOfNewMonth, lastDateOfNewMonth);
      selectedMonthsDays = DateUtils.daysInMonth(today);
      displayMonth = DateUtils.formatMonth(DateUtils.firstDayOfWeek(today));
    });
  }

  void previousMonth() {
    setState(() {
      today = DateUtils.previousMonth(today);
      var firstDateOfNewMonth = DateUtils.firstDayOfMonth(today);
      var lastDateOfNewMonth = DateUtils.lastDayOfMonth(today);
      updateSelectedRange(firstDateOfNewMonth, lastDateOfNewMonth);
      selectedMonthsDays = DateUtils.daysInMonth(today);
      displayMonth = DateUtils.formatMonth(DateUtils.firstDayOfWeek(today));
    });
  }

  void nextWeek() {
    setState(() {
      today = DateUtils.nextWeek(today);
      var firstDayOfCurrentWeek = DateUtils.firstDayOfWeek(today);
      var lastDayOfCurrentWeek = DateUtils.lastDayOfWeek(today);
      updateSelectedRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek);
      selectedWeeksDays = DateUtils
          .daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek)
          .toList()
          .sublist(0, 7);
      displayMonth = DateUtils.formatMonth(DateUtils.firstDayOfWeek(today));
    });
  }

  void previousWeek() {
    setState(() {
      today = DateUtils.previousWeek(today);
      var firstDayOfCurrentWeek = DateUtils.firstDayOfWeek(today);
      var lastDayOfCurrentWeek = DateUtils.lastDayOfWeek(today);
      updateSelectedRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek);
      selectedWeeksDays = DateUtils
          .daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek)
          .toList()
          .sublist(0, 7);
      displayMonth = DateUtils.formatMonth(DateUtils.firstDayOfWeek(today));
    });
  }

  void updateSelectedRange(DateTime start, DateTime end) {
    selectedRange = Tuple2<DateTime, DateTime>(start, end);
    if (widget.onSelectedRangeChange != null) {
      widget.onSelectedRangeChange(selectedRange);
    }
  }

  Future<Null> selectDateFromPicker() async {
    DateTime selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1960),
      lastDate: DateTime(2050),
    );



    if (selected != null) {
      var firstDayOfCurrentWeek = DateUtils.firstDayOfWeek(selected);
      var lastDayOfCurrentWeek = DateUtils.lastDayOfWeek(selected);


      setState(() {
        _selectedDate = selected;
        selectedWeeksDays = DateUtils
            .daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek)
            .toList();
        selectedMonthsDays = DateUtils.daysInMonth(selected);
        displayMonth = DateUtils.formatMonth(DateUtils.firstDayOfWeek(selected));
      });

      _launchDateSelectionCallback(selected);
    }
  }

  var gestureStart;
  var gestureDirection;
  void beginSwipe(DragStartDetails gestureDetails) {
    gestureStart = gestureDetails.globalPosition.dx;
  }

  void getDirection(DragUpdateDetails gestureDetails) {
    if (gestureDetails.globalPosition.dx < gestureStart) {
      gestureDirection = 'rightToLeft';
    } else {
      gestureDirection = 'leftToRight';
    }
  }

  void endSwipe(DragEndDetails gestureDetails) {
    if (gestureDirection == 'rightToLeft') {
      if (isExpanded) {
        nextMonth();
      } else {
        nextWeek();
      }
    } else {
      if (isExpanded) {
        previousMonth();
      } else {
        previousWeek();
      }
    }
  }

  void toggleExpanded() {
    if (widget.isExpandable) {
      setState(() => isExpanded = !isExpanded);
    }
  }

  void handleSelectedDateAndUserCallback(DateTime day) {
    var firstDayOfCurrentWeek = DateUtils.firstDayOfWeek(day);
    var lastDayOfCurrentWeek = DateUtils.lastDayOfWeek(day);
    setState(() {
      _selectedDate = day;
      selectedWeeksDays = DateUtils
          .daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek)
          .toList();
      selectedMonthsDays = DateUtils.daysInMonth(day);
    });
    _launchDateSelectionCallback(day);
  }

  void _launchDateSelectionCallback(DateTime day) {
    if (widget.onDateSelected != null) {
      widget.onDateSelected(day);
    }
  }
}

class ExpansionCrossFade extends StatelessWidget {
  final Widget collapsed;
  final Widget expanded;
  final bool isExpanded;

  ExpansionCrossFade({this.collapsed, this.expanded, this.isExpanded});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      child: AnimatedCrossFade(
        firstChild: collapsed,
        secondChild: expanded,
        firstCurve: const Interval(0.0, 1.0, curve: Curves.fastOutSlowIn),
        secondCurve: const Interval(0.0, 1.0, curve: Curves.fastOutSlowIn),
        sizeCurve: Curves.decelerate,
        crossFadeState:
            isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 300),
      ),
    );
  }
}
