// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/src/utils/lunar_solar_utils.dart';

import '../customization/calendar_builders.dart';
import '../customization/calendar_style.dart';

class CellContent extends StatelessWidget {
  final DateTime day;
  final DateTime focusedDay;
  final dynamic locale;
  final bool isTodayHighlighted;
  final bool isToday;
  final bool isSelected;
  final bool isRangeStart;
  final bool isRangeEnd;
  final bool isWithinRange;
  final bool isOutside;
  final bool isDisabled;
  final bool isHoliday;
  final bool isWeekend;
  final CalendarStyle calendarStyle;
  final CalendarBuilders calendarBuilders;

  const CellContent({
    Key? key,
    required this.day,
    required this.focusedDay,
    required this.calendarStyle,
    required this.calendarBuilders,
    required this.isTodayHighlighted,
    required this.isToday,
    required this.isSelected,
    required this.isRangeStart,
    required this.isRangeEnd,
    required this.isWithinRange,
    required this.isOutside,
    required this.isDisabled,
    required this.isHoliday,
    required this.isWeekend,
    this.locale,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dowLabel = DateFormat.EEEE(locale).format(day);
    final dayLabel = DateFormat.yMMMMd(locale).format(day);
    final semanticsLabel = '$dowLabel, $dayLabel';

    Widget? cell =
        calendarBuilders.prioritizedBuilder?.call(context, day, focusedDay);

    if (cell != null) {
      return Semantics(
        label: semanticsLabel,
        excludeSemantics: true,
        child: cell,
      );
    }

    final text = '${day.day}';
    final margin = calendarStyle.cellMargin;
    final padding = calendarStyle.cellPadding;
    final alignment = calendarStyle.cellAlignment;
    final duration = const Duration(milliseconds: 250);
    final resultConvert = convertSolar2Lunar(day.day, day.month, day.year, 7);
    final dayLunar = resultConvert[0];
    var textLunar = dayLunar.toString();
    if(dayLunar == 1){
      textLunar = textLunar + '/' + resultConvert[1].toString();
    }

    Widget verticalMargin = const SizedBox(height: 0);

    if (isDisabled) {
      cell = calendarBuilders.disabledBuilder?.call(context, day, focusedDay) ??
          AnimatedContainer(
            duration: duration,
            margin: margin,
            padding: padding,
            decoration: calendarStyle.disabledDecoration,
            alignment: alignment,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(text, style: calendarStyle.disabledTextStyle),
                verticalMargin,
                Text(textLunar, style: calendarStyle.disabledTextStyleSmall),
              ],
            ),
          );
    } else if (isSelected) {
      cell = calendarBuilders.selectedBuilder?.call(context, day, focusedDay) ??
          AnimatedContainer(
            duration: duration,
            margin: margin,
            padding: padding,
            decoration: calendarStyle.selectedDecoration,
            alignment: alignment,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(text, style: calendarStyle.selectedTextStyle),
                verticalMargin,
                Text(textLunar, style: calendarStyle.selectedTextStyleSmall),
              ],
            ),
          );
    } else if (isRangeStart) {
      cell = calendarBuilders.rangeStartBuilder
              ?.call(context, day, focusedDay) ??
          AnimatedContainer(
            duration: duration,
            margin: margin,
            padding: padding,
            decoration: calendarStyle.rangeStartDecoration,
            alignment: alignment,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(text, style: calendarStyle.rangeStartTextStyle),
                verticalMargin,
                Text(textLunar, style: calendarStyle.rangeStartTextStyleSmall),
              ],
            ),
          );
    } else if (isRangeEnd) {
      cell = calendarBuilders.rangeEndBuilder?.call(context, day, focusedDay) ??
          AnimatedContainer(
            duration: duration,
            margin: margin,
            padding: padding,
            decoration: calendarStyle.rangeEndDecoration,
            alignment: alignment,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(text, style: calendarStyle.rangeEndTextStyle),
                verticalMargin,
                Text(textLunar, style: calendarStyle.rangeEndTextStyleSmall),
              ],
            ),
          );
    } else if (isToday && isTodayHighlighted) {
      cell = calendarBuilders.todayBuilder?.call(context, day, focusedDay) ??
          AnimatedContainer(
            duration: duration,
            margin: margin,
            padding: padding,
            decoration: calendarStyle.todayDecoration,
            alignment: alignment,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(text, style: calendarStyle.todayTextStyle),
                verticalMargin,
                Text(textLunar, style: calendarStyle.todayTextStyleSmall),
              ],
            ),
          );
    } else if (isHoliday) {
      cell = calendarBuilders.holidayBuilder?.call(context, day, focusedDay) ??
          AnimatedContainer(
            duration: duration,
            margin: margin,
            padding: padding,
            decoration: calendarStyle.holidayDecoration,
            alignment: alignment,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(text, style: calendarStyle.holidayTextStyle),
                verticalMargin,
                Text(textLunar, style: calendarStyle.holidayTextStyleSmall),
              ],
            ),
          );
    } else if (isWithinRange) {
      cell = calendarBuilders.withinRangeBuilder
              ?.call(context, day, focusedDay) ??
          AnimatedContainer(
            duration: duration,
            margin: margin,
            padding: padding,
            decoration: calendarStyle.withinRangeDecoration,
            alignment: alignment,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(text, style: calendarStyle.withinRangeTextStyle),
                verticalMargin,
                Text(textLunar, style: calendarStyle.withinRangeTextStyleSmall),
              ],
            ),
          );
    } else if (isOutside) {
      cell = calendarBuilders.outsideBuilder?.call(context, day, focusedDay) ??
          AnimatedContainer(
            duration: duration,
            margin: margin,
            padding: padding,
            decoration: calendarStyle.outsideDecoration,
            alignment: alignment,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(text, style: calendarStyle.outsideTextStyle),
                verticalMargin,
                Text(textLunar, style: calendarStyle.outsideTextStyleSmall),
              ],
            ),
          );
    } else {
      cell = calendarBuilders.defaultBuilder?.call(context, day, focusedDay) ??
          AnimatedContainer(
            duration: duration,
            margin: margin,
            padding: padding,
            decoration: isWeekend
                ? calendarStyle.weekendDecoration
                : calendarStyle.defaultDecoration,
            alignment: alignment,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  text,
                  style: isWeekend
                      ? calendarStyle.weekendTextStyle
                      : calendarStyle.defaultTextStyle,
                ),
                verticalMargin,
                Text(
                  textLunar,
                  style: isWeekend
                      ? calendarStyle.weekendTextStyleSmall
                      : calendarStyle.defaultTextStyleSmall,
                ),
              ],
            ),
          );
    }

    return Semantics(
      label: semanticsLabel,
      excludeSemantics: true,
      child: cell,
    );
  }
}
