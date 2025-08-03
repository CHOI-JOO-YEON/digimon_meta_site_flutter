import 'package:auto_route/auto_route.dart';
import 'package:digimon_meta_site_flutter/model/deck-build.dart';
import 'package:digimon_meta_site_flutter/model/format.dart';
import 'package:digimon_meta_site_flutter/provider/user_provider.dart';
import 'package:digimon_meta_site_flutter/router.dart';
import 'package:digimon_meta_site_flutter/service/deck_service.dart';
import 'package:digimon_meta_site_flutter/service/size_service.dart';
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
    // 부모 컨텍스트를 미리 저장
    final parentContext = context;
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
                    padding: SizeService.allPadding(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 드래그 핸들
                        Center(
                          child: Container(
                            width: SizeService.largePadding(context) * 2.5,
                            height: SizeService.spacingSize(context) * 1.67,
                            margin: SizeService.customPadding(context, bottom: 3.2),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: SizeService.customRadius(context, multiplier: 0.5),
                            ),
                          ),
                        ),
                        
                        Row(
                          children: [
                            Icon(Icons.tune, 
                              color: Colors.grey[700],
                              size: SizeService.mediumIconSize(context),
                            ),
                            SizeService.horizontalSpacing(context, multiplier: 1.6),
                            Text(
                              '덱 메뉴',
                              style: TextStyle(
                                fontSize: SizeService.titleFontSize(context),
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
                      padding: SizeService.horizontalPadding(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 덱 뷰 행 수 조정 (세로모드에서만)
                          if (deckViewRowNumber != null && onRowNumberChanged != null && 
                              MediaQuery.of(context).orientation == Orientation.portrait)
                            _buildRowNumberSlider(
                              deckViewRowNumber,
                              onRowNumberChanged,
                            ),
                          
                          if (menuType == DeckMenuType.deckBuilder)
                            _buildMenuItem(
                              icon: Icons.add_box_outlined,
                              color: Colors.green[600]!,
                              title: '새로 만들기',
                              subtitle: '새로운 덱으로 시작',
                              onTap: () {
                                Navigator.pop(context);
                                if (onDeckInit != null) {
                                  // 모달이 닫힌 후 작업 수행
                                  Future.delayed(const Duration(milliseconds: 300), () {
                                    if (parentContext.mounted) {
                                      DeckService().resetDeck(parentContext, () {
                                        onDeckInit();
                                        if (parentContext.mounted) {
                                          ToastOverlay.show(parentContext, '새로운 덱이 생성되었습니다.', type: ToastType.success);
                                        }
                                      });
                                    }
                                  });
                                }
                              },
                            ),

                            if (menuType == DeckMenuType.deckBuilder)
                            _buildMenuItem(
                              icon: Icons.clear_outlined,
                              color: Colors.red[600]!,
                              title: '덱 비우기',
                              subtitle: '모든 카드 제거',
                              onTap: () {
                                Navigator.pop(context);
                                if (onDeckClear != null) {
                                  // 모달이 닫힌 후 작업 수행
                                  Future.delayed(const Duration(milliseconds: 300), () {
                                    if (parentContext.mounted) {
                                      DeckService().clearDeck(parentContext, deck, () {
                                        onDeckClear();
                                        if (parentContext.mounted) {
                                          ToastOverlay.show(parentContext, '덱이 비워졌습니다.', type: ToastType.warning);
                                        }
                                      });
                                    }
                                  });
                                }
                              },
                            ),


                            _buildMenuItem(
                            icon: Icons.copy_outlined,
                            color: Colors.blue[600]!,
                            title: '덱 복사하기',
                            subtitle: menuType == DeckMenuType.deckBuilder 
                              ? '현재 덱을 복사하여 새로 만들기'
                              : '이 덱을 복사해서 새로운 덱 만들기',
                            onTap: () {
                              Navigator.pop(context);
                              // 모달이 닫힌 후 작업 수행
                              Future.delayed(const Duration(milliseconds: 300), () {
                                if (parentContext.mounted) {
                                  if (menuType == DeckMenuType.deckBuilder && onDeckCopy != null) {
                                    DeckService().copyDeck(parentContext, deck, onCopy: onDeckCopy);
                                  } else {
                                    DeckService().copyDeck(parentContext, deck);
                                  }
                                }
                              });
                            },
                          ),
                            if (menuType == DeckMenuType.deckBuilder)                           
                            _buildMenuItem(
                              icon: Icons.save_outlined,
                              color: Colors.purple[600]!,
                              title: '덱 저장',
                              subtitle: '서버에 덱 저장',
                              onTap: () {
                                Navigator.pop(context);
                                // 모달이 닫힌 후 작업 수행
                                Future.delayed(const Duration(milliseconds: 300), () async {
                                  if (!parentContext.mounted) return;
                                  if (userProvider.isLogin) {
                                    Map<int, FormatDto> formats = await DeckService().getFormats(deck);
                                    if (parentContext.mounted) {
                                      DeckService().showSaveDialog(parentContext, formats, deck, () {
                                        if (onReload != null) onReload();
                                        if (parentContext.mounted) {
                                          ToastOverlay.show(parentContext, '덱이 저장되었습니다.', type: ToastType.success);
                                        }
                                      });
                                    }
                                  } else {
                                    if (parentContext.mounted) {
                                      ToastOverlay.show(parentContext, '로그인이 필요합니다.', type: ToastType.warning);
                                    }
                                  }
                                });
                              },
                            ),

                            if (menuType == DeckMenuType.deckBuilder)
                            _buildMenuItem(
                              icon: Icons.download_outlined,
                              color: Colors.green[600]!,
                              title: '덱 가져오기',
                              subtitle: '덱 코드/이미지에서 불러오기',
                              onTap: () {
                                Navigator.pop(context);
                                if (onDeckImport != null) {
                                  // 모달이 닫힌 후 작업 수행
                                  Future.delayed(const Duration(milliseconds: 300), () {
                                    if (parentContext.mounted) {
                                      DeckService().showImportDialog(parentContext, (deckBuild) {
                                        onDeckImport(deckBuild);
                                        if (parentContext.mounted) {
                                          ToastOverlay.show(parentContext, '덱을 가져왔습니다.', type: ToastType.success);
                                        }
                                      });
                                    }
                                  });
                                }
                              },
                            ),
                          
                          _buildMenuItem(
                            icon: Icons.upload_outlined,
                            color: Colors.purple[600]!,
                            title: '덱 내보내기',
                            subtitle: '덱 코드 내보내기',
                            onTap: () {
                              Navigator.pop(context);
                              // 모달이 닫힌 후 작업 수행
                              Future.delayed(const Duration(milliseconds: 300), () {
                                if (parentContext.mounted) {
                                  DeckService().showExportDialog(parentContext, deck);
                                }
                              });
                            },
                          ),
                          
                          _buildMenuItem(
                            icon: Icons.image_outlined,
                            color: Colors.pink[600]!,
                            title: '덱 이미지 저장',
                            subtitle: '덱을 이미지로 저장',
                            onTap: () {
                              Navigator.pop(context);
                              // 모달이 닫힌 후 네비게이션 수행
                              Future.delayed(const Duration(milliseconds: 300), () {
                                if (parentContext.mounted) {
                                  parentContext.navigateTo(DeckImageRoute(deck: deck));
                                }
                              });
                            },
                          ),
                          
                          _buildMenuItem(
                            icon: Icons.receipt_long_outlined,
                            color: Colors.teal[600]!,
                            title: '대회 제출용 레시피',
                            subtitle: '대회용 덱리스트 다운로드',
                            onTap: () {
                              Navigator.pop(context);
                              // 모달이 닫힌 후 작업 수행
                              Future.delayed(const Duration(milliseconds: 300), () {
                                if (parentContext.mounted) {
                                  DeckService().downloadDeckReceipt(parentContext, deck);
                                }
                              });
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
    return _RowNumberSlider(
      initialValue: deckViewRowNumber,
      onChanged: onRowNumberChanged,
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

class _RowNumberSlider extends StatefulWidget {
  final int initialValue;
  final Function(int) onChanged;
  
  const _RowNumberSlider({
    required this.initialValue,
    required this.onChanged,
  });
  
  @override
  _RowNumberSliderState createState() => _RowNumberSliderState();
}

class _RowNumberSliderState extends State<_RowNumberSlider> {
  late int currentValue;
  
  @override
  void initState() {
    super.initState();
    currentValue = widget.initialValue;
  }
  
  @override
  void didUpdateWidget(_RowNumberSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      currentValue = widget.initialValue;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
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
                      '$currentValue장',
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
            value: currentValue.toDouble(),
            min: 2,
            max: 8,
            divisions: 6,
            activeColor: Colors.purple[600],
            label: '$currentValue장',
            onChanged: (value) {
              setState(() {
                currentValue = value.round();
              });
              widget.onChanged(currentValue);
            },
          ),
        ],
      ),
    );
  }
}