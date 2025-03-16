import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';

@RoutePage()
class KeywordInfoPage extends StatelessWidget {
  // 키워드와 설명을 담은 리스트
  final List<Map<String, String>> keywords = [
    {
      'name': '보안 (Security)',
      'description': '보안 효과는 카드가 보안에서 공개되었을 때 발동합니다. 보안 효과는 상대 디지몬의 공격으로 인해 공개된 경우에만 발동합니다.'
    },
    {
      'name': '진화원 효과 (Inherited Effect)',
      'description': '진화원에 있는 카드의 효과로, 진화한 디지몬이 그 효과를 물려받습니다. 진화원 효과는 해당 디지몬이 배틀 에리어에 있을 때만 적용됩니다.'
    },
    {
      'name': '메인 (Main)',
      'description': '자신의 메인 페이즈에 발동할 수 있는 효과입니다. 턴당 1번 사용 제한이 없다면 여러 번 사용할 수 있습니다.'
    },
    {
      'name': '등장 시 (When Played)',
      'description': '카드가 배틀 에리어에 등장했을 때 발동하는 효과입니다. 카드를 플레이하거나 진화했을 때 발동합니다.'
    },
    {
      'name': '공격 선언 시 (When Attacking)',
      'description': '디지몬이 공격을 선언했을 때 발동하는 효과입니다. 상대 플레이어나 디지몬을 공격할 때 발생합니다.'
    },
    {
      'name': '상대 턴 (Opponent\'s Turn)',
      'description': '상대의 턴 동안 발동할 수 있는 효과입니다. 특별히 타이밍이 명시되어 있지 않다면 상대 턴 중 아무 때나 사용할 수 있습니다.'
    },
    {
      'name': '디지버스트 (Digibursting)',
      'description': '자신의 디지몬 아래에 있는 카드를 트래시에 놓는 비용입니다. 디지버스트 효과를 발동하기 위해 사용됩니다.'
    },
    {
      'name': '디지크로스 (DigiXros)',
      'description': '2장 이상의 디지몬을 결합하여 새로운 디지몬을 만드는 메커니즘입니다. 디지크로스에 사용된 카드들은 그 디지몬의 진화원이 됩니다.'
    },
    {
      'name': '디지조이 (Digi-Joying)',
      'description': '타이머 테이머를 속성으로 가진 카드에 적용되며, 타이머 테이머는 배틀 에리어에 있는 디지몬에 장착하여 추가 효과를 부여할 수 있습니다.'
    },
    {
      'name': '메모리 (Memory)',
      'description': '게임 리소스로, 카드 비용을 지불하거나 특정 효과를 발동할 때 사용합니다. 메모리 게이지가 상대방 쪽으로 넘어가면 턴이 종료됩니다.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '주요 키워드',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: keywords.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      keywords[index]['name']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          keywords[index]['description']!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 