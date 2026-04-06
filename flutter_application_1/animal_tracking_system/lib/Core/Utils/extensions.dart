import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String toTitleCase() {
    return split(' ').map((word) => word.capitalize()).join(' ');
  }
}

extension DateTimeExtension on DateTime {
  String formatDate() {
    return DateFormat('dd/MM/yyyy').format(this);
  }

  String formatDateTime() {
    return DateFormat('dd/MM/yyyy HH:mm').format(this);
  }

  String formatTime() {
    return DateFormat('HH:mm').format(this);
  }
}

extension WidgetExtension on Widget {
  Widget padding({double all = 0, double horizontal = 0, double vertical = 0}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontal,
        vertical: vertical,
      ).copyWith(
        top: all > 0 ? all : vertical,
        bottom: all > 0 ? all : vertical,
        left: all > 0 ? all : horizontal,
        right: all > 0 ? all : horizontal,
      ),
      child: this,
    );
  }

  Widget center() {
    return Center(child: this);
  }

  Widget rounded({double radius = 8}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: this,
    );
  }

  Widget shadow({double elevation = 2}) {
    return Material(
      elevation: elevation,
      borderRadius: BorderRadius.circular(8),
      child: this,
    );
  }
}