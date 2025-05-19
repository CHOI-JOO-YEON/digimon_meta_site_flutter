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
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  final appRouter = AppRouter();
  WidgetsFlutterBinding.ensureInitialized();

  // 웹 플랫폼에서 렌더링 방식 설정
  if (kIsWeb) {
    // 텍스트 선택 관련 웹 렌더링 설정
    debugPaintLayerBordersEnabled = false;
    // 최신 Flutter 버전에서는 다음 API가 변경됨
    // 웹 렌더링 성능 최적화 설정
  }

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
    listenForLogoutEvent();
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
      if (code != null) {
        await UserService().oauthLogin(code, context);
      }
    });
  }

  void listenForLogoutEvent() {
    html.window.addEventListener('message', (event) async {
      html.MessageEvent messageEvent = event as html.MessageEvent;
      var logoutSuccess = messageEvent.data['logout_success'];
      if (logoutSuccess == true) {
        Provider.of<UserProvider>(context, listen: false).unAuth();
      }
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
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        dialogTheme: DialogTheme(
            backgroundColor: const Color(0xFFECEFF1),
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            )),
        fontFamily: 'JalnanGothic',
        primarySwatch: const MaterialColor(0xFF1565C0, {
          50: Color(0xFFE3F2FD),
          100: Color(0xFFBBDEFB),
          200: Color(0xFF90CAF9),
          300: Color(0xFF64B5F6),
          400: Color(0xFF42A5F5),
          500: Color(0xFF2196F3),
          600: Color(0xFF1E88E5),
          700: Color(0xFF1976D2),
          800: Color(0xFF1565C0),
          900: Color(0xFF0D47A1),
        }),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: const MaterialColor(0xFF1565C0, {
            50: Color(0xFFE3F2FD),
            100: Color(0xFFBBDEFB),
            200: Color(0xFF90CAF9),
            300: Color(0xFF64B5F6),
            400: Color(0xFF42A5F5),
            500: Color(0xFF2196F3),
            600: Color(0xFF1E88E5),
            700: Color(0xFF1976D2),
            800: Color(0xFF1565C0),
            900: Color(0xFF0D47A1),
          }),
          accentColor: const Color(0xFFFF5722),
          backgroundColor: const Color(0xFFF8F9FA),
          cardColor: const Color(0xFFFFFFFF),
          brightness: Brightness.light,
        ),
        cardTheme: CardTheme(
          elevation: 3.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          shadowColor: Colors.black.withOpacity(0.2),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 2.0,
          backgroundColor: Color(0xFF1565C0),
          foregroundColor: Colors.white,
        ),
        tabBarTheme: const TabBarTheme(
          labelColor: Color(0xFF1565C0),
          unselectedLabelColor: Color(0xFF78909C),
          indicatorColor: Color(0xFF1565C0),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(color: Color(0xFF0D47A1), fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.w600),
          headlineSmall: TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: Color(0xFF37474F)),
          bodyMedium: TextStyle(color: Color(0xFF455A64)),
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
