import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:digimon_meta_site_flutter/model/card.dart';

class CustomCard extends StatefulWidget {
  final double width;
  final DigimonCard card;
  final Function(DigimonCard)? cardPressEvent;

  final Function? onHover;
  final Function? onExit;
  final Function? onLongPress;

  const CustomCard({
    super.key,
    required this.width,
    this.cardPressEvent,
    required this.card,
    this.onHover,
    this.onExit, this.onLongPress,
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
            if(widget.cardPressEvent!=null) {
              widget.cardPressEvent!(widget.card);
            }

          },
          onLongPressStart: _handleLongPressStart,
          onLongPressEnd: _handleLongPressEnd,

          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              SizedBox(
                  width: widget.width,
                  child: Image.network(
                    widget.card.smallImgUrl ?? '',
                    fit: BoxFit.fill,
                  )
                  ),
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
