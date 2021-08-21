import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';
import 'package:pomodoro/components/CustomContent.dart';
import 'package:pomodoro/components/CustomFormBuilderTime.dart';
import 'package:pomodoro/components/CustomScaffoldOf.dart';
import 'package:pomodoro/components/CustomText.dart';
import 'package:pomodoro/components/CustomView.dart';
import 'package:pomodoro/components/PomodoroItem.dart';
import 'package:pomodoro/database/times.dart';
import 'package:pomodoro/interface/pomodoro.dart';

class PomodoroForm extends StatefulWidget {
  final IPomodoro? from;
  final Function onSubmit;

  const PomodoroForm({
    Key? key,
    this.from,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _PomodoroFormState createState() => _PomodoroFormState();
}

class _PomodoroFormState extends State<PomodoroForm> {
  bool preview = false;
  final GlobalKey<FormBuilderState> _key = GlobalKey<FormBuilderState>();

  IPomodoro pomodoro = IPomodoro(
    name: null,
    description: null,
    time: 25,
    short: 5,
    long: 30,
    period: 1,
  );

  @override
  void initState() {
    super.initState();

    if (widget.from != null) pomodoro = widget.from!;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
    ));
  }

  void onFormSubmit() {
    if (_key.currentState!.saveAndValidate()) {
      setState(() {
        pomodoro.name = _key.currentState!.value['name'];
        pomodoro.description = _key.currentState!.value['description'];
        preview = true;
      });
    }
  }

  void onPreviewSubmit() {
    widget.onSubmit(pomodoro);
    close();
  }

  void close() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    bool keyboardIsOpen = MediaQuery.of(context).viewInsets.bottom != 0;

    return CustomView(
      top: 70,
      radius: 15,
      closeable: true,
      child: Container(
        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: CustomScaffoldOf(
          willPop: true,
          onWillPop: () {
            preview ? setState(() => preview = false) : close();
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            floatingActionButton: Visibility(
              visible: !keyboardIsOpen,
              child: _FloatingActionButton(),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.miniEndFloat,
            body: Column(
              children: preview ? [_Preview()] : [_Form()],
            ),
          ),
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget _Preview() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowGlow();
            return false;
          },
          child: ListView(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => setState(() => preview = false),
                      icon: Icon(Icons.arrow_back),
                      splashRadius: 24,
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    CustomText(
                      AppLocalizations.of(context)!.back_to_form,
                    ),
                  ],
                ),
              ),
              PomodoroItem(
                from: pomodoro,
              ),
              SizedBox(
                height: 12,
              ),
              CustomContent(
                title:
                    AppLocalizations.of(context)!.pomodoro_form_preview_title,
                content:
                    AppLocalizations.of(context)!.pomodoro_form_preview_content,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget _Form() {
    return Expanded(
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowGlow();
          return false;
        },
        child: ListView(
          children: [
            CustomContent(
              title: AppLocalizations.of(context)!.pomodoro_form_title,
              content: AppLocalizations.of(context)!.pomodoro_form_content,
            ),
            __Form(),
          ],
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget __Form() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: FormBuilder(
        key: _key,
        initialValue: {
          'name': pomodoro.name,
          'description': pomodoro.description
        },
        child: Column(
          children: [
            FormBuilderTextField(
              name: 'name',
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.pomodoro_name,
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(context,
                    errorText: AppLocalizations.of(context)!.empty_field),
              ]),
            ),
            SizedBox(
              height: 12,
            ),
            FormBuilderTextField(
              name: 'description',
              minLines: 2,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.pomodoro_description,
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(context,
                    errorText: AppLocalizations.of(context)!.empty_field),
              ]),
            ),
            SizedBox(
              height: 20,
            ),
            CustomFormBuilderTime(
              label: AppLocalizations.of(context)!.pomodoro_timer,
              items: times,
              initialValue: pomodoro.time,
              onChanged: (int value) => setState(() => pomodoro.time = value),
            ),
            SizedBox(
              height: 12,
            ),
            CustomFormBuilderTime(
              label: AppLocalizations.of(context)!.pomodoro_short_break,
              items: times,
              initialValue: pomodoro.short,
              onChanged: (int value) => setState(() => pomodoro.short = value),
            ),
            SizedBox(
              height: 12,
            ),
            CustomFormBuilderTime(
              label: AppLocalizations.of(context)!.pomodoro_long_break,
              items: times,
              initialValue: pomodoro.long,
              onChanged: (int value) => setState(() => pomodoro.long = value),
            ),
            SizedBox(
              height: 12,
            ),
            CustomFormBuilderTime(
              suffix: false,
              label: AppLocalizations.of(context)!.pomodoro_period,
              items: [1, 2, 3, 4],
              initialValue: pomodoro.period,
              onChanged: (int value) => setState(() => pomodoro.period = value),
            ),
            SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  FloatingActionButton _FloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: preview ? () => onPreviewSubmit() : () => onFormSubmit(),
      label: CustomText(
        AppLocalizations.of(context)!.submit,
      ),
      icon: Icon(Icons.done),
    );
  }
}
