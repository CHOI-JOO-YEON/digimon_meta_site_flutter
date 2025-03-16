import 'package:digimon_meta_site_flutter/service/card_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:auto_route/auto_route.dart';
import '../model/deck-build.dart';
import '../model/locale_card_data.dart';
import '../provider/text_simplify_provider.dart';
import '../service/color_service.dart';
import '../state/game_state.dart';
import '../widget/card/game/deck_area.dart';
import '../widget/card/game/field_area_widget.dart';
import '../widget/card/game/field_zone_widget.dart';
import '../widget/card/game/hand_area.dart';
import '../widget/card/game/memory_gauge.dart';
import '../widget/card/game/razing_zone_widget.dart';
import '../widget/card/game/security_stack_area.dart';
import '../widget/card/game/show_cards_widget.dart';
import '../widget/card/game/trash_area.dart';

// 세로 모드를 위한 커스텀 필드 영역 위젯 (한 줄에 4개 카드)
class PortraitFieldArea extends StatelessWidget {
  final double cardWidth;

  const PortraitFieldArea({super.key, required this.cardWidth});

  @override
  Widget build(BuildContext context) {
    double resizingWidth = cardWidth * 0.85;
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        return Column(
          children: [
            Text('필드',
                style: TextStyle(fontSize: gameState.textWidth(cardWidth))),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 첫 번째 그리드 - 한 줄에 4개 카드 (세로모드)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4, // 한 줄에 4개
                          childAspectRatio: 0.35,
                          crossAxisSpacing: resizingWidth * 0.05),
                      itemCount: 8,
                      itemBuilder: (context, index) {
                        return FieldZoneWidget(
                          fieldZone: gameState.fieldZones["field$index"]!,
                          cardWidth: resizingWidth,
                          isRaising: false,
                        );
                      },
                    ),
                    SizedBox(
                      height: resizingWidth * 0.05,
                    ),
                    // 두 번째 그리드 - 한 줄에 4개 카드 (세로모드)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4, // 한 줄에 4개
                          childAspectRatio: 0.712,
                          crossAxisSpacing: resizingWidth * 0.05),
                      itemCount: gameState.fieldZones.length - 8,
                      itemBuilder: (context, index) {
                        return FieldZoneWidget(
                          fieldZone: gameState.fieldZones["field${index + 8}"]!,
                          cardWidth: resizingWidth,
                          isRaising: false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

@RoutePage()
class GamePlayGroundPage extends StatefulWidget {
  final DeckBuild deckBuild;

  const GamePlayGroundPage({super.key, required this.deckBuild});

  @override
  State<GamePlayGroundPage> createState() => _GamePlayGroundPageState();
}

class _GamePlayGroundPageState extends State<GamePlayGroundPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameState(widget.deckBuild),
      child: Scaffold(
          appBar: AppBar(
            title: const Text('플레이그라운드'),
          ),
          body: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            // 화면 크기에 따른 레이아웃 분기를 위한 변수
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;
            final isLandscape = screenWidth > screenHeight;
            final isLargeScreen = screenWidth > 900;
            
            // 화면 크기에 따른 적응형 레이아웃 변수 계산
            double width = isLandscape 
                ? constraints.maxWidth * 0.6 
                : constraints.maxWidth * 0.95;
            double height = isLandscape 
                ? width * (3.5 / 6)
                : width * (4 / 6);
            
            // 카드 크기 조정 - 세로 모드에서는 필드에 맞게 카드 크기 조정
            double cardWidth = isLandscape 
                ? width / 12 
                : width / 5; // 세로 모드에서 필드 한 줄에 4개 표시에 맞게 조정 (7 -> 5)
            
            final gameState = Provider.of<GameState>(context);
            // 글자 크기를 화면 크기에 맞게 조절
            double fontSize = isLargeScreen ? width * 0.01 : 12;
            int selectedLocaleIndex = 0;
            LocaleCardData? localeCardData = gameState
                .getSelectedCard()
                ?.localeCardData[selectedLocaleIndex];
            
            // 반응형 레이아웃 구성
            return Container(
              color: Theme.of(context).cardColor,
              child: isLandscape
                ? _buildLandscapeLayout(context, gameState, width, height, cardWidth, fontSize, localeCardData)
                : _buildPortraitLayout(context, gameState, width, height, cardWidth, fontSize, localeCardData),
            );
          })),
    );
  }
  
  // 가로 화면 레이아웃
  Widget _buildLandscapeLayout(
    BuildContext context, 
    GameState gameState, 
    double width, 
    double height, 
    double cardWidth, 
    double fontSize,
    LocaleCardData? localeCardData
  ) {
    // 가로 모드에서 ShowCards 크기 설정
    double showCardsSize = MediaQuery.of(context).size.width * 0.4; // 화면 너비의 40% 사용
    
    return Stack(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 카드 디테일 영역의 크기 제한
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.3, // 화면 너비의 30%로 제한
              child: Padding(
                padding: EdgeInsets.all(width * 0.01),
                child: Column(
                  children: [
                    _buildControlButtons(gameState, cardWidth),
                    gameState.getSelectedCard() == null
                        ? Container()
                        : Expanded(
                            child: SingleChildScrollView(
                              child: _buildCardDetails(context, gameState, fontSize, localeCardData),
                            ),
                          ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: width,
                height: height,
                child: _buildGameField(gameState, cardWidth),
              ),
            ),
          ],
        ),
        
        // 가로 모드에서도 일관성 있는 ShowCards 다이얼로그
        if (gameState.isShowDialog() || gameState.isShowTrash)
          Positioned.fill(
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 닫기 버튼 추가
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0, bottom: 8.0),
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 30),
                            onPressed: () {
                              // 다이얼로그 닫기
                              if (gameState.isShowTrash) {
                                gameState.updateShowTrash(false);
                              } else if (gameState.isShowDialog()) {
                                // shows 리스트를 비워서 다이얼로그 닫기
                                gameState.shows.clear();
                                gameState.notifyListeners();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    // 카드 표시 영역 - 세로 모드와 동일한 스타일
                    Center(
                      child: Container(
                        height: cardWidth * 6,
                        width: cardWidth * 6,
                        constraints: BoxConstraints(
                          maxWidth: showCardsSize,
                          maxHeight: showCardsSize,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10.0,
                              spreadRadius: 5.0,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: ShowCards(
                          cardWidth: cardWidth * 1.2, // 카드 크기를 약간 더 크게 설정
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  // 세로 화면 레이아웃
  Widget _buildPortraitLayout(
    BuildContext context, 
    GameState gameState, 
    double width, 
    double height, 
    double cardWidth, 
    double fontSize,
    LocaleCardData? localeCardData
  ) {
    // 화면의 실제 높이 계산
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final appBarHeight = AppBar().preferredSize.height;
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    // 하단 여유 공간 줄임 (50 -> 30)
    final availableHeight = screenHeight - appBarHeight - safeAreaTop - safeAreaBottom - 30;
    
    // 세로 모드에서 높이 비율 재조정
    final fieldAreaHeight = availableHeight * 0.40; // 0.42 -> 0.40
    final gameAreaHeight = availableHeight * 0.38; // 유지
    final handAreaHeight = availableHeight * 0.22; // 0.20 -> 0.22
    
    // 세로 모드에서 ShowCards의 크기를 화면 크기에 맞게 조정
    double showCardsSize = screenWidth * 0.85; // 화면 너비의 85% 사용
    
    return Stack(
      children: [
        Column(
          children: [
            // 컨트롤 버튼을 상단에 배치 - 패딩 줄임
            Padding(
              padding: EdgeInsets.all(4.0), // 8.0 -> 4.0
              child: _buildControlButtons(gameState, cardWidth),
            ),
            
            // 필드 영역 - 세로 모드에서는 필드만 표시
            Container(
              width: width,
              height: fieldAreaHeight,
              child: _buildFieldAreaOnly(gameState, cardWidth),
            ),
            
            // 기타 게임 영역 - 시큐리티, 덱, 육성존, 트래시 영역 (핸드 제외)
            Container(
              width: width,
              height: gameAreaHeight,
              child: _buildGameAreaGrid(gameState, cardWidth),
            ),
            
            // 핸드 영역 - 맨 아래에 독립적으로 배치
            Container(
              width: width,
              height: handAreaHeight,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: EdgeInsets.all(2.0), // 4.0 -> 2.0
              child: _buildHandAreaOnly(gameState, cardWidth),
            ),
          ],
        ),
        
        // ShowCards 다이얼로그 오버레이 - 가로 모드와 동일하게 수정
        if (gameState.isShowDialog() || gameState.isShowTrash)
          Positioned.fill(
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 닫기 버튼 추가
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0, bottom: 8.0),
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 30),
                            onPressed: () {
                              // 다이얼로그 닫기
                              if (gameState.isShowTrash) {
                                gameState.updateShowTrash(false);
                              } else if (gameState.isShowDialog()) {
                                // shows 리스트를 비워서 다이얼로그 닫기
                                gameState.shows.clear();
                                gameState.notifyListeners();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    // 카드 표시 영역 - 가로 모드와 동일하게 조정
                    Center(
                      child: Container(
                        height: cardWidth * 6,
                        width: cardWidth * 6,
                        constraints: BoxConstraints(
                          maxWidth: showCardsSize,
                          maxHeight: showCardsSize,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10.0,
                              spreadRadius: 5.0,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: ShowCards(
                          cardWidth: cardWidth * 1.2, // 카드 크기를 약간 더 크게 설정
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  // 컨트롤 버튼 영역
  Widget _buildControlButtons(GameState gameState, double cardWidth) {
    return Container(
      decoration: const BoxDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildIconButton(
            gameState, 
            cardWidth, 
            Icons.undo, 
            () => gameState.undo(), 
            '뒤로', 
            gameState.undoStack.isEmpty ? Colors.grey : Colors.black
          ),
          _buildIconButton(
            gameState, 
            cardWidth, 
            Icons.redo, 
            () => gameState.redo(), 
            '앞으로', 
            gameState.redoStack.isEmpty ? Colors.grey : Colors.black
          ),
          _buildIconButton(
            gameState, 
            cardWidth, 
            Icons.refresh, 
            () => gameState.init(widget.deckBuild), 
            '초기화', 
            null
          ),
          _buildIconButton(
            gameState, 
            cardWidth, 
            Icons.token, 
            () => gameState.addTokenToHand(), 
            '토큰 추가', 
            null
          ),
        ],
      ),
    );
  }
  
  // 아이콘 버튼 위젯
  Widget _buildIconButton(
    GameState gameState, 
    double cardWidth, 
    IconData icon, 
    VoidCallback onPressed, 
    String tooltip, 
    Color? color
  ) {
    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(
          width: gameState.iconWidth(cardWidth),
          height: gameState.iconWidth(cardWidth)),
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          size: gameState.iconWidth(cardWidth),
          color: color,
        ),
        tooltip: tooltip,
      ),
    );
  }
  
  // 카드 상세 정보 위젯
  Widget _buildCardDetails(
    BuildContext context, 
    GameState gameState, 
    double fontSize,
    LocaleCardData? localeCardData
  ) {
    final isLandscape = MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                localeCardData?.name ?? '데이터 없음',
                style: TextStyle(
                  fontSize: fontSize * 1.5,
                  fontFamily: localeCardData!.locale == 'JPN' 
                      ? "MPLUSC" 
                      : "JalnanGothic",
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                    // 이미지 최대 크기 제한
                    double maxWidth = isLandscape 
                        ? MediaQuery.of(context).size.width * 0.25 // 가로 모드에서 화면 너비의 25% 제한
                        : constraints.maxWidth;
                    
                    return SizedBox(
                      width: maxWidth,
                      child: Stack(
                        children: [
                          SizedBox(
                            width: maxWidth,
                            child: Image.network(
                              gameState.getSelectedCard()!.getDisplayImgUrl() ?? '',
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
        
        Consumer<TextSimplifyProvider>(
          builder: (context, textSimplifyProvider, child) {
            return Row(
              children: [
                Text('텍스트 간소화', style: TextStyle(fontSize: fontSize)),
                Switch(
                  value: textSimplifyProvider.getTextSimplify(),
                  onChanged: (v) {
                    textSimplifyProvider.updateTextSimplify(v);
                  },
                  inactiveThumbColor: Colors.red,
                )
              ],
            );
          },
        ),
        
        Consumer<TextSimplifyProvider>(
          builder: (context, textSimplifyProvider, child) {
            return Column(
              children: [
                if (localeCardData.effect != null)
                  CardService().effectWidget(
                    context,
                    localeCardData.effect!,
                    '상단 텍스트',
                    ColorService.getColorFromString(
                        gameState.getSelectedCard()!.color1!),
                    fontSize,
                    localeCardData.locale,
                    textSimplifyProvider.getTextSimplify(),
                  ),
                const SizedBox(height: 5),
                if (localeCardData.sourceEffect != null)
                  CardService().effectWidget(
                    context,
                    localeCardData.sourceEffect!,
                    '하단 텍스트',
                    ColorService.getColorFromString(
                        gameState.getSelectedCard()!.color1!),
                    fontSize,
                    localeCardData.locale,
                    textSimplifyProvider.getTextSimplify(),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
  
  // 세로 모드에서 필드 영역만 표시
  Widget _buildFieldAreaOnly(GameState gameState, double cardWidth) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: EdgeInsets.all(2.0), // 4.0 -> 2.0
      child: Column(
        children: [
          // 메모리 게이지 - 1단으로 변경하여 높이 감소
          Container(
            height: cardWidth * 0.4, // 높이 추가 감소 (0.5 -> 0.4)
            child: MemoryGauge(
              cardWidth: cardWidth * 0.9,
            ),
          ),
          // 필드 영역 - 세로 모드용 커스텀 위젯 사용
          Expanded(
            child: PortraitFieldArea(
              cardWidth: cardWidth,
            ),
          ),
        ],
      ),
    );
  }
  
  // 세로 모드에서 핸드 영역만 표시
  Widget _buildHandAreaOnly(GameState gameState, double cardWidth) {
    return Column(
      children: [
        Text('핸드',
            style: TextStyle(fontSize: gameState.textWidth(cardWidth))),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(4.0),
            ),
            margin: EdgeInsets.all(2.0),
            child: HandArea(
              cardWidth: cardWidth,
            ),
          ),
        ),
      ],
    );
  }
  
  // 세로 모드에서 시큐리티, 덱, 육성존, 트래시 등 영역 배치 (핸드 제외)
  Widget _buildGameAreaGrid(GameState gameState, double cardWidth) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: EdgeInsets.all(2.0), // 4.0 -> 2.0
      child: Column(
        children: [
          // 상단 행: 시큐리티, 덱 - 높이 비율 증가
          Expanded(
            flex: 1,
            child: Row(
              children: [
                // 시큐리티
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    margin: EdgeInsets.all(1.0), // 2.0 -> 1.0
                    child: SecurityStackArea(
                      cardWidth: cardWidth,
                    ),
                  ),
                ),
                // 덱
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    margin: EdgeInsets.all(1.0), // 2.0 -> 1.0
                    child: DeckArea(
                      cardWidth: cardWidth,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 하단 행: 육성존, 트래시 - 높이 비율 유지
          Expanded(
            flex: 1,
            child: Row(
              children: [
                // 육성존
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    margin: EdgeInsets.all(1.0), // 2.0 -> 1.0
                    child: RaisingZoneWidget(
                      cardWidth: cardWidth,
                    ),
                  ),
                ),
                // 트래시
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    margin: EdgeInsets.all(1.0), // 2.0 -> 1.0
                    child: TrashArea(
                      cardWidth: cardWidth,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // 게임 필드 영역 (가로 모드에서 사용)
  Widget _buildGameField(GameState gameState, double cardWidth) {
    return Column(
      children: [
        Expanded(
            flex: 1, // 원래대로 되돌림 (2 -> 1)
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5.0),
              child: MemoryGauge(
                cardWidth: cardWidth,
              ),
            )),
        Expanded(
          flex: 8,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Expanded(
                        flex: 1,
                        child: SecurityStackArea(
                          cardWidth: cardWidth,
                        )),
                    Expanded(
                        flex: 1,
                        child: RaisingZoneWidget(
                          cardWidth: cardWidth,
                        )),
                  ],
                ),
              ),
              Expanded(
                flex: 8,
                child: Column(
                  children: [
                    Expanded(
                        flex: 3,
                        child: FieldArea(
                          cardWidth: cardWidth,
                        )),
                    Expanded(
                        flex: 1,
                        child: HandArea(
                          cardWidth: cardWidth,
                        )),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Expanded(
                        flex: 1,
                        child: DeckArea(
                          cardWidth: cardWidth,
                        )),
                    Expanded(
                        flex: 1,
                        child: TrashArea(
                          cardWidth: cardWidth,
                        )),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
