import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';
import 'package:pomodoro/interface/pomodoro.dart';
import 'package:pomodoro/core/storage.dart' as storage;
import 'package:pomodoro/services/pomodoro.dart' as pomodoro;
import 'package:pomodoro/components/CustomContent.dart';
import 'package:pomodoro/components/CustomScaffoldOf.dart';
import 'package:pomodoro/components/PomodoroItem.dart';
import 'package:pomodoro/components/CustomText.dart';
import 'package:pomodoro/components/CustomView.dart';
import 'package:pomodoro/widgets/form.dart';
import 'package:pomodoro/widgets/language.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool canCloseModal = false;
  bool openedModal = false;
  bool ready = false;

  int step = 0;

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) => init());

    super.initState();
  }

  void init() async {
    Map<String, dynamic>? item = await pomodoro.fetch();
    if (item == null) {
      List<IPomodoro>? items = await pomodoro.load();
      String? locale = await storage.getItem('locale');

      if (items == null) {
        setState(() {
          ready = true;
          if (locale == null)
            askUserForLanguage(context);
          else
            canCloseModal = true;
        });
      } else {
        Navigator.pushReplacementNamed(context, 'home');
      }
    } else {
      Navigator.pushReplacementNamed(context, 'item',
          arguments: jsonEncode(item));
    }
  }

  void askUserForLanguage(BuildContext context) {
    setState(() => this.openedModal = true);
    showModalBottomSheet(
      context: context,
      builder: (context) => CustomScaffoldOf(
        willPop: canCloseModal,
        child: LanguageBottomSheetWidget(
          closeable: canCloseModal,
        ),
      ),
      backgroundColor: Colors.transparent,
      enableDrag: canCloseModal,
      isDismissible: canCloseModal,
      isScrollControlled: true,
    ).then((_) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
      ));

      setState(() {
        this.openedModal = false;
        this.canCloseModal = true;
      });
    });
  }

  void askUserForForm(BuildContext context) {
    setState(() => this.openedModal = true);
    showModalBottomSheet(
      context: context,
      builder: (context) => CustomScaffoldOf(
        willPop: canCloseModal,
        child: PomodoroForm(
          onSubmit: (IPomodoro pomodoro) => this.saveNewPomodoro(pomodoro),
        ),
      ),
      backgroundColor: Colors.transparent,
      enableDrag: canCloseModal,
      isDismissible: canCloseModal,
      isScrollControlled: true,
    ).then((_) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
      ));

      setState(() {
        this.openedModal = false;
      });
    });
  }

  void saveNewPomodoro(IPomodoro item) async {
    try {
      await pomodoro.add(item);
      Navigator.pushReplacementNamed(context, 'home');
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffoldOf(
      willPop: step != 0,
      onWillPop: () => setState(() => this.step -= 1),
      child: ready
          ? Scaffold(
              backgroundColor: Colors.black,
              floatingActionButton: _FloatingActionButton(),
              body: CustomView(
                top: !openedModal ? 0 : 50,
                radius: !openedModal ? 0 : 15,
                child: Column(
                  children: _Steps(),
                ),
              ),
            )
          : Container(
              color: Colors.white,
            ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget _Header({
    double height = 300,
    double width = double.infinity,
    double radius = 16,
  }) {
    Radius _radius = Radius.circular(radius);

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      height: height,
      width: width,
      padding: EdgeInsets.fromLTRB(30, 0, 30, 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: _radius,
          topRight: _radius,
        ),
        image: DecorationImage(
            image: AssetImage("lib/assets/images/splash.png"),
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget _Footer() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _ChangeLanguage(),
        ],
      ),
    );
  }

  // ignore: non_constant_identifier_names
  List<Widget> _Steps() {
    double height = 350;

    if (step == 1)
      height = 200;
    else if (step == 2) height = 0;

    List<Widget> widgets = [
      _Header(
        height: height,
        radius: !openedModal ? 0 : 16,
      ),
    ];
    if (step == 0 || step == 1) {
      widgets.addAll([
        _Step(
          title: step == 0
              ? AppLocalizations.of(context)!.splash_wellcome_title
              : AppLocalizations.of(context)!.splash_question_title,
          content: step == 0
              ? AppLocalizations.of(context)!.splash_wellcome_content
              : AppLocalizations.of(context)!.splash_answer_content,
        ),
        Spacer(),
        _Footer(),
      ]);
    } else {
      widgets.addAll([
        SizedBox(
          height: 30,
        ),
        PomodoroItem(
          margin: 20,
          name: AppLocalizations.of(context)!.pomodoro_example_name,
          description:
              AppLocalizations.of(context)!.pomodoro_example_description,
          period: 2,
          time: 25,
          short: 5,
          long: 30,
        ),
        _Step(
          title: AppLocalizations.of(context)!.splash_example_title,
          content: AppLocalizations.of(context)!.splash_example_content,
        ),
      ]);
    }

    return widgets;
  }

  // ignore: non_constant_identifier_names
  Widget _Step({
    required String title,
    required String content,
  }) {
    return CustomContent(
      title: title,
      content: content,
    );
  }

  // ignore: non_constant_identifier_names
  Widget _ChangeLanguage() {
    return TextButton(
      onPressed: () => askUserForLanguage(context),
      child: CustomText(
        AppLocalizations.of(context)!.change_language,
      ),
    );
  }

  // ignore: non_constant_identifier_names
  FloatingActionButton _FloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: step <= 1
          ? () => setState(() => step += 1)
          : () => askUserForForm(context),
      label: step <= 1
          ? Icon(
              step <= 1 ? Icons.arrow_forward : Icons.add,
            )
          : CustomText(AppLocalizations.of(context)!.add_pomodoro),
      icon: step <= 1
          ? null
          : Icon(
              Icons.add,
            ),
    );
  }
}

class Step {
  String title;
  String content;

  Step({
    required this.title,
    required this.content,
  });
}
