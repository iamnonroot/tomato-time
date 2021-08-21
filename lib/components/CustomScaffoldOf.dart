import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomScaffoldOf extends StatelessWidget {
  final Widget child;
  final bool willPop;
  final Function? onWillPop;

  const CustomScaffoldOf({
    Key? key,
    required this.child,
    this.willPop = false,
    this.onWillPop,
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
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: child,
      ),
    );
  }
}
