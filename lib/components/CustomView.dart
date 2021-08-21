import 'package:flutter/material.dart';

class CustomView extends StatelessWidget {
  final double top;
  final double radius;
  final Color? backgroundColor;
  final bool closeable;
  final Widget child;

  CustomView({
    Key? key,
    this.top = 0,
    this.radius = 0,
    this.backgroundColor = Colors.white,
    this.closeable = false,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    Radius radius = Radius.circular(this.radius);

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      width: width,
      height: height - this.top,
      margin: EdgeInsets.fromLTRB(0, top, 0, 0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: radius,
          topRight: radius,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: closeable
            ? [
                child,
                arrow(width: width / 4),
              ]
            : [
                child,
              ],
      ),
    );
  }

  Widget arrow({
    double width = 100,
  }) {
    return Positioned(
      top: 10,
      child: Container(
        width: width <= 100 ? 100 : width,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.all(
            Radius.circular(50),
          ),
        ),
      ),
    );
  }
}
