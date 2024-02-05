import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:digimon_meta_site_flutter/model/card.dart'; // 가정된 카드 모델

class CustomCard extends StatefulWidget {
  final double width;
  final DigimonCard card;
  final Function(DigimonCard) cardPressEvent;
  final Function(DigimonCard)? mouseEnterEvent;

  const CustomCard(
      {super.key,
      required this.width,
      required this.cardPressEvent,
      required this.card,
      this.mouseEnterEvent});

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {

  @override
  void initState() {
    super.initState();
    _compressImage(widget.card);
    setState(() {});
  }

  // 오버레이 표시 함수


  // @override
  // void didUpdateWidget(CustomCard oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   // selectCard가 변경되었는지 확인
  //   if (widget.width != oldWidget.width) {
  //     // selectCard가 변경되었다면 이미지를 다시 압축
  //     _compressImage(widget.card.imgUrl);
  //   }
  // }
  Future<void> _compressImage(DigimonCard card) async {
    if (widget.card.compressedImg == null && card.imgUrl != null) {
      final response = await http.get(Uri.parse(card.imgUrl!));
      if (response.statusCode == 200) {
        final Uint8List compressedImage =
            await FlutterImageCompress.compressWithList(response.bodyBytes,
                minWidth: widget.width.ceil() * 2,
                // minWidth: 745,
                quality: 100,
                format: CompressFormat.png);
        setState(() {
          widget.card.setCompressedImg(compressedImage);
        });
      }
    }
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Container(
  //     child: MouseRegion(
  //         onEnter: (event) => setState(() {
  //               // _showOverlay(context);
  //               if (widget.mouseEnterEvent != null) {
  //                 widget.mouseEnterEvent!(widget.card);
  //               }
  //             }),
  //
  //         child: GestureDetector(
  //           onTap: () {
  //             widget.cardPressEvent(widget.card);
  //           },
  //           child: Transform.scale(
  //             scale: 1,
  //             child: Container(
  //               width: widget.width,
  //               child: widget.card.compressedImg == null
  //                   ? Container()
  //
  //                   // Center(child: CircularProgressIndicator())
  //                   : Image.memory(
  //                       widget.card.compressedImg!,
  //                       fit: BoxFit.cover,
  //                     ),
  //             ),
  //           ),
  //         )),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: MouseRegion(
        onEnter: (event) {
          setState(() {
            // _showOverlay(context);
            if (widget.mouseEnterEvent != null) {
              widget.mouseEnterEvent!(widget.card);
            }
          });
        },
        child: GestureDetector(
          onTap: () {
            widget.cardPressEvent(widget.card);
          },
          child: Stack(
            alignment: Alignment.bottomRight, // 스택의 정렬 방향
            children: [
              Transform.scale(
                scale: 1,
                child: Container(
                  width: widget.width,
                  child: widget.card.compressedImg == null
                      ? Container() // 이미지가 없는 경우
                      : Image.memory(
                    widget.card.compressedImg!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // 확대 버튼 추가
              Positioned(
                right: 0,
                bottom: 0,
                child: IconButton(
                  icon: Icon(Icons.zoom_in, color: Colors.black,),
                  onPressed: () {
                    _showImageDialog(context, widget.card.imgUrl!);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageDialog(BuildContext context,String url) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Image.network(url, fit: BoxFit.contain),
        );
      },
    );
  }

}
