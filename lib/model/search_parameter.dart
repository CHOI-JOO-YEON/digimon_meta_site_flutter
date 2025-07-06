class SearchParameter{
  String? searchString;
  
  // New detailed search fields
  String? cardNameSearch;
  String? cardNoSearch;
  String? effectSearch;
  String? sourceEffectSearch;
  
  int? noteId;
  Set<String>? colors ={};
  int? colorOperation;
  Set<int>? lvs;

  Set<String>? cardTypes;
  int typeOperation =1; //0 = and, 1 = or

  Set<String> types = {};
  
  Set<String> forms = {}; // New field for form filtering
  int formOperation = 1; // 0 = and, 1 = or
  
  Set<String> attributes = {}; // New field for attribute filtering
  int attributeOperation = 1; // 0 = and, 1 = or

  int? minPlayCost=0; //
  int? maxPlayCost=20;
  int? minDp=1000;
  int? maxDp=17000;
  int? minDigivolutionCost=0;
  int? maxDigivolutionCost=8;
  Set<String>? rarities;

  int page = 1;
  int size = 84;

  int parallelOption = 0; 

  String orderOption = "sortString";
  bool isOrderDesc = false;
  bool isEnglishCardInclude = true;
  
  // 발매일 관련 필드 추가
  DateTime? minReleaseDate;
  DateTime? maxReleaseDate;
  bool isLatestReleaseFirst = false; // 최신 발매일 우선 정렬

  SearchParameter() {
    // 기본적으로 발매일이 오늘보다 이전이면서 최신 우선 정렬 적용
    setLatestReleasedCardsFirst();
  }

  factory SearchParameter.fromJson(Map<String, dynamic> json) {
    return SearchParameter()
      ..searchString = json['searchString'] as String?
      ..cardNameSearch = json['cardNameSearch'] as String?
      ..cardNoSearch = json['cardNoSearch'] as String?
      ..effectSearch = json['effectSearch'] as String?
      ..sourceEffectSearch = json['sourceEffectSearch'] as String?
      ..noteId = json['noteId'] as int?
      ..colors = json['colors'] != null ? Set<String>.from(json['colors']) : null
      ..colorOperation = json['colorOperation'] as int?
      ..lvs = json['lvs'] != null ? Set<int>.from(json['lvs']) : null
      ..cardTypes = json['cardTypes'] != null ? Set<String>.from(json['cardTypes']) : null
      ..typeOperation = json['typeOperation'] as int? ?? 1
      ..types = (json['types'] as List<dynamic>?)?.map((e) => e as String).toSet() ?? {}
      ..forms = (json['forms'] as List<dynamic>?)?.map((e) => e as String).toSet() ?? {}
      ..formOperation = json['formOperation'] as int? ?? 1
      ..attributes = (json['attributes'] as List<dynamic>?)?.map((e) => e as String).toSet() ?? {}
      ..attributeOperation = json['attributeOperation'] as int? ?? 1
      ..minPlayCost = json['minPlayCost'] as int?
      ..maxPlayCost = json['maxPlayCost'] as int?
      ..minDp = json['minDp'] as int?
      ..maxDp = json['maxDp'] as int?
      ..minDigivolutionCost = json['minDigivolutionCost'] as int?
      ..maxDigivolutionCost = json['MaxDigivolutionCost'] as int?
      ..rarities = json['rarities'] != null ? Set<String>.from(json['rarities']) : null
      ..page = json['page'] as int? ?? 1
      ..size = json['size'] as int? ?? 84
      ..parallelOption = json['parallelOption'] as int? ?? 0
      ..orderOption = json['orderOption'] as String? ?? 'sortString'
      ..isOrderDesc = json['isOrderDesc'] as bool? ?? false
      ..isEnglishCardInclude = json['isEnglishCardInclude'] as bool? ?? true
      ..minReleaseDate = json['minReleaseDate'] != null ? DateTime.parse(json['minReleaseDate']) : null
      ..maxReleaseDate = json['maxReleaseDate'] != null ? DateTime.parse(json['maxReleaseDate']) : DateTime.now()
      ..isLatestReleaseFirst = json['isLatestReleaseFirst'] as bool? ?? true;
  }
  
  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = {};
    if (searchString != null) data['searchString'] = searchString;
    if (cardNameSearch != null) data['cardNameSearch'] = cardNameSearch;
    if (cardNoSearch != null) data['cardNoSearch'] = cardNoSearch;
    if (effectSearch != null) data['effectSearch'] = effectSearch;
    if (sourceEffectSearch != null) data['sourceEffectSearch'] = sourceEffectSearch;
    if (noteId != null) data['noteId'] = noteId;
    if (colors != null) data['colors'] = colors!.toList();
    if (colorOperation != null) data['colorOperation'] = colorOperation;
    if (lvs != null) data['lvs'] = lvs!.toList();
    if (cardTypes != null) data['cardTypes'] = cardTypes!.toList();
    if (minPlayCost != null) data['minPlayCost'] = minPlayCost;
    if (maxPlayCost != null) data['maxPlayCost'] = maxPlayCost;
    if (minDp != null) data['minDp'] = minDp;
    if (maxDp != null) data['maxDp'] = maxDp;
    if (minDigivolutionCost != null) data['minDigivolutionCost'] = minDigivolutionCost;
    if (maxDigivolutionCost != null) data['MaxDigivolutionCost'] = maxDigivolutionCost;
    if (rarities != null) data['rarities'] = rarities!.toList();
    data['page'] = page;
    data['size'] = size;
    data['parallelOption'] = parallelOption;
    data['orderOption'] = orderOption;
    data['isOrderDesc'] = isOrderDesc;
    data['isEnglishCardInclude'] = isEnglishCardInclude;
    
    data['types'] = types.toList();
    data['typeOperation'] = typeOperation;
    
    data['forms'] = forms.toList();
    data['formOperation'] = formOperation;
    
    data['attributes'] = attributes.toList();
    data['attributeOperation'] = attributeOperation;
    
    if (minReleaseDate != null) data['minReleaseDate'] = minReleaseDate!.toIso8601String();
    if (maxReleaseDate != null) data['maxReleaseDate'] = maxReleaseDate!.toIso8601String();
    data['isLatestReleaseFirst'] = isLatestReleaseFirst;

    return data;
  }

  @override
  String toString() {
    return 'SearchParameter{ searchString: $searchString, cardNameSearch: $cardNameSearch, cardNoSearch: $cardNoSearch, effectSearch: $effectSearch, sourceEffectSearch: $sourceEffectSearch, noteId: $noteId, colors: ${colors?.join(", ")}, colorOperation: $colorOperation, lvs: ${lvs?.join(", ")}, cardTypes: ${cardTypes?.join(", ")}, forms: ${forms.join(", ")}, attributes: ${attributes.join(", ")}, minPlayCost: $minPlayCost, maxPlayCost: $maxPlayCost, minDp: $minDp, maxDp: $maxDp, minDigivolutionCost: $minDigivolutionCost, maxDigivolutionCost: $maxDigivolutionCost, rarities: ${rarities?.join(", ")}, page: $page, size: $size, parallelOption: $parallelOption, orderOption: $orderOption, isOrderDesc: $isOrderDesc, minReleaseDate: $minReleaseDate, maxReleaseDate: $maxReleaseDate, isLatestReleaseFirst: $isLatestReleaseFirst}';
  }

  void reset() {
    searchString = null;
    cardNameSearch = null;
    cardNoSearch = null;
    effectSearch = null;
    sourceEffectSearch = null;
    noteId = null;
    colors ={};
    colorOperation = null;
    lvs = null;

    cardTypes = null;
    typeOperation =1; 

    types = {};
    forms = {};
    formOperation = 1;
    attributes = {};
    attributeOperation = 1;

    minPlayCost=0; 
    maxPlayCost=20;
    minDp=1000;
    maxDp=17000;
    minDigivolutionCost=0;
    maxDigivolutionCost=8;
    rarities = null;

    page = 1;
    size = 84;

    parallelOption = 0;

    orderOption = "sortString";
    isOrderDesc = false;
    isEnglishCardInclude = true;
    
    // 기본적으로 최신 발매일 우선 정렬 적용
    setLatestReleasedCardsFirst();
  }
  
  // 편의 메서드: 발매일이 오늘보다 이전이면서 최신 우선 정렬
  void setLatestReleasedCardsFirst() {
    maxReleaseDate = DateTime.now();
    isLatestReleaseFirst = true;
  }
  
  // 편의 메서드: 특정 기간 내 발매된 카드 검색
  void setReleaseDateRange(DateTime? minDate, DateTime? maxDate) {
    minReleaseDate = minDate;
    maxReleaseDate = maxDate;
  }
  
  // 편의 메서드: 특정 날짜 이후 발매된 카드 검색
  void setReleasedAfter(DateTime date) {
    minReleaseDate = date;
  }
  
  // 편의 메서드: 특정 날짜 이전 발매된 카드 검색
  void setReleasedBefore(DateTime date) {
    maxReleaseDate = date;
  }
}