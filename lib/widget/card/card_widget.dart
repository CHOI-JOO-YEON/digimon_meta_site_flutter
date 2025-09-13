import 'dart:async';
import 'package:digimon_meta_site_flutter/model/search_parameter.dart';
import 'package:digimon_meta_site_flutter/service/card_service.dart';
import 'package:digimon_meta_site_flutter/widget/common/toast_overlay.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:digimon_meta_site_flutter/model/card.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../provider/limit_provider.dart';
import '../../provider/locale_provider.dart';
import '../../service/color_service.dart';
import '../common/card_image_fallback.dart';
import 'game/card_back_widget.dart';

class CustomCard extends StatefulWidget {
  final double width;
  final DigimonCard card;
  final bool? isActive;
  final bool? zoomActive;
  final Function(DigimonCard)? cardPressEvent;

  final Function? onHover;
  final Function? onExit;
  final Function? onLongPress;
  final Function? onDoubleTab;
  final Function(SearchParameter)? searchWithParameter;

  final bool hideLimitBadges;
  final bool hoverEffect;
  
  // 카드 증감 기능 관련 속성 추가
  final Function(DigimonCard)? addCard;
  final Function(DigimonCard)? removeCard;
  final int? cardCount;
  
  // 증감 모드 관련 추가 속성
  final bool isButtonsActive;
  final Function(bool)? onButtonsToggle;

