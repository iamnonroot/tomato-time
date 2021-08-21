import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomText extends StatelessWidget {
  String content = '';
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;
  final TextAlign align;
  final double lineHeight;
  final bool listen;

  CustomText(
    String content, {
    this.fontSize = 16,
    this.fontWeight = FontWeight.normal,
    this.color = Colors.black,
    this.align = TextAlign.start,
    this.lineHeight = 1.0,
    this.listen = true,
  }) {
    this.content = content;
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      this.content,
      textAlign: align,
      style: TextStyle(
        fontSize: this.fontSize,
        fontWeight: this.fontWeight,
        color: color,
        height: lineHeight,
      ),
    );
  }
}
