import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:digimon_meta_site_flutter/model/card.dart'; // 가정된 카드 모델

class CustomCard extends StatefulWidget {
  final double width;
  final DigimonCard card;
  final Function(DigimonCard) cardPressEvent;
  // final Function(DigimonCard)? mouseEnterEvent;
  // final Function()? mouseExitEvent;
  final Function? onHover; // 마우스 오버 콜백
  final Function? onExit; // 마우스 아웃 콜백

  const CustomCard(
      {super.key,
      required this.width,
      required this.cardPressEvent,
      required this.card,  this.onHover, this.onExit,
      // this.mouseEnterEvent,this.mouseExitEvent
      });

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {

  @override
  void initState() {
    super.initState();
    // _compressImage(widget.card);
    setState(() {});
  }

  // Future<void> _compressImage(DigimonCard card) async {
  //   if (card.compressedImg==null&& card.imgUrl != null) {
  //     final response = await http.get(Uri.parse(card.imgUrl!));
  //     if (response.statusCode == 200) {
  //       final Uint8List compressedImage =
  //           await FlutterImageCompress.compressWithList(response.bodyBytes,
  //               minWidth: widget.width.ceil() * 2,
  //               quality: 50,
  //               format: CompressFormat.png);
  //       widget.card.setCompressedImg(compressedImage);
  //       setState(() {
  //
  //       });
  //     }
  //   }
  // }

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
        // onExit: (event){},
        // onEnter: (event) {
        //   setState(() {
        //     // _showOverlay(context);
        //     // if (widget.mouseEnterEvent != null) {
        //     //   widget.mouseEnterEvent!(widget.card);
        //     // }
        //   });
        // },
        onEnter: (event){
          if(widget.onHover!=null) {
            widget.onHover!(context);
          }
        },
        onExit: (event){
          if(widget.onExit!=null) {
            widget.onExit!();
          }

        } ,
        child: GestureDetector(
          onTap: () {
            widget.cardPressEvent(widget.card);
          },
          child: Stack(
            alignment: Alignment.bottomRight, // 스택의 정렬 방향
            children: [
              SizedBox(
                  width: widget.width,
                  child:
                  Image.network(widget.card.smallImgUrl??'',fit: BoxFit.fill,)
                  // widget.card.compressedImg == null
                  //     ? Container() // 이미지가 없는 경우
                  //     : Image.memory(
                  //   widget.card.compressedImg!,
                  //   fit: BoxFit.fill,
                  // ),
                ),
              // 확대 버튼 추가
              Positioned(
                right: widget.width * 0.05, // 위치 조정: 오른쪽 여백을 좀 더 줄임
                bottom: widget.width * 0.05, // 위치 조정: 아래쪽 여백을 좀 더 줄임
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints.tightFor(
                        width: widget.width * 0.2, // 크기 조정: 버튼의 너비를 더 크게 조정
                        height: widget.width * 0.2 // 크기 조정: 버튼의 높이를 더 크게 조정
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: widget.width * 0.16, // 아이콘 크기 조정: 아이콘을 더 크게 조정
                      icon: const Icon(Icons.zoom_in, color: Colors.black),
                      onPressed: () {
                        _showImageDialog(context, widget.card.imgUrl!);
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

  void _showImageDialog(BuildContext context,String url) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Image.network(url, fit: BoxFit.fill),
        );
      },
    );
  }

}