  const CustomCard({
    super.key,
    required this.width,
    this.cardPressEvent,
    required this.card,
    this.onHover,
    this.onExit,
    this.onLongPress,
    this.isActive,
    this.zoomActive,
    this.searchWithParameter,
    this.onDoubleTab,
    this.hideLimitBadges = false,
    this.hoverEffect = false,
    
    // 추가된 파라미터
    this.addCard,
    this.removeCard,
    this.cardCount,
    this.isButtonsActive = false,
    this.onButtonsToggle,
  });

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> with SingleTickerProviderStateMixin {
  Timer? _timer;
  bool _isHovered = false;
  bool _isShowingButtons = false;
  late AnimationController _animationController;
  int? _previousCount;
  bool _isHighlighted = false;

  // 카드 크기 기준 고정 radius 계산
  double get cardRadius => widget.width * 0.06;
  double get cardCountBadgeRadius => widget.width * 0.04;
  double get parallelBadgeRadius => widget.width * 0.03;

  @override
  void initState() {
    super.initState();
    _isShowingButtons = widget.isButtonsActive;
    _previousCount = widget.cardCount;
    
    // 애니메이션 컨트롤러 초기화
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isHighlighted = false;
        });
        _animationController.reset();
      }
    });
  }

  @override
  void didUpdateWidget(CustomCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 외부에서 isButtonsActive가 변경되면 내부 상태도 업데이트
    if (oldWidget.isButtonsActive != widget.isButtonsActive) {
      _isShowingButtons = widget.isButtonsActive;
    }
    
    // 카드 수량이 변경되었는지 확인하고 애니메이션 실행
    if (widget.cardCount != null && _previousCount != widget.cardCount) {
      _triggerAnimation();
      _previousCount = widget.cardCount;
    }
  }

  void _triggerAnimation() {
    setState(() {
      _isHighlighted = true;
    });
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer?.cancel();
    if (widget.onExit != null) {
      widget.onExit!();
    }
    super.dispose();
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    _timer = Timer.periodic(Duration(milliseconds: 500), (_) {
      if (widget.onLongPress != null) {
        widget.onLongPress!(widget.card);
      }
    });
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    _timer?.cancel();
  }

  void _handleDoubleTap() {
    if (widget.onDoubleTab != null) {
      widget.onDoubleTab!();
    }
  }

  void _toggleButtons() {
    if (widget.addCard != null && widget.removeCard != null) {
      final newState = !_isShowingButtons;
      setState(() {
        _isShowingButtons = newState;
      });
      
      // 버튼 상태가 변경되면 부모에게 알림
      if (widget.onButtonsToggle != null) {
        widget.onButtonsToggle!(newState);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String color = widget.card.color2 ?? widget.card.color1!;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 768; // 모바일 화면 감지
    final isVerySmall = screenWidth < 480; // 매우 작은 화면 감지
    
    return MouseRegion(
      onEnter: (event) {
        if (event.kind == PointerDeviceKind.mouse) {
          setState(() {
            _isHovered = true;
          });
          widget.onHover?.call(context);
        }
      },
      onExit: (event) {
        if (event.kind == PointerDeviceKind.mouse) {
          setState(() {
            _isHovered = false;
          });
          widget.onExit?.call();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: _isHovered && widget.hoverEffect
            ? (Matrix4.identity()..scale(1.03))
            : Matrix4.identity(),
        child: GestureDetector(
          onTap: () {
            if (widget.addCard != null && widget.removeCard != null) {
              _toggleButtons(); // 증감 버튼 토글
            } else if (widget.cardPressEvent != null) {
              widget.cardPressEvent!(widget.card);
            }
          },
          // onDoubleTap: _handleDoubleTap,
          onLongPress: () {
            if (widget.onLongPress != null) {
              widget.onLongPress!();
            }
          },
          // onLongPressStart: _handleLongPressStart,
          // onLongPressEnd: _handleLongPressEnd,
          child: Consumer<LimitProvider>(
            builder: (context, limitProvider, child) {
              int allowedQuantity =
                  limitProvider.getCardAllowedQuantity(widget.card.cardNo!);
              List<String> abPairBanCardNos =
                  limitProvider.getABPairBanCardNos(widget.card.cardNo!);
              return Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: widget.width,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                          spreadRadius: 0,
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(cardRadius),
                      child: ColorFiltered(
                        colorFilter: widget.isActive ?? true
                            ? ColorFilter.mode(
                                Colors.transparent, BlendMode.srcATop)
                            : ColorFilter.matrix(<double>[
                                0.2126,
                                0.7152,
                                0.0722,
                                0,
                                0,
                                0.2126,
                                0.7152,
                                0.0722,
                                0,
                                0,
                                0.2126,
                                0.7152,
                                0.0722,
                                0,
                                0,
                                0,
                                0,
                                0,
                                1,
                                0,
                              ]),
                        child: Consumer<LocaleProvider>(
                          builder: (context, localeProvider, _) {
                            return Image.network(
                              widget.card.getDisplaySmallImgUrl(localeProvider.localePriority) ?? '',
                              fit: BoxFit.fill,
                              loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / 
                                      loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                              ),
                            );
                          },
                              errorBuilder: (context, error, stackTrace) {
                                return CardImageFallback(
                                  card: widget.card,
                                  width: widget.width,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  if (widget.card.isParallel ?? false)
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Builder(
                        builder: (context) {
                          double containerSize = widget.width * 0.2;
                          double iconSize = widget.width * 0.15;
                          double fontSize = widget.width * 0.12;

                          return Container(
                            padding: EdgeInsets.only(
                                left: widget.width * 0.02,
                                right: widget.width * 0.02),
                            height: containerSize,
                            decoration: BoxDecoration(
                                color: ColorService.getColorFromString(
                                    widget.card.color1!),
                                borderRadius:
                                    BorderRadius.circular(parallelBadgeRadius)),
                            child: Center(
                              child: Text(
                                '패럴렐',
                                style: TextStyle(
                                  color: widget.card.color1 == 'WHITE'
                                      ? Colors.black
                                      : Colors.white,
                                  fontSize: fontSize * 0.8,
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  if (allowedQuantity == 1 ||
                      allowedQuantity == 0 ||
                      abPairBanCardNos.isNotEmpty)
                    Positioned(
                      top: widget.width * 0.08,
                      right: widget.width * 0.08,
                      child: Builder(
                        builder: (context) {
                          // hideLimitBadges가 true인 경우 배지를 표시하지 않음
                          if (widget.hideLimitBadges) {
                            return SizedBox();
                          }
                          
                          double containerSize = widget.width * 0.2;
                          double iconSize = widget.width * 0.15;
                          double fontSize = widget.width * 0.12;

                          if (allowedQuantity == 0) {
                            return Container(
                              padding: EdgeInsets.zero,
                              width: containerSize,
                              height: containerSize,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.block,
                                  color: Colors.white,
                                  size: iconSize,
                                ),
                              ),
                            );
                          } else if (allowedQuantity == 1) {
                            return Container(
                              padding: EdgeInsets.zero,
                              width: containerSize,
                              height: containerSize,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '1',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          } else if (abPairBanCardNos.isNotEmpty) {
                            return GestureDetector(
                              onTap: () {
                                ToastOverlay.show(context,
                                    '${abPairBanCardNos.toString()} 카드와 함께 사용할 수 없습니다.');
                              },
                              child: Container(
                                padding: EdgeInsets.zero,
                                width: containerSize,
                                height: containerSize,
                                decoration: BoxDecoration(
                                  color: Colors.purple,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    'AB',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: fontSize*0.7,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return SizedBox();
                          }
                        },
                      ),
                    ),
                  if (widget.zoomActive != false)
                    Positioned(
                      right: widget.width * 0.05,
                      bottom: widget.width * 0.05,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints.tightFor(
                            width: widget.width * 0.2,
                            height: widget.width * 0.2,
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            iconSize: widget.width * 0.16,
                            icon: Icon(
                              Icons.zoom_in,
                              color:
                                  color == 'BLACK' ? Colors.white : Colors.black,
                            ),
                            onPressed: () {
                              CardService().showImageDialog(
                                 context, widget.card, 
                                 searchWithParameter: widget.searchWithParameter);
                            },
                          ),
                        ),
                      ),
                    ),
                  // 카드 수량 표시
                  if (widget.cardCount != null)
                    Positioned(
                      left: isMobile ? 4 : 8,
                      bottom: isMobile ? 4 : 8,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOutQuart,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? widget.width * 0.06 : widget.width * 0.08,
                          vertical: isMobile ? widget.width * 0.03 : widget.width * 0.05,
                        ),
                        decoration: BoxDecoration(
                          gradient: _isHighlighted 
                              ? LinearGradient(
                                  colors: [
                                    const Color(0xFFFF6B35),
                                    const Color(0xFFFF8E53),
                                  ],
                                )
                              : LinearGradient(
                                  colors: [
                                    const Color(0xFF1F2937),
                                    const Color(0xFF374151),
                                  ],
                                ),
                          borderRadius: BorderRadius.circular(cardCountBadgeRadius),
                          boxShadow: [
                            BoxShadow(
                              color: _isHighlighted
                                  ? const Color(0xFFFF6B35).withOpacity(0.4)
                                  : Colors.black.withOpacity(0.3),
                              blurRadius: _isHighlighted ? 12 : 8,
                              offset: const Offset(0, 4),
                              spreadRadius: _isHighlighted ? 1 : 0,
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: isMobile ? 0.5 : 1,
                          ),
                        ),
                        child: AnimatedDefaultTextStyle(
                          duration: Duration(milliseconds: 300),
                          style: TextStyle(
                            fontSize: _isHighlighted
                                ? (isMobile ? widget.width * 0.12 : widget.width * 0.14)
                                : (isMobile ? widget.width * 0.10 : widget.width * 0.12),
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 1),
                                blurRadius: 2,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ],
                          ),
                          child: Text(
                            '${widget.cardCount}',
                          ),
                        ),
                      ),
                    ),
                  // 카드 선택 시 표시되는 증감 버튼
                  if (_isShowingButtons && widget.addCard != null && widget.removeCard != null)
                    Positioned.fill(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.7),
                                                          Colors.black.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(cardRadius),
                      ),
                        child: Stack(
                          children: [
                            // 닫기 버튼
                            Positioned(
                              top: isMobile ? 8 : 12,
                              right: isMobile ? 8 : 12,
                              child: GestureDetector(
                                onTap: _toggleButtons,
                                child: Container(
                                  padding: EdgeInsets.all(isMobile ? 4 : 6),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white,
                                        Colors.grey.shade100,
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    size: isMobile ? 12 : 16,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ),
                            
                            // 증감 버튼들
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildActionButton(
                                    onTap: () {
                                      widget.removeCard!(widget.card);
                                      // 카드 제거 후 버튼 상태 업데이트
                                      if (widget.cardCount == 1) {
                                        setState(() {
                                          _isShowingButtons = false;
                                        });
                                        if (widget.onButtonsToggle != null) {
                                          widget.onButtonsToggle!(false);
                                        }
                                      }
                                    },
                                    icon: Icons.remove,
                                    label: "",
                                    color: const Color(0xFFEF4444),
                                    size: isMobile ? widget.width * 0.35 : widget.width * 0.4,
                                    isMobile: isMobile,
                                  ),
                                  _buildActionButton(
                                    onTap: () => widget.addCard!(widget.card),
                                    icon: Icons.add,
                                    label: "",
                                    color: const Color(0xFF10B981),
                                    size: isMobile ? widget.width * 0.35 : widget.width * 0.4,
                                    isMobile: isMobile,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required Function() onTap,
    required IconData icon,
    required String label,
    required Color color,
    required double size,
    bool isMobile = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(size * 0.4),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: size * 0.8,
          height: size * 0.8,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color,
                Color.lerp(color, Colors.black, 0.2)!,
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: isMobile ? 0.5 : 1,
            ),
          ),
          child: Center(
            child: Icon(
              icon,
              size: size * 0.4,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                  color: Colors.black.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
