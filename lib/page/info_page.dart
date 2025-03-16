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
        // KeywordInfoRoute와 RuleInfoRoute는 미완성이므로 임시로 숨김
        // KeywordInfoRoute(), 
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
                  // 미완성 페이지이므로 탭에서도 숨김
                  // Tab(
                  //   icon: Icon(Icons.info_outline),
                  //   text: '키워드',
                  // ),
                  // Tab(
                  //   icon: Icon(Icons.rule),
                  //   text: '룰',
                  // ),
                ],
                // TabBar가 앱바 밖에 있으므로 라벨 색상을 수동으로 설정
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Theme.of(context).primaryColor,
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