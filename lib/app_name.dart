import 'package:flutter/material.dart';

class AppNameText extends StatelessWidget {
  const AppNameText({super.key, required this.fontSize});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'NET',
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.w300,
              letterSpacing: 2,
            ),
          ),
          TextSpan(
            text: 'PRIME',
            style: TextStyle(
              color: Color(0xFF2979FF),
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          TextSpan(
            text: 'X',
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize + 6,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
