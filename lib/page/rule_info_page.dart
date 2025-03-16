import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';

@RoutePage()
class RuleInfoPage extends StatelessWidget {
  final List<Map<String, dynamic>> rules = [
    {
      'title': '게임의 목표',
      'content': '상대방의 보안 카드를 모두 제거하고 추가 공격을 성공시켜 승리하는 것이 게임의 목표입니다.',
    },
    {
      'title': '게임 준비',
      'content': '각 플레이어는 50장으로 구성된 덱과 5장의 보안 카드를 가지고 시작합니다. 선공 플레이어는 5장, 후공 플레이어는 6장의 카드를 드로우합니다.',
    },
    {
      'title': '게임 흐름',
      'content': '''
게임은 다음 순서로 진행됩니다:

1. 드로우 페이즈: 자신의 턴 시작에 카드 1장을 드로우합니다.
2. 테이머 페이즈: 테이머 카드를 플레이할 수 있습니다.
3. 디지몬 진화 페이즈: 디지몬을 진화시킬 수 있습니다.
4. 메인 페이즈: 디지몬 및 옵션 카드를 플레이하고, 메인 효과를 사용할 수 있습니다.
5. 공격 페이즈: 디지몬으로 상대방을 공격할 수 있습니다.
6. 메모리 체크: 메모리 게이지를 확인하고, 3 이상 상대방 쪽에 있다면 턴을 종료합니다.
      ''',
    },
    {
      'title': '카드 종류',
      'content': '''
디지몬 카드 게임에는 다음과 같은 종류의 카드가 있습니다:

1. 디지타마: 부화 영역에서 시작하는 카드로, 자신의 턴에 디지몬으로 진화시킬 수 있습니다.
2. 디지몬: 게임의 주요 유닛으로, 상대방을 공격할 수 있습니다.
3. 테이머: 디지몬에 추가 효과를 부여하는 서포트 카드입니다.
4. 옵션: 다양한 효과를 가진 일회성 카드입니다.
      ''',
    },
    {
      'title': '메모리 게이지',
      'content': '메모리 게이지는 게임의 자원을 표시하는 중요한 요소입니다. 카드를 플레이하거나 효과를 사용할 때 메모리를 소비합니다. 메모리 게이지가 상대방 쪽으로 3 이상 이동하면 턴이 종료됩니다.',
    },
    {
      'title': '보안 공격',
      'content': '디지몬으로 상대방의 보안 카드를 공격할 수 있습니다. 공격이 성공하면 상대방의 보안 카드가 공개되고, 보안 효과가 있다면 발동합니다. 모든 보안 카드가 제거된 후 추가 공격이 성공하면 게임에서 승리합니다.',
    },
    {
      'title': '디지몬 진화',
      'content': '손에 있는 디지몬 카드를 배틀 에리어에 있는 디지몬에 겹쳐 놓아 진화시킬 수 있습니다. 진화 시 진화 비용만큼 메모리를 소비하며, 진화하면 새로운 효과를 얻고 등장 시 효과를 발동시킬 수 있습니다.',
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
              '게임 룰',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rules.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      rules[index]['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          rules[index]['content'],
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