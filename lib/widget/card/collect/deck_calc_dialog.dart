import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../model/CardQuantityCalculator.dart';
import '../../../model/card.dart';
import '../../../model/deck_response_dto.dart';
import '../../../model/format.dart';
import '../../../provider/collect_provider.dart';
import '../../deck/color_palette.dart';

class DeckCalcDialog extends StatefulWidget {
  final List<FormatDto> formats;
  final Map<int, List<DeckResponseDto>> deckMap;

  const DeckCalcDialog(
      {super.key, required this.formats, required this.deckMap});

  @override
  State<DeckCalcDialog> createState() => _DeckCalcDialogState();
}

class _DeckCalcDialogState extends State<DeckCalcDialog> {
  late CardQuantityCalculator _calculator;
  int _selectedFormatId = 0;
  Map<int, Set<int>> _checkedDeckIds = {};
  bool _showExceededCards = true;
  bool _showEnCards = true;
  bool _useCardNoAsKey = true;

  @override
  void initState() {
    super.initState();
    _calculator = CardQuantityCalculator();
    _selectedFormatId =
        widget.formats.isNotEmpty ? widget.formats[0].formatId! : 0;
    _initializeCheckedDeckIds();
  }

  void _initializeCheckedDeckIds() {
    for (int formatId in widget.deckMap.keys) {
      _checkedDeckIds[formatId] = Set<int>();
    }
  }

  void _onFormatSelected(int formatId) {
    setState(() {
      _selectedFormatId = formatId;
    });
  }

  void _onDeckChecked(DeckResponseDto deck, bool isChecked) {
    int formatId = deck.formatId!;
    int deckId = deck.deckId!;

    setState(() {
      if (isChecked) {
        _calculator.addDeck(deck);
        _checkedDeckIds[formatId]!.add(deckId);
      } else {
        _calculator.removeDeck(deck);
        _checkedDeckIds[formatId]!.remove(deckId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    CollectProvider collectProvider = Provider.of(context, listen: false);

    // 카드 리스트 정렬
    List<DigimonCard> sortedCards = !_useCardNoAsKey
        ? _calculator.maxQuantitiesByCardNo.entries
        .map((entry) => _calculator.getCardByCardNo(entry.key))
        .whereType<DigimonCard>()
        .toList()

        : _calculator.maxQuantitiesById.keys
        .map((id) => _calculator.getCardById(id))
        .whereType<DigimonCard>()
        .toList();

    sortedCards.sort((a, b) => (a.sortString ?? '').compareTo(b.sortString ?? ''));
    return AlertDialog(
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        child: Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(right: BorderSide(color: Colors.grey)),
                        ),
                        child: Column(
                          children: [
                            Text('포맷',style: TextStyle(fontSize: 30),),
                            Expanded(
                              child: ListView.builder(
                                itemCount: widget.formats.length,
                                itemBuilder: (context, index) {
                                  final format = widget.formats[index];
                                  return ListTile(
                                    title: Text(format.name ?? ''),
                                    onTap: () => _onFormatSelected(format.formatId!),
                                    selected: _selectedFormatId == format.formatId,
                                    selectedTileColor: Colors.grey[200],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(right: BorderSide(color: Colors.grey)),
                        ),
                        child: Column(
                          children: [
                            Text('덱 이름',style: TextStyle(fontSize: 30)),
                            Expanded(
                              child: ListView.builder(
                                itemCount:
                                    widget.deckMap[_selectedFormatId]?.length ?? 0,
                                itemBuilder: (context, index) {
                                  final deck =
                                      widget.deckMap[_selectedFormatId]![index];
                                  final isChecked = _checkedDeckIds[_selectedFormatId]
                                          ?.contains(deck.deckId) ??
                                      false;
                                  return CheckboxListTile(
                                    title: Row(
                                      children: [
                                        ColorWheel(
                                          colors: deck.colors!,
                                        ),
                                        SizedBox(width: 10,),
                                        Text(deck.deckName ?? ''),
                                      ],
                                    ),
                                    value: isChecked,
                                    onChanged: (value) =>
                                        _onDeckChecked(deck, value!),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text('필요한 카드 목록',style: TextStyle(fontSize: 30)),
                          Container(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _showExceededCards,
                                      onChanged: (value) {
                                        setState(() {
                                          _showExceededCards = value!;
                                        });
                                      },
                                    ),
                                    Text('이미 가지고 있는 카드 표시'),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _showEnCards,
                                      onChanged: (value) {
                                        setState(() {
                                          _showEnCards = value!;
                                        });
                                      },
                                    ),
                                    Text('미발매 카드 표시'),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _useCardNoAsKey,
                                      onChanged: (value) {
                                        setState(() {
                                          _useCardNoAsKey = value!;
                                        });
                                      },
                                    ),
                                    Text('패레 구분'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: sortedCards.length,
                              itemBuilder: (context, index) {
                                final card = sortedCards[index];
                                final quantity = !_useCardNoAsKey
                                    ? _calculator.maxQuantitiesByCardNo[card.cardNo] ?? 0
                                    : _calculator.maxQuantitiesById[card.cardId] ?? 0;
                                final nowQuantity = collectProvider.getCardQuantity(card.cardId!);

                                if ((!_showExceededCards && nowQuantity < quantity) || _showExceededCards) {
                                  if ((!_showEnCards && !card.isEn) || _showEnCards) {
                                    return Card(
                                      child: ListTile(
                                        leading: Image.network(card.smallImgUrl ?? ''),
                                        title: Text('${card.cardNo} ${card.cardName}' ?? ''),
                                        subtitle: Text(
                                          '소지: $nowQuantity / 필요: $quantity',
                                          style: TextStyle(
                                              color: nowQuantity >= quantity ? Colors.green : Colors.red),
                                        ),
                                      ),
                                    );
                                  }
                                }
                                return SizedBox();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
