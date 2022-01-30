import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro/services/settings.dart';
import 'package:pomodoro/services/notification.dart' as notification;
// Widgets
import 'package:pomodoro/widgets/splash.dart';
import 'package:pomodoro/widgets/home.dart';
import 'package:pomodoro/widgets/item.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await notification.initialize();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (BuildContext context, SettingsProvider settings, _) =>
            materialApp(
          context: context,
          locale: settings.locale,
        ),
      ),
    ),
  );
}

MaterialApp materialApp({
  required BuildContext context,
  required Locale locale,
}) {
  return MaterialApp(
    title: AppLocalizations.of(context) != null
        ? AppLocalizations.of(context)!.app_name
        : 'Pomodoro',
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: ThemeData(
      fontFamily: locale.languageCode,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: Colors.red,
        secondary: Colors.amber,
      ),
    ),
    initialRoute: 'splash',
    onGenerateRoute: (RouteSettings settings) {
      var routes = <String, WidgetBuilder>{
        'splash': (_) => SplashScreen(),
        'home': (_) => Home(),
        'item': (_) => Item(arguments: settings.arguments!),
      };
      WidgetBuilder? builder = routes[settings.name];
      return MaterialPageRoute(builder: (ctx) => builder!(ctx));
    },
  );
}
