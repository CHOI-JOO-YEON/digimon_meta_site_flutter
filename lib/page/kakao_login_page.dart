import 'dart:convert';
import 'dart:html';

import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:digimon_meta_site_flutter/router.dart';
import 'package:flutter/material.dart';
import 'dart:js' as js;
import '../service/user_service.dart';


@RoutePage()
class KakaoLoginPage extends StatefulWidget {
  const KakaoLoginPage({super.key});

  @override
  State<KakaoLoginPage> createState() => _KakaoLoginPageState();
}

class _KakaoLoginPageState extends State<KakaoLoginPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sendAuthCode());
  }


  void _sendAuthCode() {
    final routeData = RouteData.of(context);
    String code = routeData.queryParams.getString('code');
    if (code != null) {
      js.context.callMethod('sendAuthCodeToParent', [code]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
