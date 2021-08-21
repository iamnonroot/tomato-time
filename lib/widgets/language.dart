import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';
import 'package:pomodoro/components/CustomText.dart';
import 'package:pomodoro/components/CustomView.dart';
import 'package:pomodoro/database/langauges.dart';
import 'package:pomodoro/interface/language.dart';
import 'package:pomodoro/services/settings.dart';
import 'package:provider/provider.dart';

class LanguageBottomSheetWidget extends StatefulWidget {
  final bool closeable;

  LanguageBottomSheetWidget({
    Key? key,
    this.closeable = false,
  }) : super(key: key);

  @override
  _LanguageBottomSheetWidgetState createState() =>
      _LanguageBottomSheetWidgetState();
}

class _LanguageBottomSheetWidgetState extends State<LanguageBottomSheetWidget> {
  int i = -1; // but index

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
    ));
  }

  void close() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    Radius radius = Radius.circular(16);

    return Consumer<SettingsProvider>(
      builder: (BuildContext context, SettingsProvider settings, _) {
        int index = languages.indexWhere(
          (item) => item.code == settings.locale.languageCode,
        );
        return CustomView(
          top: 70,
          radius: 15,
          closeable: widget.closeable,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(
                height: 280,
                color: Colors.grey[200],
                radius: radius,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
                child: CustomText(
                  AppLocalizations.of(context)!.i_speak,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              _Language(
                languages[index],
              ),
              Divider(),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
                child: CustomText(
                  AppLocalizations.of(context)!.but_my_language_is,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              _Languages(
                index: index,
              ),
              _KeepGoing(
                onPressed: () async {
                  close();
                  if (index != i && i != -1) {
                    String code = languages[i].code;
                    settings.setLocale(Locale(code));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ignore: non_constant_identifier_names
  Widget _Header({
    double height = 200,
    double width = double.infinity,
    Color? color = Colors.grey,
    Radius radius = Radius.zero,
  }) {
    return Container(
      height: height,
      width: width,
      padding: EdgeInsets.fromLTRB(30, 0, 30, 30),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topLeft: radius,
          topRight: radius,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CustomText(
            AppLocalizations.of(context)!.language_modal_title,
            fontSize: 36,
            lineHeight: 1.3,
          ),
          SizedBox(
            height: 12,
          ),
          CustomText(
            AppLocalizations.of(context)!.language_modal_subtitle,
            lineHeight: 1.5,
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget _Languages({
    required int index,
  }) {
    return Expanded(
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: languages.length,
        itemBuilder: (BuildContext context, int i) => _Language(
          languages[i],
          index: i,
          selected: (this.i == -1 && i == index) || (this.i == i),
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget _Language(
    ILanguage language, {
    int index = -1,
    bool selected = false,
  }) {
    return ListTile(
      onTap: index == -1
          ? null
          : () => setState(() {
                this.i = index;
              }),
      leading: Container(
        child: Image.asset('lib/assets/languages/${language.flag}.png'),
        margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
        width: 36,
      ),
      title: CustomText(
        language.name,
      ),
      subtitle: CustomText(
        language.translate,
        color: Colors.grey[600],
        fontSize: 14,
      ),
      trailing: selected
          ? Icon(
              Icons.done,
              color: Colors.greenAccent[700],
            )
          : null,
    );
  }

  // ignore: non_constant_identifier_names
  Widget _KeepGoing({required Function onPressed}) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: SizedBox(
        width: double.infinity,
        height: 46,
        child: ElevatedButton(
          onPressed: () => onPressed(),
          child: CustomText(
            AppLocalizations.of(context)!.keep_going,
            color: Colors.white,
          ),
          style: ButtonStyle(
            elevation: MaterialStateProperty.all(0),
            backgroundColor: MaterialStateProperty.all(Colors.red),
          ),
        ),
      ),
    );
  }
}
