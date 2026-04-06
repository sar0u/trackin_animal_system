import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final Color color;
  const LoadingWidget({super.key, this.color = Colors.blue});

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(color: color);
  }
}