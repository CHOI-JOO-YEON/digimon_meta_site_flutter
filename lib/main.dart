import 'package:digimon_meta_site_flutter/model/user.dart';
import 'package:digimon_meta_site_flutter/provider/collect_provider.dart';
import 'package:digimon_meta_site_flutter/provider/deck_sort_provider.dart';
import 'package:digimon_meta_site_flutter/provider/format_deck_count_provider.dart';
import 'package:digimon_meta_site_flutter/provider/limit_provider.dart';
import 'package:digimon_meta_site_flutter/provider/text_simplify_provider.dart';
import 'package:digimon_meta_site_flutter/provider/user_provider.dart';
import 'package:digimon_meta_site_flutter/router.dart';
import 'package:digimon_meta_site_flutter/service/user_service.dart';
import 'package:digimon_meta_site_flutter/util/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';
import 'dart:html' as html;
import 'package:responsive_framework/responsive_framework.dart';
import 'package:digimon_meta_site_flutter/service/card_data_service.dart';
import 'package:digimon_meta_site_flutter/provider/note_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  final appRouter = AppRouter();
  WidgetsFlutterBinding.ensureInitialized();

  // 앱 시작 전 카드 데이터 초기화
  await CardDataService().initialize();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => UserProvider()),
      ChangeNotifierProvider(create: (_) => LimitProvider()),
      ChangeNotifierProvider(create: (_) => DeckSortProvider()),
      ChangeNotifierProvider(create: (_) => TextSimplifyProvider()),
      ChangeNotifierProvider(create: (_) => FormatDeckCountProvider()),
      ChangeNotifierProvider(create: (_) => NoteProvider()),
      ChangeNotifierProxyProvider<UserProvider, CollectProvider>(
        create: (_) => CollectProvider(),
        update: (_, userProvider, collectProvider) {
          if (userProvider.isLogin) {
            collectProvider?.initialize();
          } else {
            collectProvider?.clear();
          }
          return collectProvider!;
        },
      ),
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
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    listenForOAuthToken();
    DioClient().onAuthError = () {
      Provider.of<UserProvider>(context, listen: false).unAuth();
    };
    _initializeLimitProvider();
    _initializeCollectProvider();
  }

  void listenForOAuthToken() {
    html.window.addEventListener('message', (event) async {
      html.MessageEvent messageEvent = event as html.MessageEvent;
      var code = messageEvent.data['code'];
      await UserService().oauthLogin(code, context);
    });
  }

  Future<void> _initializeLimitProvider() async {
    final limitProvider = Provider.of<LimitProvider>(context, listen: false);
    await limitProvider.initialize();
  }

  Future<void> _initializeCollectProvider() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final collectProvider =
        Provider.of<CollectProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DGCHub',
      theme: ThemeData(
        scaffoldBackgroundColor: Color.fromRGBO(245, 245, 245, 1),
        dialogTheme: DialogTheme(
            backgroundColor: Color.fromRGBO(220, 221, 231, 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            )),
        fontFamily: 'JalnanGothic',
        primarySwatch: const MaterialColor(0xFF1A237E, {
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
          primarySwatch: const MaterialColor(0xFF1A237E, {
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
          accentColor: const Color(0xFFFF6B00),
          backgroundColor: const Color(0xFFF5F5F5),
          cardColor: const Color(0xFFFFFFFF),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(color: Color(0xFF1A237E)),
          headlineMedium: TextStyle(color: Color(0xFF303F9F)),
          headlineSmall: TextStyle(color: Color(0xFF1A237E)),
          bodyLarge: TextStyle(color: Color(0xFF000000)),
        ),
      ),
      routerConfig: widget.router.config(),
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: [
          const Breakpoint(start: 0, end: 480, name: MOBILE),
          const Breakpoint(start: 481, end: 800, name: TABLET),
          const Breakpoint(start: 801, end: 1920, name: DESKTOP),
          const Breakpoint(start: 1920, end: double.infinity, name: '4K'),
        ],
      ),
    );
  }
}
