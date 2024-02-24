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
      routerConfig: widget.router.config(),
    );
  }


}
