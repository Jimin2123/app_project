import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RiotApiService {
  final Dio _dio;

  RiotApiService():
      _dio = Dio(
        BaseOptions(
          baseUrl: 'https://asia.api.riotgames.com',
          headers: {
            'X-Riot-Token': dotenv.env['RIOT_API_KEY'] ?? '',
          }
        )
      );

  // 닉네임으로 소환사 정보 가져오기
  Future<Map<String, dynamic>> getSummonerByName(String summonerName, String tagName) async {
    try {
      final response = await _dio.get(
        '/riot/account/v1/accounts/by-riot-id/$summonerName/$tagName',
      );
      return response.data;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode ?? 0;
      final message = e.response?.data.toString() ?? e.message;
      throw Exception('API 호출 실패 ($statusCode): $message');
    }
  }
}