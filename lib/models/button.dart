import 'package:flutter/material.dart';
class ButtonModel{
  IconData icon;
  VoidCallback action;
  Color color;
  String text;
  ButtonModel({
    required this.icon,
    required this.action,
    required this.color,
    required this.text
  });
}