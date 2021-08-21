import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';
import 'package:pomodoro/components/CustomContent.dart';
import 'package:pomodoro/services/confirm.dart';
import 'package:pomodoro/services/pomodoro.dart' as pomodoro;
import 'package:pomodoro/services/notification.dart' as notification;
import 'package:pomodoro/components/CustomScaffoldOf.dart';
import 'package:pomodoro/components/CustomText.dart';
import 'package:pomodoro/components/CustomView.dart';
import 'package:pomodoro/interface/pomodoro.dart';
import 'package:pomodoro/widgets/form.dart';

class Item extends StatefulWidget {
  final Object arguments;

  const Item({
    Key? key,
    required this.arguments,
  }) : super(key: key);

  @override
  _ItemState createState() => _ItemState();
}

class _ItemState extends State<Item> with TickerProviderStateMixin {
  // from aragments:
  late IPomodoro from;
  late int index; // index of pomodoro
  //
  late Data data;
  late TimerData? timerData = TimerData(
    end: DateTime.now(),
    time: 0,
    onEnded: () {},
  );
  List<TimeItem> timeItems = [];
  int i = 0; // index of item
  DateTime? dateTime; // on start set started time
  Timer? timer;

  @override
  void initState() {
    Map aragments = jsonDecode(widget.arguments.toString());

    index = aragments['index'];
    from = IPomodoro.fromJson(aragments['from']);

    int? start = aragments['start'];
    int? end = aragments['end'];

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (start != null && end != null) {
        DateTime startTime = DateTime.fromMillisecondsSinceEpoch(start);
        DateTime endTime = DateTime.fromMillisecondsSinceEpoch(end);
        DateTime now = DateTime.now();
        int duration = endTime.compareTo(now);
        if (duration <= 0) {
          setDefault();
        } else {
          setDefault(
            start: startTime,
          );
          startTimer();
        }
      } else
        setDefault();
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    print('DISPOS');
  }

