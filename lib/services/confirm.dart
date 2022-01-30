import 'package:flutter/material.dart';
import 'package:pomodoro/components/CustomContent.dart';
import 'package:pomodoro/components/CustomText.dart';

class ConfirmBottomSheetWidget extends StatelessWidget {
  final String title;
  final String content;
  final String yes;
  final String no;
  final Function callback;

  const ConfirmBottomSheetWidget({
    Key? key,
    required this.title,
    required this.content,
    required this.yes,
    required this.no,
    required this.callback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    Radius radius = Radius.circular(15);

    return Container(
      width: width,
      height: 220,
      padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white,
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
        children: [
          CustomContent(
            title: title,
            content: content,
            space: 8,
          ),
          buttons(context),
          arrow(),
        ],
      ),
    );
  }

  Widget buttons(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 85,
            height: 42,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: CustomText(
                no,
                fontSize: 14,
              ),
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 12,
          ),
          SizedBox(
            width: 120,
            height: 42,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                callback();
              },
              child: CustomText(
                yes,
                fontSize: 14,
              ),
              style: ButtonStyle(
                elevation: MaterialStateProperty.all(0),
                backgroundColor: MaterialStateProperty.all(Colors.amber),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
            ),
          )
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

void askForConfirm({
  required BuildContext context,
  required String title,
  required String content,
  required String yes,
  required String no,
  required Function callback,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.2),
    enableDrag: true,
    isDismissible: true,
    builder: (BuildContext context) => ConfirmBottomSheetWidget(
      title: title,
      content: content,
      yes: yes,
      no: no,
      callback: callback,
    ),
  );
}
