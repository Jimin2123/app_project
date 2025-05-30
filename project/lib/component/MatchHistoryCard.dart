import 'package:flutter/material.dart';

class MatchCard extends StatelessWidget {
  final Map<String, dynamic> match;
  final String userPuuid;

  const MatchCard({
    super.key,
    required this.match,
    required this.userPuuid,
  });

  @override
  Widget build(BuildContext context) {
    final participants = match['info']['participants'] as List;
    final userData = participants.firstWhere(
          (p) => p['puuid'] == userPuuid,
      orElse: () => throw Exception("사용자 정보를 찾을 수 없습니다."),
    );
    final isWin = userData['win'] == true;
    final cardColor = isWin ? Colors.blue[800] : Colors.red[800];

    return Card(
      color: cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(match, userPuuid),
            const SizedBox(height: 8),
            _buildChampionAndStat(match, userPuuid),
          ],
        ),
      ),
    );
  }

  // 게임 모드, 경기 결과(승/패), 시간
  Widget _buildHeader(Map<String, dynamic> match, String userPuuid) {
    final gameMode = match['info']['gameMode'];
    final gameEndTimestamp = match['info']['gameEndTimestamp'];
    final gameDuration = match['info']['gameDuration'];
    final participants = match['info']['participants'] as List;
    final userData = participants.firstWhere(
          (p) => p['puuid'] == userPuuid,
      orElse: () => throw Exception("사용자 정보를 찾을 수 없습니다."),
    );
    final isWin = userData['win'] == true;

    final now = DateTime.now().millisecondsSinceEpoch;
    final minutesAgo = ((now - gameEndTimestamp) / (1000 * 60)).round();
    final duration = Duration(seconds: gameDuration);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(gameMode,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        Text('$minutesAgo분 전',
            style: const TextStyle(color: Colors.white70)),
        Text('${isWin ? "승리" : "패배"} | ${minutes}분 ${seconds}초',
            style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  // 사용자 챔피언, 스탯 정보 표시
  Widget _buildChampionAndStat(Map<String, dynamic> match, String userPuuid) {
    final participants = match['info']['participants'] as List;
    final userData = participants.firstWhere(
          (p) => p['puuid'] == userPuuid,
      orElse: () => throw Exception("사용자 정보를 찾을 수 없습니다."),
    );

    final champLevel = userData['champLevel'];
    final championName = userData['championName'];
    final kills = userData['kills'];
    final deaths = userData['deaths'];
    final assists = userData['assists'];
    final kda = deaths == 0 ? (kills + assists).toString() : ((kills + assists) / deaths).toStringAsFixed(2);
    final cs = userData['totalMinionsKilled'];
    final items = List.generate(7, (i) => userData['item$i']).where((id) => id != 0).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 챔피언 이미지
        Image.network(
          'https://ddragon.leagueoflegends.com/cdn/14.10.1/img/champion/$championName.png',
          width: 48,
          height: 48,
          errorBuilder: (_, __, ___) => const Icon(Icons.error, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$kills / $deaths / $assists',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              Text(
                'KDA: $kda  •  CS: $cs  •  레벨 $champLevel',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Row(
                children: items.map((itemId) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Image.network(
                      'https://ddragon.leagueoflegends.com/cdn/14.10.1/img/item/$itemId.png',
                      width: 28,
                      height: 28,
                      errorBuilder: (_, __, ___) =>
                      const SizedBox(width: 28, height: 28),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        )
      ],
    );
  }
}