  void askUserForForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => CustomScaffoldOf(
        willPop: true,
        child: PomodoroForm(
          from: from,
          onSubmit: (IPomodoro item) => updatePomodoro(item),
        ),
      ),
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.2),
      enableDrag: true,
      isDismissible: true,
      isScrollControlled: true,
    );
  }

  void askUserToDelete(BuildContext context) {
    askForConfirm(
      context: context,
      title: AppLocalizations.of(context)!.delete_confirm_title,
      content: AppLocalizations.of(context)!.delete_confirm_content,
      yes: AppLocalizations.of(context)!.delete_confirm_yes,
      no: AppLocalizations.of(context)!.delete_confirm_no,
      callback: () async {
        await pomodoro.remove(index: index);
        Navigator.pop(context);
      },
    );
  }

  void updatePomodoro(IPomodoro item) async {
    try {
      setState(() => from = item);
      setDefault();
      await pomodoro.update(item, index: index);
    } catch (e) {
      log(e.toString());
    }
  }

  void setDefault({
    DateTime? start,
  }) {
    setState(() {
      dateTime = start;
      data = Data(
        from: from,
        time: dateTime,
      );
      timeItems = data.times(context);
      i = 0;
      setTimerData();
    });
  }

  void setTimerData() {
    setState(() {
      timerData = TimerData(
        end: timeItems[i].end,
        time: timeItems[i].time,
        onEnded: () => setState(() {
          print('Ended');
        }),
      );
      print('Setting time ...');
      if (timerData!.progress == 0) {
        if (i + 1 < timeItems.length) {
          i = i + 1;
          setTimerData();
        } else {
          stop();
        }
      }
    });
  }

  void start() {
    setDefault(
      start: DateTime.now(),
    );
    startTimer();
    for (int i = 0; i < timeItems.length; i++) {
      notification.show(
        id: i,
        title: timeItems[i].title,
        subtitle: timeItems[i].subtitle,
        minute: timeItems[i].minute,
      );
    }
    pomodoro.start(
      from: from,
      index: index,
      start: dateTime!,
      end: data.end,
    );
  }

  void stop() {
    setDefault();
    notification.delete();
    pomodoro.stop();
    setState(() {
      timer!.cancel();
    });
  }

  void startTimer() {
    setState(() {
      timer = Timer.periodic(Duration(minutes: 1), (_) {
        print('1 Minute');
        setTimerData();
      });
    });
  }

  void askUserToStart() {
    askForConfirm(
      context: context,
      title: AppLocalizations.of(context)!.start_title,
      content: AppLocalizations.of(context)!.start_content,
      yes: AppLocalizations.of(context)!.start,
      no: AppLocalizations.of(context)!.cancel,
      callback: () => start(),
    );
  }

  void askUserToStop() {
    askForConfirm(
      context: context,
      title: AppLocalizations.of(context)!.end_title,
      content: AppLocalizations.of(context)!.end_content,
      yes: AppLocalizations.of(context)!.end,
      no: AppLocalizations.of(context)!.cancel,
      callback: () => stop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffoldOf(
      willPop: dateTime == null,
      child: Scaffold(
        backgroundColor: Colors.red,
        body: Stack(
          children: [
            _Header(),
            CustomView(
              top: dateTime == null ? 100 : 0,
              radius: dateTime == null ? 15 : 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      height: dateTime == null ? 30 : 100,
                      duration: Duration(milliseconds: 200),
                    ),
                    _Time(
                      progress: timerData!.progress,
                      minute: timerData!.minute,
                    ),
                    CustomContent(
                      title: from.name!,
                      content: from.description!,
                      textAlign: TextAlign.center,
                      alignment: CrossAxisAlignment.center,
                      space: 12,
                    ),
                    _TimeItems(),
                    _ToggleButton(
                      onPressed: () =>
                          dateTime == null ? askUserToStart() : askUserToStop(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget _Header() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      height: 130,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
          CustomText(
            from.name!,
            color: Colors.white,
          ),
          Spacer(),
          IconButton(
            onPressed: () => askUserForForm(context),
            icon: Icon(
              Icons.edit,
              color: Colors.white,
            ),
            tooltip: AppLocalizations.of(context)!.edit,
          ),
          IconButton(
            onPressed: () => askUserToDelete(context),
            icon: Icon(
              Icons.delete,
              color: Colors.white,
            ),
            tooltip: AppLocalizations.of(context)!.delete,
          ),
        ],
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget _Time({
    required double? progress,
    required int minute,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: CircularProgressIndicator(
            value: progress == null ? 1 : progress,
            strokeWidth: 6,
            valueColor: AlwaysStoppedAnimation<Color?>(Colors.green),
          ),
        ),
        CustomText(
          minute.toString(),
          fontSize: 24,
        ),
        Positioned(
          top: 100,
          child: CustomText(
            minute == 1
                ? AppLocalizations.of(context)!.minute
                : AppLocalizations.of(context)!.minutes,
            fontSize: 14,
            color: Colors.grey[600],
          ),
        )
      ],
    );
  }

  // ignore: non_constant_identifier_names
  Widget _TimeItems() {
    return Expanded(
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowGlow();
          return false;
        },
        child: ListView(
          children: ListTile.divideTiles(
            color: Colors.grey[400],
            context: context,
            tiles: timeItems
                .skip(i)
                .map(
                  (item) => _TimeItem(
                    title: item.title,
                    subtitle: item.subtitle,
                  ),
                )
                .toList(),
          ).toList(),
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget _TimeItem({
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(
        Icons.timer,
      ),
      title: CustomText(
        title,
        fontSize: 18,
      ),
      subtitle: CustomText(
        subtitle,
        fontSize: 14,
        color: Colors.grey[600],
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget _ToggleButton({required Function onPressed}) {
    return Container(
      child: SizedBox(
        width: double.infinity,
        height: 46,
        child: ElevatedButton(
          onPressed: () => onPressed(),
          child: CustomText(
            dateTime == null
                ? AppLocalizations.of(context)!.start
                : AppLocalizations.of(context)!.end,
            color: Colors.white,
          ),
          style: ButtonStyle(
            elevation: MaterialStateProperty.all(0),
            backgroundColor: MaterialStateProperty.all(Colors.amber),
          ),
        ),
      ),
    );
  }
}

class Data {
  IPomodoro from;
  DateTime start = DateTime.now();
  DateTime end = DateTime.now();

  Data({
    required this.from,
    DateTime? time,
  }) {
    if (time != null) {
      end = time;
      start = time;
    }
  }

  List<TimeItem> times(BuildContext context) {
    List<TimeItem> items = [];

    for (int i = 0; i < this.from.period; i++) {
      items.add(
        _time(context),
      );

      if (this.from.period != 1 && i < this.from.period - 1)
        items.add(_short(context));
      else
        items.add(_long(context));
    }

    return items;
  }

  TimeItem _time(BuildContext context) {
    TimeItem item = TimeItem(
      context: context,
      type: 'time',
      now: this.start,
      start: this.end,
      end: this.end.add(Duration(minutes: this.from.time)),
      time: this.from.time,
    );

    this.end = this.end.add(Duration(minutes: this.from.time));

    return item;
  }

  TimeItem _short(BuildContext context) {
    TimeItem item = TimeItem(
      context: context,
      type: 'short',
      now: this.start,
      start: this.end,
      end: this.end.add(Duration(minutes: this.from.short)),
      time: this.from.short,
    );

    this.end = this.end.add(Duration(minutes: this.from.short));

    return item;
  }

  TimeItem _long(BuildContext context) {
    TimeItem item = TimeItem(
      context: context,
      type: 'long',
      now: this.start,
      start: this.end,
      end: this.end.add(Duration(minutes: this.from.long)),
      time: this.from.long,
    );

    this.end = this.end.add(Duration(minutes: this.from.long));

    return item;
  }
}

class TimeItem {
  late final String title;
  late final String subtitle;
  late final int time;
  late final int minute;
  late DateTime start;
  late DateTime end;

  TimeItem({
    required BuildContext context,
    required String type,
    required DateTime now,
    required this.start,
    required this.end,
    required this.time,
  }) {
    if (type == 'time')
      title = AppLocalizations.of(context)!.pomodoro_timer;
    else if (type == 'short')
      title = AppLocalizations.of(context)!.pomodoro_short_break;
    else
      title = AppLocalizations.of(context)!.pomodoro_long_break;

    subtitle =
        '${AppLocalizations.of(context)!.from} ${this._timeOf(start)} ${AppLocalizations.of(context)!.till} ${this._timeOf(end)} ${AppLocalizations.of(context)!.until} ${time.toString()} ${AppLocalizations.of(context)!.minutes}';

    Duration duration = end.difference(now);
    minute = duration.inMinutes;
  }

  String _timeOf(DateTime time) {
    return '${time.hour < 10 ? '0' + time.hour.toString() : time.hour}:${time.minute < 10 ? '0' + time.minute.toString() : time.minute}';
  }
}

class TimerData {
  late double progress = 1;
  late int minute = 0;

  TimerData({
    required DateTime end,
    required int time,
    required Function onEnded,
  }) {
    DateTime now = DateTime.now();
    now = now.add(Duration(minutes: -1));
    Duration duration = end.difference(now);
    minute = duration.inMinutes;
    double percent = ((minute * 100) / time) / 100;
    if (percent.isNaN)
      progress = 1;
    else
      progress = percent;
    if (progress == 0 && minute == 0) onEnded();
  }
}
