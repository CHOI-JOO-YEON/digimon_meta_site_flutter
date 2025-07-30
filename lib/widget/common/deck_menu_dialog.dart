import 'package:auto_route/auto_route.dart';
import 'package:digimon_meta_site_flutter/model/deck-build.dart';
import 'package:digimon_meta_site_flutter/model/format.dart';
import 'package:digimon_meta_site_flutter/provider/user_provider.dart';
import 'package:digimon_meta_site_flutter/router.dart';
import 'package:digimon_meta_site_flutter/service/deck_service.dart';
import 'package:digimon_meta_site_flutter/widget/common/toast_overlay.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum DeckMenuType {
  deckList,
  deckBuilder,
}

class DeckMenuDialog {
  static void show({
    required BuildContext context,
    required DeckBuild deck,
    required DeckMenuType menuType,
    int? deckViewRowNumber,
    Function(int)? onRowNumberChanged,
    Function()? onDeckInit,
    Function()? onDeckClear,
    Function(DeckBuild)? onDeckImport,
    Function()? onDeckCopy,
    Function()? onReload,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 고정 헤더 (드래그 핸들 + 제목)
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 드래그 핸들
                        Center(
                          child: Container(
                            width: 50,
                            height: 5,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2.5),
                            ),
                          ),
                        ),
                        
                        Row(
                          children: [
                            Icon(Icons.tune, color: Colors.grey[700]),
                            const SizedBox(width: 8),
                            Text(
                              '덱 메뉴',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // 스크롤 가능한 메뉴 리스트
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 덱 뷰 행 수 조정 (공통)
                          if (deckViewRowNumber != null && onRowNumberChanged != null)
                            _buildRowNumberSlider(
                              deckViewRowNumber,
                              onRowNumberChanged,
                            ),
                          
                          // 덱빌더 전용 메뉴
                          if (menuType == DeckMenuType.deckBuilder) ...[
                            _buildMenuItem(
                              icon: Icons.add_box_outlined,
                              color: Colors.green[600]!,
                              title: '새로 만들기',
                              subtitle: '새로운 덱으로 시작',
                              onTap: () {
                                Navigator.pop(context);
                                if (onDeckInit != null) {
                                  DeckService().resetDeck(context, () {
                                    onDeckInit();
                                    ToastOverlay.show(context, '새로운 덱이 생성되었습니다.', type: ToastType.success);
                                  });
                                }
                              },
                            ),
                            
                            _buildMenuItem(
                              icon: Icons.clear_outlined,
                              color: Colors.red[600]!,
                              title: '덱 비우기',
                              subtitle: '모든 카드 제거',
                              onTap: () {
                                Navigator.pop(context);
                                if (onDeckClear != null) {
                                  DeckService().clearDeck(context, deck, () {
                                    onDeckClear();
                                    ToastOverlay.show(context, '덱이 비워졌습니다.', type: ToastType.warning);
                                  });
                                }
                              },
                            ),
                            
                            _buildMenuItem(
                              icon: Icons.save_outlined,
                              color: Colors.purple[600]!,
                              title: '덱 저장',
                              subtitle: '서버에 덱 저장',
                              onTap: () async {
                                Navigator.pop(context);
                                if (userProvider.isLogin) {
                                  Map<int, FormatDto> formats = await DeckService().getFormats(deck);
                                  DeckService().showSaveDialog(context, formats, deck, () {
                                    if (onReload != null) onReload();
                                    ToastOverlay.show(context, '덱이 저장되었습니다.', type: ToastType.success);
                                  });
                                } else {
                                  ToastOverlay.show(context, '로그인이 필요합니다.', type: ToastType.warning);
                                }
                              },
                            ),
                            
                            _buildMenuItem(
                              icon: Icons.download_outlined,
                              color: Colors.green[600]!,
                              title: '덱 가져오기',
                              subtitle: '파일에서 덱 불러오기',
                              onTap: () {
                                Navigator.pop(context);
                                if (onDeckImport != null) {
                                  DeckService().showImportDialog(context, (deckBuild) {
                                    onDeckImport(deckBuild);
                                    ToastOverlay.show(context, '덱을 가져왔습니다.', type: ToastType.success);
                                  });
                                }
                              },
                            ),
                          ],
                          
                          // 공통 메뉴
                          _buildMenuItem(
                            icon: Icons.copy_outlined,
                            color: Colors.blue[600]!,
                            title: '덱 복사하기',
                            subtitle: menuType == DeckMenuType.deckBuilder 
                              ? '현재 덱을 복사하여 새로 만들기'
                              : '이 덱을 복사해서 새로운 덱 만들기',
                            onTap: () {
                              Navigator.pop(context);
                              if (menuType == DeckMenuType.deckBuilder && onDeckCopy != null) {
                                DeckService().copyDeck(context, deck, onCopy: onDeckCopy);
                              } else {
                                DeckService().copyDeck(context, deck);
                              }
                            },
                          ),
                          
                          _buildMenuItem(
                            icon: Icons.upload_outlined,
                            color: Colors.purple[600]!,
                            title: '덱 내보내기',
                            subtitle: '파일로 내보내기',
                            onTap: () {
                              Navigator.pop(context);
                              DeckService().showExportDialog(context, deck);
                            },
                          ),
                          
                          _buildMenuItem(
                            icon: Icons.image_outlined,
                            color: Colors.pink[600]!,
                            title: '덱 이미지 저장',
                            subtitle: '덱을 이미지로 저장',
                            onTap: () {
                              Navigator.pop(context);
                              context.navigateTo(DeckImageRoute(deck: deck));
                            },
                          ),
                          
                          _buildMenuItem(
                            icon: Icons.receipt_long_outlined,
                            color: Colors.teal[600]!,
                            title: '대회 제출용 레시피',
                            subtitle: '대회용 덱리스트 다운로드',
                            onTap: () {
                              Navigator.pop(context);
                              DeckService().downloadDeckReceipt(context, deck);
                            },
                          ),
                          
                          // 덱리스트 전용 메뉴
                          if (menuType == DeckMenuType.deckList)
                            _buildMenuItem(
                              icon: Icons.gamepad_outlined,
                              color: Colors.green[600]!,
                              title: '플레이그라운드',
                              subtitle: '게임 시뮬레이션으로 테스트',
                              onTap: () {
                                Navigator.pop(context);
                                context.navigateTo(GamePlayGroundRoute(deckBuild: deck));
                              },
                            ),
                          
                          // TTS 파일 내보내기 (관리자만, 양쪽 모두)
                          if (userProvider.hasManagerRole())
                            _buildMenuItem(
                              icon: Icons.videogame_asset_outlined,
                              color: Colors.indigo[600]!,
                              title: 'TTS 파일 내보내기',
                              subtitle: 'Table Top Simulator용 파일',
                              onTap: () async {
                                Navigator.pop(context);
                                await DeckService().exportToTTSFile(deck);
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildRowNumberSlider(
    int deckViewRowNumber,
    Function(int) onRowNumberChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.view_column, color: Colors.purple[600], size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '한 줄에 표시할 카드 장수',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${deckViewRowNumber}장',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Slider(
                value: deckViewRowNumber.toDouble(),
                min: 2,
                max: 8,
                divisions: 6,
                activeColor: Colors.purple[600],
                label: '${deckViewRowNumber}장',
                onChanged: (value) {
                  setState(() {
                    onRowNumberChanged(value.round());
                  });
                },
              ),
            ],
          );
        },
      ),
    );
  }

  static Widget _buildMenuItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}