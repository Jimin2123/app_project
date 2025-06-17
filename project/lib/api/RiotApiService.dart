import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RiotApiService {
  late final Dio _dioAsia;
  late final Dio _dioKr;


  RiotApiService() {
    final apiKey = dotenv.env['RIOT_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('RIOT_API_KEY가 초기화되지 않았습니다.');
    }

    print(apiKey);

    _dioAsia = Dio(BaseOptions(
      baseUrl: 'https://asia.api.riotgames.com',
      headers: {
        'X-Riot-Token': apiKey,
      },
    ));

    _dioKr = Dio(BaseOptions(
      baseUrl: 'https://kr.api.riotgames.com',
      headers: {
        'X-Riot-Token': apiKey,
      },
    ));
  }

  // 닉네임으로 소환사 정보 가져오기
  Future<Map<String, dynamic>> getSummonerByName(String summonerName, String tagName) async {
    try {
      final name = Uri.encodeComponent(summonerName.trim());
      final tag = Uri.encodeComponent(tagName.trim());

      final response = await _dioAsia.get(
        '/riot/account/v1/accounts/by-riot-id/$name/$tag',
      );

      return response.data;
    } on DioException catch (e) {
      throw Exception('API 호출 실패 (${e.response?.statusCode ?? 0}): ${e.message}');
    }
  }

  // 소환사 정보 가져오기
  Future<Map<String, dynamic>> getSummonerInfo(String puuid) async {
    try {
      final response = await _dioKr.get('/lol/summoner/v4/summoners/by-puuid/$puuid');

      return response.data;
    } on DioException catch (e) {
      throw Exception('API 호출 실패 (${e.response?.statusCode ?? 0}): ${e.message}');
    }
  }

  // 엔트리 정보 가져오기
  Future<List<Map<String, dynamic>>> getRankInfo(String puuid) async {
    try {
      final response = await _dioKr.get('/lol/league/v4/entries/by-puuid/$puuid');

      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw Exception('API 호출 실패 (${e.response?.statusCode ?? 0}): ${e.message}');
    }
  }

  // 소환사 매치 정보 가져오기
  Future<List> getMatchIds(String puuid, {int start = 0, int count = 5}) async {
    try {
      final response = await _dioAsia.get(
        '/lol/match/v5/matches/by-puuid/$puuid/ids?start=$start&count=$count',
      );
      return List.from(response.data);
    } on DioException catch (e) {
      throw Exception('getMatchIds 실패 (${e.response?.statusCode ?? 0}): ${e.message}');
    }
  }
  // 게임 내역 가져오기
  Future<Map<String, dynamic>> getMatchDetail(String matchId) async {
    try {
      final response = await _dioAsia.get('/lol/match/v5/matches/$matchId');

      return response.data;
    } on DioException catch (e) {
      throw Exception(
          'getMatchDetail 실패 (${e.response?.statusCode ?? 0}): ${e.message}');
    }
  }

  Future<List<Map<String, dynamic>>> getMatchDetails(List<String> matchIds) async {
    try {
      final List<Map<String, dynamic>> matchList = [];

      for (final id in matchIds) {
        final detail = await getMatchDetail(id);
        matchList.add(detail);
      }

      return matchList;
    } on DioException catch (e) {
      throw Exception('getMatchDetails 실패 (${e.response?.statusCode ?? 0}): ${e.message}');
    } catch (e) {
      throw Exception('getMatchDetails 예외 발생: $e');
    }
  }
}