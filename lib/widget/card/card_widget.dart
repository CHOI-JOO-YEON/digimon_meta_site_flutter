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
import '../../service/color_service.dart';
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
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(_isHovered ? 0.25 : 0.15),
                          blurRadius: _isHovered ? 8 : 5,
                          offset: Offset(0, _isHovered ? 4 : 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
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
                        child: Image.network(
                          widget.card.getDisplaySmallImgUrl() ?? '',
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
                            // 이미지 로드 실패 시 카드 번호와 이름을 표시
                            final String cardNo = widget.card.cardNo ?? '';
                            final String cardName = widget.card.localeCardData.isNotEmpty 
                                ? widget.card.localeCardData[0].name ?? ''
                                : '';
                            
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(widget.width * 0.05),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(widget.width * 0.05),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        cardNo,
                                        style: TextStyle(
                                          fontSize: widget.width * 0.15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      if (cardName.isNotEmpty) 
                                        Text(
                                          cardName,
                                          style: TextStyle(
                                            fontSize: widget.width * 0.12,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
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
                                    BorderRadius.circular(widget.width * 0.05)),
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
                      left: 0,
                      bottom: 0,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        padding: EdgeInsets.symmetric(
                          horizontal: widget.width * 0.07,
                          vertical: widget.width * 0.04,
                        ),
                        decoration: BoxDecoration(
                          color: _isHighlighted 
                              ? Colors.orange.withOpacity(0.9)
                              : Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                          ),
                          boxShadow: _isHighlighted
                              ? [
                                  BoxShadow(
                                    color: Colors.orange.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  )
                                ]
                              : null,
                        ),
                        child: AnimatedDefaultTextStyle(
                          duration: Duration(milliseconds: 300),
                          style: TextStyle(
                            fontSize: _isHighlighted
                                ? widget.width * 0.14
                                : widget.width * 0.11,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(
                          children: [
                            // 닫기 버튼
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: _toggleButtons,
                                child: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.close, size: 14, color: Colors.black87),
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
                                    color: Colors.red.shade700,
                                    size: widget.width * 0.4,
                                  ),
                                  _buildActionButton(
                                    onTap: () => widget.addCard!(widget.card),
                                    icon: Icons.add,
                                    label: "",
                                    color: Colors.green.shade700,
                                    size: widget.width * 0.4,
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
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size * 0.8,
        height: size * 0.8,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              spreadRadius: 0.5,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            size: size * 0.4,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
