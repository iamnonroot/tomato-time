import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pomodoro/services/pomodoro.dart' as pomodoro;
import 'package:pomodoro/components/CustomContent.dart';
import 'package:pomodoro/components/PomodoroItem.dart';
import 'package:pomodoro/components/CustomScaffoldOf.dart';
import 'package:pomodoro/components/CustomText.dart';
import 'package:pomodoro/components/CustomView.dart';
import 'package:pomodoro/interface/pomodoro.dart';
import 'package:pomodoro/widgets/form.dart';
import 'package:pomodoro/widgets/settings.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool showMenu = false;
  List<IPomodoro> items = [];

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) => init());

    super.initState();
  }

  void init() async {
    List<IPomodoro>? items = await pomodoro.load();
    setState(() {
      this.items = items!;
    });
  }

  void askUserForForm(BuildContext context, {IPomodoro? from, int? index}) {
    showModalBottomSheet(
      context: context,
      builder: (context) => CustomScaffoldOf(
        willPop: true,
        child: PomodoroForm(
          from: from,
          onSubmit: (IPomodoro item) {
            if (index != null)
              updatePomodoro(item, index);
            else if (index == null) addNewPomodoro(item);
          },
        ),
      ),
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.2),
      enableDrag: true,
      isDismissible: true,
      isScrollControlled: true,
    );
  }

  void showSettingsToUser(BuildContext context) {
    setState(() => showMenu = false);
    showModalBottomSheet(
      context: context,
      builder: (context) => SettingsBottomSheetWidget(),
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.2),
      enableDrag: true,
      isDismissible: true,
      isScrollControlled: true,
    );
  }

  void openDonatePage() async {
    String url = 'https://iamroot.ir/donate?from=pomodoro';
    setState(() => showMenu = false);
    if (await canLaunch(url)) await launch(url);
  }

  void openPomodoro({required IPomodoro from, required int index}) {
    Map data = {};
    data['index'] = index;
    data['from'] = from.toJSON();
    Navigator.pushNamed(
      context,
      'item',
      arguments: json.encode(data),
    ).then((_) => init());
  }

  void addNewPomodoro(IPomodoro item) async {
    try {
      await pomodoro.add(item);
      setState(() => items.add(item));
    } catch (e) {
      log(e.toString());
    }
  }

  void updatePomodoro(IPomodoro item, int index) async {
    try {
      setState(() => items[index] = item);
      await pomodoro.save(items);
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => setState(() => showMenu = !showMenu),
          icon: Icon(Icons.menu),
        ),
        title: CustomText(
          AppLocalizations.of(context)!.app_name,
          color: Colors.white,
        ),
      ),
      floatingActionButton: _FloatingActionButton(),
      body: Stack(
        children: [
          Positioned(
            child: _Menu(),
          ),
          CustomView(
            top: showMenu ? 110 : 0,
            radius: 15,
            child: _View(),
          ),
        ],
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget _View() {
    if (items.length != 0) {
      List<Widget> children = [
        CustomContent(
          title: AppLocalizations.of(context)!.home_title,
          content: AppLocalizations.of(context)!.home_content,
        ),
      ];

      for (IPomodoro item in items) {
        children.add(
          Padding(
            padding: EdgeInsets.fromLTRB(15, 0, 15, 20),
            child: PomodoroItem(
              from: item,
              onTap: () => openPomodoro(
                from: item,
                index: items.indexOf(item),
              ),
              onLongTap: () => askUserForForm(
                context,
                from: item,
                index: items.indexOf(item),
              ),
            ),
          ),
        );
      }

      children.add(
        SizedBox(
          height: 200,
        ),
      );

      return NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowGlow();
          return false;
        },
        child: ListView(
          children: children,
        ),
      );
    } else if (items.length == 0) {
      return CustomContent(
        title: AppLocalizations.of(context)!.home_empty_title,
        content: AppLocalizations.of(context)!.home_empty_content,
      );
    } else {
      return Container();
    }
  }

  // ignore: non_constant_identifier_names
  FloatingActionButton _FloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => askUserForForm(context),
      label: CustomText(AppLocalizations.of(context)!.add_pomodoro),
      icon: Icon(
        Icons.add,
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget _Menu() {
    return Column(
      children: [
        _MenuItem(
          label: AppLocalizations.of(context)!.settings,
          icon: Icons.settings,
          onTap: () => showSettingsToUser(context),
        ),
        _MenuItem(
          label: AppLocalizations.of(context)!.donate,
          icon: Icons.favorite,
          onTap: () => openDonatePage(),
        ),
      ],
    );
  }

  // ignore: non_constant_identifier_names
  Widget _MenuItem({
    required String label,
    required IconData icon,
    required Function onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: () => onTap(),
          child: Container(
            height: 52,
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                ),
                Icon(
                  icon,
                  color: Colors.white.withOpacity(0.7),
                ),
                SizedBox(
                  width: 16,
                ),
                CustomText(
                  label,
                  color: Colors.white.withOpacity(0.7),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
