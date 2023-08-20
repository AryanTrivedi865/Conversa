import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EpochToDate{
  static String getFormattedTime(BuildContext context,String epochString){
    final date=DateTime.fromMillisecondsSinceEpoch(int.parse(epochString));
    return TimeOfDay.fromDateTime(date).format(context);
  }
  static String getFormattedDate(BuildContext context, String epochString) {
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(int.parse(epochString));
      final time = TimeOfDay.fromDateTime(date).format(context);
      final formattedDate =
          "${DateFormat.d(Localizations.localeOf(context).toString()).format(date)} ${DateFormat.MMM(Localizations.localeOf(context).toString()).format(date)} ${DateFormat.y(Localizations.localeOf(context).toString()).format(date)} at";
      return '$formattedDate $time';
    } catch (error) {
      return getFormattedDate(context, "1690871400000");
    }
  }
  static String getLastMessageTime(BuildContext context, String epochString) {
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(epochString));
    final now=DateTime.now();
    if(now.day==date.day && now.month==date.month && now.year==date.year){
      return TimeOfDay.fromDateTime(date).format(context);
    }
    return '${date.day} ${DateFormat.MMM(Localizations.localeOf(context).toString()).format(date)}';
  }
  static String getVideoDate(BuildContext context, String epochString) {
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(epochString));
    final formattedDate = "${DateFormat.y(Localizations.localeOf(context).toString()).format(date)}${DateFormat.M(Localizations.localeOf(context).toString()).format(date)}${DateFormat.d(Localizations.localeOf(context).toString()).format(date)}-${DateFormat.H((Localizations.localeOf(context).toString())).format(date)}${DateFormat.m((Localizations.localeOf(context).toString())).format(date)}${DateFormat.s((Localizations.localeOf(context).toString())).format(date)}";
    return formattedDate;
  }
}