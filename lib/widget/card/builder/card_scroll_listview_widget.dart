import 'package:digimon_meta_site_flutter/model/card.dart';
import 'package:digimon_meta_site_flutter/model/search_parameter.dart';
import 'package:digimon_meta_site_flutter/service/card_service.dart';
import 'package:digimon_meta_site_flutter/service/keyword_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/text_simplify_provider.dart';
import '../../../service/size_service.dart';

class CardScrollListView extends StatefulWidget {
  final List<DigimonCard> cards;
  final VoidCallback? loadMoreCards;
  final Function(DigimonCard)? cardPressEvent;
  final int totalPages;
  final int currentPage;
  final Function? mouseEnterEvent;
  final Function(SearchParameter)? searchWithParameter;

  const CardScrollListView({
    super.key,
    required this.cards,
    this.loadMoreCards,
    this.cardPressEvent,
    this.mouseEnterEvent,
    required this.totalPages,
    required this.currentPage,
    this.searchWithParameter,
  });

  @override
  State<CardScrollListView> createState() => _CardScrollListViewState();
}

class _CardScrollListViewState extends State<CardScrollListView> {
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  // cardNo 대신 cardId를 사용하여 효과 관리
  final Map<int, bool> _cardAddingEffects = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !isLoading &&
        widget.currentPage < widget.totalPages) {
      loadMoreItems();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> loadMoreItems() async {
    setState(() => isLoading = true);
    if (widget.loadMoreCards != null) {
      widget.loadMoreCards!();
    }
    setState(() => isLoading = false);
  }

  // Play addition animation for a card
  void _playAdditionEffect(DigimonCard card) {
    if (card.cardId == null) return; // cardId가 없는 경우 효과 적용 안함
    
    setState(() {
      _cardAddingEffects[card.cardId!] = true;
    });

    // Reset effect after animation completes
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _cardAddingEffects.remove(card.cardId);
        });
      }
    });
  }

  // Handle card addition with visual effect
  void _handleCardAddition(DigimonCard card) {
    _playAdditionEffect(card);
    widget.cardPressEvent!(card);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: widget.cards.length + (isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < widget.cards.length) {
                final card = widget.cards[index];
                // cardId를 사용하여 애니메이션 효과 확인
                final bool isAddingCard = card.cardId != null && (_cardAddingEffects[card.cardId!] ?? false);
                
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutQuart,
                  transform: isAddingCard 
                      ? (Matrix4.identity()..scale(1.01))
                      : Matrix4.identity(),
                  padding: EdgeInsets.all(SizeService.paddingSize(context)),
                  child: GestureDetector(
                    onTap: () => _handleCardAddition(card),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            SizeService.roundRadius(context)),
                        color: isAddingCard 
                            ? Color.lerp(Theme.of(context).cardColor, Colors.white, 0.15)
                            : Theme.of(context).cardColor,
                        boxShadow: isAddingCard
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 1),
                                )
                              ]
                            : null,
                      ),
                      child: Container(
                        padding: EdgeInsets.all(SizeService.paddingSize(context)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 8,
                                child: GestureDetector(
                                  onTap: () => CardService().showImageDialog(
                                    context,
                                    card,
                                    searchWithParameter: widget.searchWithParameter,
                                  ),
                                  // Make sure this inner GestureDetector doesn't interfere with the parent
                                  behavior: HitTestBehavior.opaque,
                                  child: Image.network(
                                    card.getDisplaySmallImgUrl()!,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.broken_image);
                                    },
                                  ),
                                )),
                            Expanded(flex: 1, child: Container(),),
                            Expanded(
                                flex: 32,
                                child: GestureDetector(
                                  onTap: () => _handleCardAddition(card), // Make the text area clickable
                                  behavior: HitTestBehavior.opaque, // Important - ensures the gesture is detected across the whole area
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${card.cardNo} ${card.getDisplayName()}',
                                        style: TextStyle(
                                          fontFamily:
                                              card.getDisplayLocale() == 'JPN'
                                                  ? "MPLUSC"
                                                  : "JalnanGothic",
                                          fontSize: SizeService.bodyFontSize(context),
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      if (card.getDisplayEffect() != null)
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                margin: EdgeInsets.only(top: 4),
                                                padding: EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context).highlightColor,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: EffectTextClickable(
                                                  text: card.getDisplayEffect()!,
                                                  prefix: '상단 텍스트',
                                                  locale: card.getDisplayLocale()!,
                                                  onTap: () => _handleCardAddition(card),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      if (card.getDisplaySourceEffect() != null)
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                margin: EdgeInsets.only(top: 4),
                                                padding: EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context).highlightColor,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: EffectTextClickable(
                                                  text: card
                                                      .getDisplaySourceEffect()!,
                                                  prefix: '하단 텍스트',
                                                  locale: card.getDisplayLocale()!,
                                                  onTap: () => _handleCardAddition(card),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ))
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ],
    );
  }
}

