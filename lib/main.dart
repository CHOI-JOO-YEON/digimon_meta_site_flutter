
import 'package:digimon_meta_site_flutter/provider/user_provider.dart';
import 'package:digimon_meta_site_flutter/router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';

// void main() {
//   setPathUrlStrategy();
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (context) => UserProvider()),
//         // ChangeNotifierProvider(create: (context) => PageNotifier()),
//       ],
//       child: Builder(  // Builder를 사용하여 새로운 context를 생성합니다.
//         builder: (context) {
//           return MaterialApp.router(
//             routerDelegate: AppRouterDelegate(),
//             routeInformationParser: AppRouteInformationParser(),
//           );
//         },
//       ),
//     );
//   }
// }

void main() {
  setPathUrlStrategy();
  final appRouter = AppRouter();
  runApp(MyApp(router: appRouter));
}

class MyApp extends StatelessWidget {
  final AppRouter router;

  MyApp({required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router.config(),
    );
  }
}
