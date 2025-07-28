import 'package:digimon_meta_site_flutter/provider/collect_provider.dart';
import 'package:digimon_meta_site_flutter/provider/deck_sort_provider.dart';
import 'package:digimon_meta_site_flutter/provider/format_deck_count_provider.dart';
import 'package:digimon_meta_site_flutter/provider/limit_provider.dart';
import 'package:digimon_meta_site_flutter/provider/text_simplify_provider.dart';
import 'package:digimon_meta_site_flutter/provider/user_provider.dart';
import 'package:digimon_meta_site_flutter/provider/deck_provider.dart';
import 'package:digimon_meta_site_flutter/provider/header_toggle_provider.dart';
import 'package:digimon_meta_site_flutter/router.dart';
import 'package:digimon_meta_site_flutter/service/user_service.dart';
import 'package:digimon_meta_site_flutter/service/user_setting_service.dart';
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
      ChangeNotifierProvider(create: (_) => DeckProvider()),
      ChangeNotifierProvider(create: (_) => HeaderToggleProvider()),
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
    _loadUserSettings();
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

  Future<void> _loadUserSettings() async {
    try {
      // LimitProvider가 초기화될 때까지 기다림
      await Future.delayed(Duration(milliseconds: 100));
      
      final userSetting = await UserSettingService().loadUserSetting(context);
      await UserSettingService().applyUserSetting(context, userSetting);
    } catch (e) {
      print('Failed to load user settings on app start: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DGCHub',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        dialogTheme: DialogTheme(
          backgroundColor: Colors.white,
          elevation: 16.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          shadowColor: Colors.black.withOpacity(0.15),
        ),
        fontFamily: 'JalnanGothic',
        useMaterial3: true,
        primarySwatch: const MaterialColor(0xFF2563EB, {
          50: Color(0xFFEFF6FF),
          100: Color(0xFFDBEAFE),
          200: Color(0xFFBFDBFE),
          300: Color(0xFF93C5FD),
          400: Color(0xFF60A5FA),
          500: Color(0xFF3B82F6),
          600: Color(0xFF2563EB),
          700: Color(0xFF1D4ED8),
          800: Color(0xFF1E40AF),
          900: Color(0xFF1E3A8A),
        }),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
          primary: const Color(0xFF2563EB),
          secondary: const Color(0xFF7C3AED),
          surface: Colors.white,
          background: const Color(0xFFF5F7FA),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: const Color(0xFF1F2937),
          onBackground: const Color(0xFF374151),
        ),
        cardTheme: CardTheme(
          elevation: 8.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          shadowColor: Colors.black.withOpacity(0.1),
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 4.0,
            shadowColor: Colors.black.withOpacity(0.15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1F2937),
          shadowColor: Colors.black.withOpacity(0.1),
          surfaceTintColor: Colors.transparent,
          titleTextStyle: const TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'JalnanGothic',
          ),
        ),
        tabBarTheme: TabBarTheme(
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF6B7280),
          indicatorColor: const Color(0xFF2563EB),
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF2563EB),
                const Color(0xFF1D4ED8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          dividerColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          overlayColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              return Colors.transparent;
            },
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: Color(0xFF111827), 
            fontWeight: FontWeight.bold,
            fontSize: 32,
            height: 1.2,
          ),
          headlineMedium: TextStyle(
            color: Color(0xFF1F2937), 
            fontWeight: FontWeight.w700,
            fontSize: 24,
            height: 1.3,
          ),
          headlineSmall: TextStyle(
            color: Color(0xFF374151), 
            fontWeight: FontWeight.w600,
            fontSize: 20,
            height: 1.4,
          ),
          bodyLarge: TextStyle(
            color: Color(0xFF374151),
            fontSize: 16,
            height: 1.6,
          ),
          bodyMedium: TextStyle(
            color: Color(0xFF4B5563),
            fontSize: 14,
            height: 1.5,
          ),
          bodySmall: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 12,
            height: 1.4,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF6B7280),
          size: 24,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.grey.shade100,
          selectedColor: const Color(0xFF2563EB).withOpacity(0.1),
          disabledColor: Colors.grey.shade200,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
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
