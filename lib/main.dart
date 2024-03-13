import 'package:digimon_meta_site_flutter/model/user.dart';
import 'package:digimon_meta_site_flutter/provider/user_provider.dart';
import 'package:digimon_meta_site_flutter/router.dart';
import 'package:digimon_meta_site_flutter/service/user_service.dart';
import 'package:digimon_meta_site_flutter/util/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';
import 'dart:html' as html;

Future<void> main() async {
  setPathUrlStrategy();
  final appRouter = AppRouter();
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => UserProvider()),
    ],
    child: MyApp(
      router: appRouter,
    ),
  ));
}

class MyApp extends StatefulWidget {
  final AppRouter router;

  const MyApp({
    super.key,
    required this.router,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    listenForOAuthToken();
    DioClient().onAuthError = () {
      Provider.of<UserProvider>(context, listen: false).unAuth();
    };
  }
  void listenForOAuthToken() {
    html.window.addEventListener('message', (event) async {
      html.MessageEvent messageEvent = event as html.MessageEvent;
      var code = messageEvent.data['code'];
      await UserService().oauthLogin(code, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Digimon-Meta',
      theme: ThemeData(
       fontFamily: 'JalnanGothic',
        primarySwatch: MaterialColor(0xFF1A237E, {
          50: Color(0xFFE8EAF6),
          100: Color(0xFFC5CAE9),
          200: Color(0xFF9FA8DA),
          300: Color(0xFF7986CB),
          400: Color(0xFF5C6BC0),
          500: Color(0xFF3F51B5),
          600: Color(0xFF3949AB),
          700: Color(0xFF303F9F),
          800: Color(0xFF283593),
          900: Color(0xFF1A237E),
        }),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: MaterialColor(0xFF1A237E, {
            50: Color(0xFFE8EAF6),
            100: Color(0xFFC5CAE9),
            200: Color(0xFF9FA8DA),
            300: Color(0xFF7986CB),
            400: Color(0xFF5C6BC0),
            500: Color(0xFF3F51B5),
            600: Color(0xFF3949AB),
            700: Color(0xFF303F9F),
            800: Color(0xFF283593),
            900: Color(0xFF1A237E),
          }),
          accentColor: Color(0xFFFF6B00),
          backgroundColor: Color(0xFFF5F5F5),
          cardColor: Color(0xFFFFFFFF),
        ),
        textTheme: TextTheme(
          headline1: TextStyle(color: Color(0xFF1A237E)),
          headline2: TextStyle(color: Color(0xFF3949AB)),
          headline3: TextStyle(color: Color(0xFF303F9F)),
          headline4: TextStyle(color: Color(0xFF283593)),
          headline5: TextStyle(color: Color(0xFF1A237E)),
          headline6: TextStyle(color: Color(0xFF1A237E)),
          bodyText1: TextStyle(color: Color(0xFF000000)),
          bodyText2: TextStyle(color: Color(0xFF000000)),
        ),
      ),
      routerConfig: widget.router.config(),
    );
  }


}
