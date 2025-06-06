import 'dart:convert';

import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:digimon_meta_site_flutter/model/search_parameter.dart';
import 'package:digimon_meta_site_flutter/router.dart';
import 'package:digimon_meta_site_flutter/service/keyword_service.dart';
import 'package:digimon_meta_site_flutter/widget/common/toast_overlay.dart';
import 'package:provider/provider.dart';
import 'package:digimon_meta_site_flutter/provider/deck_provider.dart';

@RoutePage()
class KeywordInfoPage extends StatefulWidget {
  @override
  State<KeywordInfoPage> createState() => _KeywordInfoPageState();
}

class _KeywordInfoPageState extends State<KeywordInfoPage> {
  final KeywordService _keywordService = KeywordService();
  bool _isLoading = true;
  List<KeywordCategory> _categories = [];
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    _loadKeywords();
  }

  Future<void> _loadKeywords() async {
    await _keywordService.loadKeywords();
    setState(() {
      _categories = _keywordService.getAllCategories();
      _isLoading = false;
    });
  }

  // 검색어에 따라 카테고리 필터링
  List<KeywordCategory> _getFilteredCategories() {
    if (_searchQuery == null || _searchQuery!.isEmpty) {
      return _categories;
    }
    
    final query = _searchQuery!.toLowerCase();
    return _categories.where((category) {
      // 카테고리 이름에 검색어가 포함되는지 확인
      if (category.name.toLowerCase().contains(query)) {
        return true;
      }
      
      // 카테고리 설명에 검색어가 포함되는지 확인
      if (category.description.toLowerCase().contains(query)) {
        return true;
      }
      
      // 패턴 중에 검색어가 포함된 것이 있는지 확인
      for (var pattern in category.patterns) {
        if (pattern.pattern.toLowerCase().contains(query) || 
            pattern.description.toLowerCase().contains(query)) {
          return true;
        }
      }
      
      return false;
    }).toList();
  }

  // 키워드로 카드 검색 화면으로 이동
  void _searchCardsByKeyword(BuildContext context, String keyword) {
    // 키워드 별칭 맵핑
    Map<String, List<String>> keywordAliases = {
      'S 어택': ['시큐리티 어택'],
      '시큐리티 어택': ['S 어택'],
      // 필요한 다른 별칭들을 여기에 추가
    };

    // 검색할 키워드 목록 생성
    List<String> keywordsToSearch = [keyword];
    if (keywordAliases.containsKey(keyword)) {
      keywordsToSearch.addAll(keywordAliases[keyword]!);
    }

    // 다이얼로그 표시
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('키워드로 카드 검색'),
          content: Text('$keyword 키워드를 가진 카드를 검색하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // 다이얼로그 닫기
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // 다이얼로그 닫기
                
                // 현재 덱 정보 가져오기
                final deckProvider = Provider.of<DeckProvider>(context, listen: false);
                final currentDeck = deckProvider.currentDeck;
                
                // 검색 파라미터 생성
                SearchParameter searchParameter = SearchParameter();
                
                // 여러 키워드를 OR 조건으로 결합
                String regexPattern = keywordsToSearch.map((k) => '《.*?' + k + '.*?》').join('|');
                searchParameter.searchString = '@${regexPattern}';
                
                // 검색 파라미터를 JSON으로 변환하여 DeckBuilderRoute로 전달
                // 현재 덱 정보도 함께 전달
                context.navigateTo(
                  MainRoute(
                    children: [
                      DeckBuilderRoute(
                        deck: currentDeck,
                        searchParameterString: json.encode(searchParameter.toJson())
                      )
                    ]
                  )
                );
              },
              child: Text('검색'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 검색 바
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '키워드 검색...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                
                // 키워드 리스트
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '키워드 목록',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _getFilteredCategories().length,
                          itemBuilder: (context, index) {
                            final category = _getFilteredCategories()[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 타이틀과 검색 버튼을 포함하는 Row
                                    Row(
                                      children: [
                                        // 타이틀
                                        Expanded(
                                          child: Text(
                                            category.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Color.fromRGBO(206, 101, 1, 1), // 주황색으로 통일
                                            ),
                                          ),
                                        ),
                                        // 검색 버튼
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Color.fromRGBO(206, 101, 1, 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: Color.fromRGBO(206, 101, 1, 0.3),
                                              width: 1.0,
                                            ),
                                          ),
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.search,
                                              color: Color.fromRGBO(206, 101, 1, 1),
                                              size: 20,
                                            ),
                                            tooltip: '이 키워드로 카드 검색',
                                            onPressed: () {
                                              _searchCardsByKeyword(context, category.name);
                                            },
                                            padding: EdgeInsets.all(8),
                                            constraints: BoxConstraints(),
                                            splashRadius: 24,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // 설명
                                    Text(
                                      category.description,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              )
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
} 