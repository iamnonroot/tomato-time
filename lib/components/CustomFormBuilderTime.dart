import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';
import 'package:pomodoro/components/CustomText.dart';

class CustomFormBuilderTime<T> extends StatefulWidget {
  final String label;
  final List<int> items;
  final int initialValue;
  final Function onChanged;
  final bool suffix;

  const CustomFormBuilderTime({
    Key? key,
    required this.label,
    required this.items,
    required this.initialValue,
    required this.onChanged,
    this.suffix = true,
  }) : super(key: key);

  @override
  _CustomFormBuilderTimeState<T> createState() => _CustomFormBuilderTimeState();
}

class _CustomFormBuilderTimeState<T> extends State<CustomFormBuilderTime<T>> {
  void setValue(int i) {
    widget.onChanged(widget.items[i]);
  }

  void lessValue() {
    if (index - 1 <= -1)
      return;
    else
      setValue(index - 1);
  }

  void moreValue() {
    if (index + 1 >= widget.items.length)
      return;
    else
      setValue(index + 1);
  }

  int get index {
    return widget.items.indexOf(widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          CustomText(widget.label),
          Spacer(),
          IconButton(
            onPressed: index == 0 ? null : () => lessValue(),
            icon: Icon(Icons.remove),
            splashRadius: 24,
          ),
          _value(),
          IconButton(
            onPressed:
                index == widget.items.length - 1 ? null : () => moreValue(),
            icon: Icon(Icons.add),
            splashRadius: 24,
          ),
        ],
      ),
    );
  }

  Widget _value() {
    return Container(
      width: 50,
      child: Column(
        children: widget.suffix
            ? [
                CustomText(
                  widget.initialValue.toString(),
                  color: Colors.grey[800],
                ),
                SizedBox(
                  height: 8,
                ),
                CustomText(
                  AppLocalizations.of(context)!.minutes,
                  fontSize: 12,
                  color: Colors.grey[500],
                )
              ]
            : [
                CustomText(
                  widget.initialValue.toString(),
                  color: Colors.grey[600],
                ),
              ],
      ),
    );
  }
}
