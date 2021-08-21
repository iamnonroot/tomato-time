import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';
import 'package:pomodoro/components/CustomText.dart';
import 'package:pomodoro/interface/pomodoro.dart';

class PomodoroItem extends StatefulWidget {
  final String? name;
  final String? description;
  final int time;
  final int short;
  final int long;
  final int period;
  final IPomodoro? from;
  final double margin;
  final Function? onTap;
  final Function? onLongTap;

  const PomodoroItem({
    Key? key,
    this.name,
    this.description,
    this.time = 0,
    this.short = 0,
    this.long = 0,
    this.period = 0,
    this.from,
    this.margin = 10,
    this.onTap,
    this.onLongTap,
  }) : super(key: key);

  @override
  _PomodoroItemState createState() => _PomodoroItemState();
}

class _PomodoroItemState extends State<PomodoroItem> {
  late IPomodoro pomodoro;

  @override
  void initState() {
    super.initState();

    if (widget.from == null) {
      pomodoro = new IPomodoro(
        name: widget.name,
        description: widget.description,
        time: widget.time,
        short: widget.short,
        long: widget.long,
        period: widget.period,
      );
    } else {
      pomodoro = widget.from!;
    }
  }

  @override
  Widget build(BuildContext context) {
    BorderRadius radius = BorderRadius.all(
      Radius.circular(12),
    );

    return AnimatedContainer(
      duration: Duration(
        milliseconds: 200,
      ),
      margin: EdgeInsets.all(
        widget.margin,
      ),
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 5,
            blurRadius: 20,
            offset: Offset(0, 10), // changes position of shadow
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: widget.onTap == null ? null : () => widget.onTap!(),
          onLongPress:
              widget.onLongTap == null ? null : () => widget.onLongTap!(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(
                context: context,
              ),
              _Period(
                context: context,
              ),
              _Times(
                children: [
                  _Time(
                    context: context,
                    title: AppLocalizations.of(context)!.pomodoro_timer,
                    time: pomodoro.time,
                  ),
                  _Time(
                      context: context,
                      title: AppLocalizations.of(context)!.pomodoro_short_break,
                      time: pomodoro.short,
                      bordered: true),
                  _Time(
                    context: context,
                    title: AppLocalizations.of(context)!.pomodoro_long_break,
                    time: pomodoro.long,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget _Header({required BuildContext context}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            pomodoro.name == null
                ? AppLocalizations.of(context)!.pomodoro_name
                : pomodoro.name!,
            fontSize: 18,
          ),
          SizedBox(
            height: 12,
          ),
          CustomText(
            pomodoro.description == null
                ? AppLocalizations.of(context)!.pomodoro_description
                : pomodoro.description!,
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget _Period({required BuildContext context}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 1, color: Colors.grey.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          CustomText(
            AppLocalizations.of(context)!.pomodoro_period,
            fontSize: 15,
          ),
          Spacer(),
          CustomText(
            pomodoro.period == 0
                ? AppLocalizations.of(context)!.undefined
                : pomodoro.period.toString(),
            color: Colors.grey[600],
            fontSize: pomodoro.period == 0 ? 12 : 16,
          ),
        ],
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget _Times({
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 1, color: Colors.grey.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: children,
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget _Time({
    required BuildContext context,
    required String title,
    required int time,
    bool bordered = false,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 12, 10, 12),
        decoration: BoxDecoration(
          border: bordered
              ? Border(
                  left:
                      BorderSide(width: 1, color: Colors.grey.withOpacity(0.5)),
                  right:
                      BorderSide(width: 1, color: Colors.grey.withOpacity(0.5)),
                )
              : Border(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              title,
              fontSize: 13,
              color: Colors.grey[600],
            ),
            SizedBox(
              height: 12,
            ),
            CustomText(
              time == 0
                  ? AppLocalizations.of(context)!.undefined
                  : time.toString() + ' ' + AppLocalizations.of(context)!.min,
              fontSize: 16,
            ),
          ],
        ),
      ),
    );
  }
}
