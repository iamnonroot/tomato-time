import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';
import 'package:pomodoro/interface/language.dart';
import 'package:pomodoro/core/storage.dart' as storage;
import 'package:pomodoro/database/langauges.dart';
import 'package:pomodoro/components/CustomScaffoldOf.dart';
import 'package:pomodoro/components/CustomContent.dart';
import 'package:pomodoro/components/CustomText.dart';
import 'package:pomodoro/components/CustomView.dart';
import 'package:pomodoro/widgets/language.dart';

class SettingsBottomSheetWidget extends StatefulWidget {
  const SettingsBottomSheetWidget({Key? key}) : super(key: key);

  @override
  _SettingsBottomSheetWidgetState createState() =>
      _SettingsBottomSheetWidgetState();
}

class _SettingsBottomSheetWidgetState extends State<SettingsBottomSheetWidget> {
  bool openedModal = false;

  ILanguage? language;

  @override
  void initState() {
    super.initState();

    init();
  }

  Future<void> init() async {
    String? locale = await storage.getItem('locale');

    setState(() {
      language = languages.firstWhere(
        (item) => item.code == (locale == null ? 'en' : locale),
      );
    });
  }

  void askUserForLanguage(BuildContext context) {
    setState(() => openedModal = true);
    showModalBottomSheet(
      context: context,
      builder: (context) => CustomScaffoldOf(
        willPop: true,
        child: LanguageBottomSheetWidget(
          closeable: true,
        ),
      ),
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.2),
      enableDrag: true,
      isDismissible: true,
      isScrollControlled: true,
    ).then((_) {
      setState(() => openedModal = false);

      init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomView(
      top: openedModal ? 40 : 70,
      radius: 15,
      closeable: true,
      child: Column(
        children: [
          CustomContent(
            title: AppLocalizations.of(context)!.settings,
            content: AppLocalizations.of(context)!.settings_subtitle,
          ),
          language == null ? Container() : _LanguageItem(),
        ],
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget _LanguageItem() {
    return ListTile(
      onTap: () => askUserForLanguage(context),
      leading: Container(
        child: Image.asset('lib/assets/languages/${language!.flag}.png'),
        margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
        width: 36,
      ),
      title: CustomText(
        AppLocalizations.of(context)!.your_language,
      ),
      subtitle: CustomText(
        language!.translate,
        color: Colors.grey[600],
        fontSize: 14,
      ),
      trailing: Icon(Icons.chevron_right),
    );
  }
}