// 새로운 클릭 가능한 텍스트 위젯
class EffectTextClickable extends StatefulWidget {
  final String text;
  final String prefix;
  final String locale;
  final VoidCallback onTap;

  const EffectTextClickable({
    Key? key,
    required this.text,
    required this.prefix,
    required this.locale,
    required this.onTap,
  }) : super(key: key);

  @override
  State<EffectTextClickable> createState() => _EffectTextClickableState();
}

class _EffectTextClickableState extends State<EffectTextClickable> {
  // 현재 활성화된 설명의 키 (없으면 null)
  String? activeDescriptionKey;
  final KeywordService _keywordService = KeywordService();
  bool _keywordsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadKeywords();
  }

  Future<void> _loadKeywords() async {
    await _keywordService.loadKeywords();
    setState(() {
      _keywordsLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isTextSimplify =
        Provider.of<TextSimplifyProvider>(context).getTextSimplify();
    final List<InlineSpan> spans = [];
    spans.add(TextSpan(
      text: widget.prefix,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontFamily: "JalnanGothic",
      ),
    ));
    spans.add(const TextSpan(text: '\n'));
    
    // 클릭 가능한 텍스트 기능 추가
    spans.addAll(CardService().getSpansByLocale(
      widget.locale, 
      widget.text, 
      isTextSimplify,
      onBracketTap: (String bracketText) {
        // 괄호에서 텍스트 추출
        String content = bracketText;
        if (content.startsWith('《') && content.endsWith('》')) {
          content = content.substring(1, content.length - 1);
        } else if (content.startsWith('≪') && content.endsWith('≫')) {
          content = content.substring(1, content.length - 1);
        } else if (content.startsWith('＜') && content.endsWith('＞')) {
          content = content.substring(1, content.length - 1);
        }
        
        // 상태 업데이트: 같은 키를 다시 누르면 설명을 토글함
        setState(() {
          if (activeDescriptionKey == content) {
            activeDescriptionKey = null; // 이미 활성화된 설명을 다시 누르면 닫기
          } else {
            activeDescriptionKey = content; // 새로운 설명 활성화
          }
        });
      }
    ));

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque, // 중요: 모든 영역에서 탭 이벤트가 감지되도록 설정
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 메인 텍스트
          Text.rich(
            TextSpan(
              children: spans,
              style: TextStyle(
                fontSize: SizeService.bodyFontSize(context),
                color: Colors.black,
                height: 1.4,
                fontFamily: widget.locale == 'JPN' ? "MPLUSC" : "JalnanGothic",
              ),
            ),
          ),
          
          // 활성화된 설명이 있으면 표시
          if (activeDescriptionKey != null)
            GestureDetector(
              // 설명 영역은 이벤트 전파 방지 (클릭 시 설명만 닫히도록)
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  activeDescriptionKey = null;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(top: 4, left: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.withOpacity(0.4), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    )
                  ]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 헤더 (키워드 이름)
                    Row(
                      children: [
                        // 키워드 이름 (주황색으로 변경, 아이콘 제거)
                        Text(
                          activeDescriptionKey!,
                          style: TextStyle(
                            fontSize: SizeService.bodyFontSize(context) * 0.9,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromRGBO(206, 101, 1, 1), // 주황색으로 변경
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // 닫기 버튼
                        InkWell(
                          onTap: () {
                            setState(() {
                              activeDescriptionKey = null;
                            });
                          },
                          child: Icon(
                            Icons.close,
                            size: SizeService.bodyFontSize(context) * 0.8,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    
                    // 구분선
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Divider(
                        color: Colors.grey.withOpacity(0.3),
                        height: 1,
                      ),
                    ),
                    
                    // 효과 설명 텍스트
                    Text(
                      _getEffectDescriptionText(activeDescriptionKey!),
                      style: TextStyle(
                        fontSize: SizeService.bodyFontSize(context) * 0.85,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  // 카드 효과에 대한 설명 텍스트 가져오기
  String _getEffectDescriptionText(String content) {
    // 키워드 서비스에서 설명 가져오기
    if (_keywordsLoaded) {
      return _keywordService.getKeywordDescription(content);
    }
    
    // 설명이 없을 경우 기본 반환
    return '이 효과에 대한 자세한 설명이 없습니다.';
  }
}
