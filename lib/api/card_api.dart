import 'package:digimon_meta_site_flutter/model/card.dart';
import 'package:digimon_meta_site_flutter/model/use_card_response_dto.dart';
import 'package:digimon_meta_site_flutter/service/card_data_service.dart';
import 'package:digimon_meta_site_flutter/util/dio.dart';


class CardApi {
  String baseUrl = const String.fromEnvironment('SERVER_URL');
  DioClient dioClient = DioClient();
  CardDataService cardDataService = CardDataService();

  Future<UseCardResponseDto> getUseCard(int id) async {
    try {
      var response = await dioClient.dio
          .get('$baseUrl/api/card/use', queryParameters: {'cardImgId': id});
      if (response.statusCode == 200) {
        return UseCardResponseDto.fromJson(response.data);
      } else {
        throw Exception('Failed to load cards');
      }
    } catch (e) {
      throw Exception('Error occurred while fetching cards');
    }
  }
  
  // Search cards using the CardDataService
  Future<List<DigimonCard>> searchCards({String? cardNo, String? searchText}) async {
    if (cardNo != null && cardNo.isNotEmpty) {
      return cardDataService.searchCardsByNumber(cardNo);
    } else if (searchText != null && searchText.isNotEmpty) {
      return cardDataService.searchCardsByText(searchText);
    }
    return [];
  }
}
