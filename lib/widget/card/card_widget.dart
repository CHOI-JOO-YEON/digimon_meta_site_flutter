import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:digimon_meta_site_flutter/model/card.dart'; // 가정된 카드 모델

class CustomCard extends StatefulWidget {
  final double width;
  final DigimonCard card;
  final Function(DigimonCard) cardPressEvent;

  final Function? onHover; // 마우스 오버 콜백
  final Function? onExit; // 마우스 아웃 콜백

  const CustomCard({
    super.key,
    required this.width,
    required this.cardPressEvent,
    required this.card,
    this.onHover,
    this.onExit,
  });

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  @override
  void initState() {
    super.initState();
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      child: MouseRegion(
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
            widget.cardPressEvent(widget.card);
          },
          child: Stack(
            alignment: Alignment.bottomRight, // 스택의 정렬 방향
            children: [
              SizedBox(
                  width: widget.width,
                  child: Image.network(
                    widget.card.smallImgUrl ?? '',
                    fit: BoxFit.fill,
                  )
                  ),
              // 확대 버튼 추가
              Positioned(
                right: widget.width * 0.05,
                bottom: widget.width * 0.05,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints.tightFor(
                        width: widget.width * 0.2,
                        height: widget.width * 0.2
                        ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: widget.width * 0.16,
                      icon: const Icon(Icons.zoom_in, color: Colors.black),
                      onPressed: () {
                        _showImageDialog(context, widget.card);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageDialog(BuildContext context, DigimonCard card) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Image.network(card.imgUrl ?? '', fit: BoxFit.fill),
        );
      },
    );
  }
}
