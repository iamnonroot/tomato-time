import 'package:flutter/material.dart';
import 'package:pomodoro/components/CustomText.dart';

class CustomContent extends StatelessWidget {
  final String title;
  final String content;
  final double space;
  final CrossAxisAlignment alignment;
  final TextAlign textAlign;

  const CustomContent({
    Key? key,
    required this.title,
    required this.content,
    this.space = 24,
    this.alignment = CrossAxisAlignment.start,
    this.textAlign = TextAlign.start,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(30, 40, 20, 30),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          CustomText(
            title,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            lineHeight: 1.5,
            align: textAlign,
          ),
          SizedBox(
            height: space,
          ),
          CustomText(
            content,
            color: Colors.grey[600],
            lineHeight: 1.7,
            align: textAlign,
          ),
        ],
      ),
    );
  }
}
