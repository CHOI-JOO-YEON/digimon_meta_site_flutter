import 'dart:async';
import 'package:digimon_meta_site_flutter/service/card_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:digimon_meta_site_flutter/model/card.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../provider/limit_provider.dart';
import '../../service/color_service.dart';

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
  final Function(int)? searchNote;

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
    this.searchNote,
    this.onDoubleTab,
  });

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    setState(() {});
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    String color = widget.card.color2 ?? widget.card.color1!;
    return MouseRegion(
      onEnter: (event) {
        if (widget.onHover != null) {
          widget.onHover!(context);
        }
      },
      onExit: (event) {
        if (widget.onExit != null) {
          widget.onExit!();
        }
      },
      child: GestureDetector(
        onTap: () {
          if (widget.cardPressEvent != null) {
            widget.cardPressEvent!(widget.card);
          }
        },
        onDoubleTap: _handleDoubleTap,
        // onLongPress: _handleLongPress,
        onLongPressStart: _handleLongPressStart,
        onLongPressEnd: _handleLongPressEnd,
        child: Consumer<LimitProvider>(
          builder: (context, limitProvider, child) {
            int allowedQuantity =
                limitProvider.getCardAllowedQuantity(widget.card.cardNo!);
            return Stack(
              alignment: Alignment.bottomRight,
              children: [
                SizedBox(
                  width: widget.width,
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
                      widget.card.smallImgUrl ?? '',
                      fit: BoxFit.fill,
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
                                color: Colors.white,
                                fontSize: fontSize * 0.8,
                                // fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                if (allowedQuantity == 1 || allowedQuantity == 0)
                  Positioned(
                    top: widget.width * 0.08,
                    right: widget.width * 0.08,
                    child: Builder(
                      builder: (context) {
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
                                context, widget.card, widget.searchNote);
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
