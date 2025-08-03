import 'package:auto_route/auto_route.dart';
import 'package:digimon_meta_site_flutter/router.dart';
import 'package:digimon_meta_site_flutter/service/card_overlay_service.dart';
import 'package:digimon_meta_site_flutter/service/size_service.dart';
import 'package:flutter/material.dart';

@RoutePage()
class InfoPage extends StatelessWidget {
  final CardOverlayService _cardOverlayService = CardOverlayService();

  @override
  Widget build(BuildContext context) {
    double fontSize = SizeService.bodyFontSize(context);
    
    return AutoTabsRouter.tabBar(
      physics: const NeverScrollableScrollPhysics(),
      routes: [
        LimitInfoRoute(),
        KeywordInfoRoute(), 
        // 룰 탭은 준비 단계이므로 주석 처리
        // 향후 룰 페이지가 완성되면 활성화
        // RuleInfoRoute()
      ],
      builder: (context, child, controller) {
        controller.addListener(() {
          if (controller.indexIsChanging) {
            _cardOverlayService.removeAllOverlays();
          }
        });

        return Scaffold(
          body: Column(
            children: [
              TabBar(
                controller: controller,
                tabs: [
                  Tab(
                    icon: Icon(Icons.block),
                    text: '금지/제한',
                  ),
                  Tab(
                    icon: Icon(Icons.info_outline),
                    text: '키워드',
                  ),
                  // 향후 룰 탭이 추가될 예정
                  // Tab(
                  //   icon: Icon(Icons.rule),
                  //   text: '룰',
                  // ),
                ],
              ),
              Expanded(
                child: child,
              ),
            ],
          ),
        );
      },
    );
  }
} 