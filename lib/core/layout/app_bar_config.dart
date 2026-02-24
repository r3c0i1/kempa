import 'package:flutter/material.dart';

class AppBarConfig {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;

  const AppBarConfig({
    required this.title,
    this.actions,
    this.centerTitle = false
  });
}