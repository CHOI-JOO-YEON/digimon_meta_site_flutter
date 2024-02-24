import 'package:auto_route/auto_route.dart';
import 'package:digimon_meta_site_flutter/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;

import 'package:provider/provider.dart';

@RoutePage()
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  void openOAuthPopup() {
    String url = 'http://localhost:8080/oauth2/authorization/kakao';
    String windowName = 'OAuthLogin';
    String windowFeatures = 'width=800,height=600';
    html.window.open(url, windowName, windowFeatures);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<UserProvider>(

        builder: (context, userProvider, child) => Column(
          children: [
            ElevatedButton(onPressed: (){}, child: Text(userProvider.nickname ?? '')),

            // userProvider.isLogin()
            //     ? Center(
            //   child: ElevatedButton(
            //     onPressed: () {
            //       userProvider.logout();
            //     },
            //     child: Text('로그아웃'),
            //   ),
            // )
            //     : Center(
            //   child: ElevatedButton(
            //     onPressed: () {
            //       openOAuthPopup();
            //     },
            //     child: Text('카카오 로그인'),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}