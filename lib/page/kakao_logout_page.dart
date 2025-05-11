import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'dart:js' as js;

@RoutePage()
class KakaoLogoutPage extends StatefulWidget {
  const KakaoLogoutPage({super.key});

  @override
  State<KakaoLogoutPage> createState() => _KakaoLogoutPageState();
}

class _KakaoLogoutPageState extends State<KakaoLogoutPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sendLogoutSuccess());
  }

  void _sendLogoutSuccess() {
    // sendLogoutSuccessToParent 함수 호출 (index.html에 정의됨)
    js.context.callMethod('sendLogoutSuccessToParent', [true]);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('로그아웃 처리 중...', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
} 