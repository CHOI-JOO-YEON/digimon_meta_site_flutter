import 'package:digimon_meta_site_flutter/service/card_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:auto_route/auto_route.dart';
import '../model/deck-build.dart';
import '../model/locale_card_data.dart';
import '../provider/text_simplify_provider.dart';
import '../service/color_service.dart';
import '../state/game_state.dart';
import '../widget/card/game/deck_area.dart';
import '../widget/card/game/field_area_widget.dart';
import '../widget/card/game/hand_area.dart';
import '../widget/card/game/memory_gauge.dart';
import '../widget/card/game/razing_zone_widget.dart';
import '../widget/card/game/security_stack_area.dart';
import '../widget/card/game/show_cards_widget.dart';
import '../widget/card/game/trash_area.dart';

@RoutePage()
class GamePlayGroundPage extends StatefulWidget {
  final DeckBuild deckBuild;

  const GamePlayGroundPage({super.key, required this.deckBuild});

  @override
  State<GamePlayGroundPage> createState() => _GamePlayGroundPageState();
}

class _GamePlayGroundPageState extends State<GamePlayGroundPage> {
  @override
  void initState() {
    super.initState();
    // 가로모드로 고정
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // 앱 종료 시 orientation 제한 해제
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  // 반응형 계산을 위한 유틸리티 메서드들
  Map<String, dynamic> _calculateResponsiveDimensions(BoxConstraints constraints) {
    final screenWidth = constraints.maxWidth;
    final screenHeight = constraints.maxHeight;
    
    // 화면 크기에 따른 breakpoint 설정
    bool isSmallScreen = screenWidth < 1200;
    bool isMediumScreen = screenWidth >= 1200 && screenWidth < 1600;
    bool isLargeScreen = screenWidth >= 1600;
    
    // 패딩 계산
    double padding = screenWidth * 0.01;
    
    // 화면 크기에 따른 게임 영역 비율 조정
    Map<String, int> gameAreaFlexRatios;
    Map<String, int> gameAreaRowFlexRatios;
    int fieldColumns;
    
    if (isSmallScreen) {
      // 작은 화면: 컴팩트한 레이아웃
      gameAreaFlexRatios = {
        'memory': 1,
        'main': 8,
      };
      gameAreaRowFlexRatios = {
        'left': 3,    // Security + Razing 영역 늘림
        'center': 6,  // Field + Hand 영역 축소
        'right': 3,   // Deck + Trash 영역 늘림
      };
      fieldColumns = 4; // 필드 컬럼 수 줄임
    } else if (isMediumScreen) {
      // 중간 화면: 균형잡힌 레이아웃
      gameAreaFlexRatios = {
        'memory': 1,
        'main': 8,
      };
      gameAreaRowFlexRatios = {
        'left': 2,
        'center': 8,
        'right': 2,
      };
      fieldColumns = 6; // 필드 컬럼 수 중간
    } else {
      // 큰 화면: 원래 레이아웃
      gameAreaFlexRatios = {
        'memory': 1,
        'main': 8,
      };
      gameAreaRowFlexRatios = {
        'left': 2,
        'center': 8,
        'right': 2,
      };
      fieldColumns = 8; // 필드 컬럼 수 최대
    }
    
    // 카드 크기 계산 (화면 크기 기반)
    double cardWidth;
    if (isSmallScreen) {
      cardWidth = screenWidth * 0.08; // 화면 너비의 8% (거의 2배 증가)
    } else if (isMediumScreen) {
      cardWidth = screenWidth * 0.07; // 화면 너비의 7% (거의 2배 증가)
    } else {
      cardWidth = screenWidth * 0.06; // 화면 너비의 6% (거의 2배 증가)
    }
    
    // 최소/최대 카드 크기 제한 (더 큰 범위로 조정)
    cardWidth = cardWidth.clamp(50.0, 120.0);
    
    // 폰트 크기 계산 (반응형) - 카드 크기 증가에 맞춰 조정
    double fontSize;
    if (isSmallScreen) {
      fontSize = screenWidth * 0.018; // 1.5배 증가
    } else if (isMediumScreen) {
      fontSize = screenWidth * 0.015; // 1.5배 증가
    } else {
      fontSize = screenWidth * 0.013; // 1.4배 증가
    }
    
    // 최소/최대 폰트 크기 제한 (더 큰 범위로 조정)
    fontSize = fontSize.clamp(12.0, 24.0);
    
    // 필드와 핸드 영역의 세로 비율 계산
    Map<String, int> centerAreaVerticalRatios;
    if (isSmallScreen) {
      centerAreaVerticalRatios = {
        'field': 5,  // 필드 영역 비율
        'hand': 2,   // 핸드 영역 비율 증가
      };
    } else if (isMediumScreen) {
      centerAreaVerticalRatios = {
        'field': 6,  // 필드 영역 비율
        'hand': 2,   // 핸드 영역 비율 약간 증가
      };
    } else {
      centerAreaVerticalRatios = {
        'field': 3,  // 필드 영역 비율 (원래)
        'hand': 1,   // 핸드 영역 비율 (원래)
      };
    }

    return {
      'cardWidth': cardWidth,
      'fontSize': fontSize,
      'padding': padding,
      'gameAreaFlexRatios': gameAreaFlexRatios,
      'gameAreaRowFlexRatios': gameAreaRowFlexRatios,
      'centerAreaVerticalRatios': centerAreaVerticalRatios,
      'fieldColumns': fieldColumns,
      'isSmallScreen': isSmallScreen,
      'isMediumScreen': isMediumScreen,
      'isLargeScreen': isLargeScreen,
    };
  }

  void _showResetConfirmDialog(BuildContext context, GameState gameState) {
    // 게임이 진행되지 않은 상태(undo가 불가능한 상태)라면 바로 초기화
    if (gameState.undoStack.isEmpty && gameState.redoStack.isEmpty) {
      gameState.init(widget.deckBuild);
      return;
    }
    
    // 게임이 진행된 상태라면 컨펌 창 띄우기
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('초기화 확인'),
          content: const Text('정말로 게임을 초기화하시겠습니까?\n모든 진행 상황이 삭제됩니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                gameState.init(widget.deckBuild);
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameState(widget.deckBuild),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('플레이그라운드'),
        ),
        body: OrientationBuilder(
          builder: (context, orientation) {
            // 세로모드일 때 경고 메시지 표시
            if (orientation == Orientation.portrait) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.screen_rotation,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '가로모드에서만 사용할 수 있습니다',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '화면을 회전시켜 주세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }
            
            // 가로모드일 때 게임 화면 표시
            return LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final dimensions = _calculateResponsiveDimensions(constraints);
                final gameState = Provider.of<GameState>(context);
                
                int selectedLocaleIndex = 0;
                LocaleCardData? localeCardData = gameState
                    .getSelectedCard()
                    ?.localeCardData[selectedLocaleIndex];
                    
                return Container(
                  color: Theme.of(context).cardColor,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 좌측 패널 (카드 정보)
                      Expanded(
                        flex: dimensions['isSmallScreen'] ? 3 : (dimensions['isMediumScreen'] ? 2 : 1),
                        child: Padding(
                          padding: EdgeInsets.all(dimensions['padding']!),
                          child: Column(
                            children: [
                              // 컨트롤 버튼들
                              Container(
                                decoration: const BoxDecoration(),
                                child: Row(
                                  children: [
                                    _buildControlButton(
                                      icon: Icons.undo,
                                      onPressed: () => gameState.undo(),
                                      tooltip: '뒤로',
                                      isEnabled: gameState.undoStack.isNotEmpty,
                                      iconSize: gameState.iconWidth(dimensions['cardWidth']!),
                                    ),
                                    _buildControlButton(
                                      icon: Icons.redo,
                                      onPressed: () => gameState.redo(),
                                      tooltip: '앞으로',
                                      isEnabled: gameState.redoStack.isNotEmpty,
                                      iconSize: gameState.iconWidth(dimensions['cardWidth']!),
                                    ),
                                    _buildControlButton(
                                      icon: Icons.refresh,
                                      onPressed: () => _showResetConfirmDialog(context, gameState),
                                      tooltip: '초기화',
                                      isEnabled: true,
                                      iconSize: gameState.iconWidth(dimensions['cardWidth']!),
                                    ),
                                    _buildControlButton(
                                      icon: Icons.token,
                                      onPressed: () => gameState.addTokenToHand(),
                                      tooltip: '토큰 추가',
                                      isEnabled: true,
                                      iconSize: gameState.iconWidth(dimensions['cardWidth']!),
                                    ),
                                  ],
                                ),
                              ),
                              // 선택된 카드 정보 표시
                              if (gameState.getSelectedCard() != null)
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // 카드 이름
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                localeCardData?.name ?? '데이터 없음',
                                                style: TextStyle(
                                                  fontSize: dimensions['fontSize']! * 1.5,
                                                  fontFamily: localeCardData?.locale == 'JPN'
                                                      ? "MPLUSC"
                                                      : "JalnanGothic",
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        // 카드 이미지
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: LayoutBuilder(
                                                builder: (BuildContext context, BoxConstraints constraints) {
                                                  return SizedBox(
                                                    width: constraints.maxWidth,
                                                    child: Image.network(
                                                      gameState.getSelectedCard()!.getDisplayImgUrl() ?? '',
                                                      fit: BoxFit.fitWidth,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return Container(
                                                          height: constraints.maxWidth * 1.4,
                                                          color: Colors.grey[300],
                                                          child: const Icon(Icons.image_not_supported),
                                                        );
                                                      },
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        // 카드 효과 텍스트
                                        Consumer<TextSimplifyProvider>(
                                          builder: (context, textSimplifyProvider, child) {
                                            return Column(
                                              children: [
                                                if (localeCardData?.effect != null)
                                                  CardService().effectWidget(
                                                    context,
                                                    localeCardData!.effect!,
                                                    '상단 텍스트',
                                                    ColorService.getColorFromString(
                                                        gameState.getSelectedCard()!.color1!),
                                                    dimensions['fontSize']!,
                                                    localeCardData.locale,
                                                    true,
                                                  ),
                                                const SizedBox(height: 5),
                                                if (localeCardData?.sourceEffect != null)
                                                  CardService().effectWidget(
                                                    context,
                                                    localeCardData!.sourceEffect!,
                                                    '하단 텍스트',
                                                    ColorService.getColorFromString(
                                                        gameState.getSelectedCard()!.color1!),
                                                    dimensions['fontSize']!,
                                                    localeCardData.locale,
                                                    true,
                                                  ),
                                              ],
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      // 우측 게임 보드
                      Expanded(
                        flex: dimensions['isSmallScreen'] ? 7 : (dimensions['isMediumScreen'] ? 8 : 9),
                        child: Padding(
                          padding: EdgeInsets.all(dimensions['padding']!),
                          child: Stack(
                            children: [
                              Column(
                                children: [
                                  Expanded(
                                    flex: dimensions['gameAreaFlexRatios']['memory']!,
                                    child: MemoryGauge(
                                      cardWidth: dimensions['cardWidth']!,
                                    ),
                                  ),
                                  Expanded(
                                    flex: dimensions['gameAreaFlexRatios']['main']!,
                                    child: _buildResponsiveGameArea(dimensions, gameState),
                                  ),
                                ],
                              ),
                              if (gameState.isShowDialog() || gameState.isShowTrash)
                                Align(
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    height: dimensions['cardWidth']! * 6,
                                    width: dimensions['cardWidth']! * 6,
                                    child: ShowCards(
                                      cardWidth: dimensions['cardWidth']!,
                                    ),
                                  ),
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
        ),
      ),
    );
  }

  Widget _buildResponsiveGameArea(Map<String, dynamic> dimensions, GameState gameState) {
    // 모든 영역에 동일한 카드 크기 사용
    double cardWidth = dimensions['cardWidth']!;
    
    return Row(
      children: [
        Expanded(
          flex: dimensions['gameAreaRowFlexRatios']['left']!,
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: SecurityStackArea(
                  cardWidth: cardWidth,
                ),
              ),
              Expanded(
                flex: 1,
                child: RaisingZoneWidget(
                  cardWidth: cardWidth,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: dimensions['gameAreaRowFlexRatios']['center']!,
          child: Column(
            children: [
              Expanded(
                flex: dimensions['centerAreaVerticalRatios']['field']!,
                child: ResponsiveFieldArea(
                  cardWidth: cardWidth,
                  fieldColumns: dimensions['fieldColumns']!,
                ),
              ),
              Expanded(
                flex: dimensions['centerAreaVerticalRatios']['hand']!,
                child: HandArea(
                  cardWidth: cardWidth,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: dimensions['gameAreaRowFlexRatios']['right']!,
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: DeckArea(
                  cardWidth: cardWidth,
                ),
              ),
              Expanded(
                flex: 1,
                child: TrashArea(
                  cardWidth: cardWidth,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    required bool isEnabled,
    required double iconSize,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(
        width: iconSize,
        height: iconSize,
      ),
      child: IconButton(
        onPressed: isEnabled ? onPressed : null,
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          size: iconSize,
          color: isEnabled ? Colors.black : Colors.grey,
        ),
        tooltip: tooltip,
      ),
    );
  }
}
