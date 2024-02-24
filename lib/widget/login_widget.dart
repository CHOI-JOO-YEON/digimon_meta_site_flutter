import 'package:flutter/material.dart';
import 'dart:html' as html;

import 'package:provider/provider.dart';

import '../provider/user_provider.dart';

class LoginWidget extends StatelessWidget {
  const LoginWidget({super.key});

  void openOAuthPopup() {
    String url = 'http://localhost:8080/oauth2/authorization/kakao';
    String windowName = 'OAuthLogin';
    String windowFeatures = 'width=800,height=600';
    html.window.open(url, windowName, windowFeatures);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (userProvider.nickname != null)
              ElevatedButton(
                  onPressed: () {}, child: Text(userProvider.nickname!)),
            userProvider.isLogin()
                ? Center(
                    child: ElevatedButton(
                      onPressed: () {
                        userProvider.logout();
                      },
                      child: Text('로그아웃'),
                    ),
                  )
                : Center(
                    child: ElevatedButton(
                      onPressed: () {
                        openOAuthPopup();
                      },
                      child: Text('카카오 로그인'),
                    ),
                  ),
          ],
        );
      },
    );
  }
}
