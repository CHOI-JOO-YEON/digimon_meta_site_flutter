import 'package:digimon_meta_site_flutter/model/card.dart';
import 'package:digimon_meta_site_flutter/widget/card/card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CardInfoWidget extends StatefulWidget {
  final DigimonCard? selectCard;

  const CardInfoWidget({super.key, this.selectCard});

  @override
  State<CardInfoWidget> createState() => _CardInfoWidgetState();
}

class _CardInfoWidgetState extends State<CardInfoWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.selectCard == null) {
      return Container();
    } else {
      return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        DigimonCard card = widget.selectCard!;


        List<Widget> shortWidgets = createShortInfoWidgets(card, constraints);
        // List<Widget> shortWidgets1 = createShortInfoWidgets1(card, constraints);
        // List<Widget> shortWidgets2 = createShortInfoWidgets2(card, constraints);
        return Padding(
          padding: EdgeInsets.all(constraints.maxHeight * 0.05),
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomCard(
                    width: constraints.maxHeight * 0.9 * 0.715,
                    cardPressEvent: (card) {},
                    card: card),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(card.cardName!),
                     // Row(
                     //    children:
                     //      shortWidgets1
                     //  ),
                     //  Row(
                     //    children: shortWidgets2,
                     //  ),
                     //  if(card.effect!=null)
                     //  LongInfo('효과', card.effect!,constraints.maxHeight*0.2 )
                      Center(
                        child: Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: shortWidgets),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      });
    }
  }

  Widget shortInfo(String category, String text, double height) {
    bool useMarquee = text.length > 8; // 텍스트 길이에 따른 조건
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: Colors.white60),
      child: SizedBox(
        width: height * 3,
        height: height,
        child: Padding(
          padding: EdgeInsets.all(height*0.05),
          child: Row(
            children: [
              Center(
                child: Text(
                  category,
                  style: TextStyle(
                      fontSize: height * 0.3,
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold),
                ),
              ),


              // Expanded(
              //   child: Align(
              //     // alignment: Alignment.center, // 텍스트를 왼쪽 정렬합니다.
              //     child: useMarquee
              //         ? SizedBox(
              //             width: height * 1.6,
              //             child: Marquee(
              //               text: text,
              //               style: TextStyle(fontSize: height * 0.3),
              //               velocity: 50.0,
              //               // 텍스트의 움직이는 속도
              //               pauseAfterRound: Duration.zero,
              //               // 각 라운드 후 일시 정지 없음
              //               blankSpace: height * 0.5, // 텍스트 사이의 공백
              //             ),
              //           )
              //         : FittedBox(
              //             fit: BoxFit.scaleDown, // 컨테이너에 맞게 텍스트 크기 조절
              //             child: Text(
              //               text,
              //               style: TextStyle(fontSize: height * 0.3),
              //               maxLines: 1,
              //             ),
              //           ),
              //   ),
              // ),
              Expanded(
                child: Align(
                  // alignment: Alignment.center, // 텍스트를 왼쪽 정렬합니다.
                  child: useMarquee
                      ? SizedBox(
                          width: height * 1.6,

                        )
                      : FittedBox(
                          fit: BoxFit.scaleDown, // 컨테이너에 맞게 텍스트 크기 조절
                          child: Text(
                            text,
                            style: TextStyle(fontSize: height * 0.3),
                            maxLines: 1,
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

  Widget LongInfo(String category, String text, double height) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: Colors.white60),
      child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center, // 자식들을 왼쪽 정렬합니다.
          children: [
            Center(
              child: Text(
                category,
                style: TextStyle(
                    fontSize: height * 0.3,
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SingleChildScrollView(
                child: Align(
                  alignment: Alignment.center, // 텍스트를 왼쪽 정렬합니다.
                  child:  Text(
                      text,
                      style: TextStyle(fontSize: height * 0.3),
                    ),
                  ),
                ),

            
          ],
        ),
      
    );
  }

  List<Widget> createShortInfoWidgets1(
      DigimonCard digimonCard, BoxConstraints constraints) {
    List<Widget> widgets = [];

    if (digimonCard.cardNo != null) {
      widgets.add(
          shortInfo('카드번호', digimonCard.cardNo!, constraints.maxHeight * 0.2));
    }
    if (digimonCard.lv != null) {
      widgets.add(shortInfo(
          'LV', digimonCard.lv.toString(), constraints.maxHeight * 0.2));
    }
    if (digimonCard.rarity != null) {
      widgets.add(
          shortInfo('레어도', digimonCard.rarity!, constraints.maxHeight * 0.2));
    }
    if (digimonCard.cardType != null) {
      widgets.add(shortInfo(
          '카드타입', digimonCard.cardType!, constraints.maxHeight * 0.2));
    }
    if (digimonCard.playCost != null) {
      widgets.add(shortInfo('등장코스트', digimonCard.playCost.toString(),
          constraints.maxHeight * 0.2));
    }
    return widgets;
  }

  List<Widget> createShortInfoWidgets2(
      DigimonCard digimonCard, BoxConstraints constraints) {
    List<Widget> widgets = [];

    if (digimonCard.dp != null) {
      widgets.add(shortInfo(
          'DP', digimonCard.dp.toString(), constraints.maxHeight * 0.2));
    }
    if (digimonCard.attributes != null) {
      widgets.add(shortInfo(
          '속성', digimonCard.attributes!, constraints.maxHeight * 0.2));
    }
    if (digimonCard.types != null && digimonCard.types!.isNotEmpty) {
      widgets.add(shortInfo(
          '유형', digimonCard.getTypeString(), constraints.maxHeight * 0.2));
    }
    if (digimonCard.form != null) {
      widgets.add(shortInfo(
          '형태', digimonCard.getFormString(), constraints.maxHeight * 0.2));
    }
    if (digimonCard.digivolveCost1 != null) {
      widgets.add(shortInfo('진화조건1', digimonCard.getDigivolveString1(),
          constraints.maxHeight * 0.2));
    }
    if (digimonCard.digivolveCost2 != null) {
      widgets.add(shortInfo('진화조건2', digimonCard.getDigivolveString2(),
          constraints.maxHeight * 0.2));
    }
    return widgets;
  }

  List<Widget> createShortInfoWidgets(
      DigimonCard digimonCard, BoxConstraints constraints) {
    List<Widget> widgets = [];
    if (digimonCard.cardNo != null) {
      widgets.add(
          shortInfo('카드번호', digimonCard.cardNo!, constraints.maxHeight * 0.2));
    }
    if (digimonCard.lv != null) {
      widgets.add(shortInfo(
          'LV', digimonCard.lv.toString(), constraints.maxHeight * 0.2));
    }
    if (digimonCard.rarity != null) {
      widgets.add(
          shortInfo('레어도', digimonCard.rarity!, constraints.maxHeight * 0.2));
    }
    if (digimonCard.cardType != null) {
      widgets.add(shortInfo(
          '카드타입', digimonCard.cardType!, constraints.maxHeight * 0.2));
    }
    if (digimonCard.playCost != null) {
      widgets.add(shortInfo('등장코스트', digimonCard.playCost.toString(),
          constraints.maxHeight * 0.2));
    }
    if (digimonCard.dp != null) {
      widgets.add(shortInfo(
          'DP', digimonCard.dp.toString(), constraints.maxHeight * 0.2));
    }
    if (digimonCard.attributes != null) {
      widgets.add(shortInfo(
          '속성', digimonCard.attributes!, constraints.maxHeight * 0.2));
    }
    if (digimonCard.types != null && digimonCard.types!.isNotEmpty) {
      widgets.add(shortInfo(
          '유형', digimonCard.getTypeString(), constraints.maxHeight * 0.2));
    }
    if (digimonCard.form != null) {
      widgets.add(shortInfo(
          '형태', digimonCard.getFormString(), constraints.maxHeight * 0.2));
    }
    if (digimonCard.digivolveCost1 != null) {
      widgets.add(shortInfo('진화조건1', digimonCard.getDigivolveString1(),
          constraints.maxHeight * 0.2));
    }
    if (digimonCard.digivolveCost2 != null) {
      widgets.add(shortInfo('진화조건2', digimonCard.getDigivolveString2(),
          constraints.maxHeight * 0.2));
    }
    return widgets;
  }
}
