
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/user_provider.dart';

class CustomHeader extends StatefulWidget {
  const CustomHeader({super.key});

  @override
  State<CustomHeader> createState() => _CustomHeaderState();
}

class _CustomHeaderState extends State<CustomHeader> {
  @override
  Widget build(BuildContext context) {
    return Row(
      // children: [
      //   Consumer<UserProvider>(
      //     builder: (context, userProvider, child) {
      //       if (userProvider.user != null) {
      //         return IconButton(
      //           icon: Icon(Icons.logout),
      //           onPressed: () {
      //             userProvider.logout();
      //           },
      //         );
      //       } else {
      //         return Consumer<AppRouterProvider>(
      //           builder: (context,provider, child) {
      //             return IconButton(
      //               icon: Icon(Icons.login),
      //               onPressed: (){ provider.setPath(AppRoutePath.login());}
      //             );
      //           }
      //         );
      //       }
      //     },
      //   ),
      // ],
    );
  }
}
