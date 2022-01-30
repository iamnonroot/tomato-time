import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomScaffoldOf extends StatelessWidget {
  final Widget child;
  final bool willPop;
  final Function? onWillPop;
  final Brightness brightness;

  const CustomScaffoldOf({
    Key? key,
    required this.child,
    this.willPop = false,
    this.onWillPop,
    this.brightness = Brightness.light,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (willPop == true && onWillPop != null) {
          onWillPop!();
          return false;
        } else
          return willPop;
      },
      child: AnnotatedRegion(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.white,
          statusBarIconBrightness: this.brightness,
          systemNavigationBarIconBrightness: this.brightness,
        ),
        child: child,
      ),
    );
  }
}
