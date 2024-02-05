import 'dart:typed_data';

import 'package:digimon_meta_site_flutter/model/card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;

class CardInfoWidget extends StatefulWidget {
  final DigimonCard? selectCard;

  const CardInfoWidget({super.key, this.selectCard});

  @override
  State<CardInfoWidget> createState() => _CardInfoWidgetState();
}

class _CardInfoWidgetState extends State<CardInfoWidget> {
  Widget buildTextContainer(String label, String? value) {
    return Container(
      width: 120, // 고정된 너비
      child: Text(
        '$label: ${value ?? 'N/A'}',
        overflow: TextOverflow.ellipsis,
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    if (widget.selectCard == null) {
      return Container();
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: widget.selectCard!.compressedImg == null
                ? Container()

            // Center(child: CircularProgressIndicator())
                : Image.memory(
              widget.selectCard!.compressedImg!,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            flex: 11,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [
                        buildTextContainer('카드 이름', widget.selectCard!.cardName),
                        buildTextContainer('카드 번호', widget.selectCard!.cardNo),
                        buildTextContainer('레벨', widget.selectCard!.lv?.toString()),
                        buildTextContainer('DP', widget.selectCard!.dp?.toString()),
                        buildTextContainer('플레이 비용', widget.selectCard!.playCost?.toString()),
                        buildTextContainer('진화 비용 1', widget.selectCard!.digivolveCost1?.toString()),
                        buildTextContainer('진화 조건 1', widget.selectCard!.digivolveCondition1?.toString()),
                        buildTextContainer('진화 비용 2', widget.selectCard!.digivolveCost2?.toString()),
                        buildTextContainer('진화 조건 2', widget.selectCard!.digivolveCondition2?.toString()),
                        buildTextContainer('색상 1', widget.selectCard!.color1),
                        buildTextContainer('색상 2', widget.selectCard!.color2),
                        buildTextContainer('희귀도', widget.selectCard!.rarity),
                        buildTextContainer('카드 타입', widget.selectCard!.cardType),
                        buildTextContainer('형태', widget.selectCard!.form),
                        buildTextContainer('속성', widget.selectCard!.attributes),
                        buildTextContainer('타입', widget.selectCard!.types?.join(', ')),
                        buildTextContainer('패러렐 카드 여부', widget.selectCard!.isParallel! ? '예' : '아니오'),
                      ],
                    ),
                    if (widget.selectCard!.effect != null)
                      Text('효과: ${widget.selectCard!.effect}'),
                    if (widget.selectCard!.sourceEffect != null)
                      Text('소스 이펙트: ${widget.selectCard!.sourceEffect}'),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }
  }
}

