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
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGameInfoSection(match, userPuuid),
            const SizedBox(width: 12),
            _buildChampionAndSpellSection(match, userPuuid),
            const SizedBox(width: 12),
            _buildKDASection(match, userPuuid),
            const SizedBox(height: 12),
            _buildTeamSection(match),
          ],
        ),
      ),
    );
  }

  // 게임 정보 섹션
  Widget _buildGameInfoSection(Map<String, dynamic> match, String userPuuid) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          gameMode,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$minutesAgo시간 전',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              isWin ? '승리' : '패배',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$minutes분 ${seconds}초',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        )
      ],
    );
  }

  // 챔피언 정보 섹션
  Widget _buildChampionAndSpellSection(Map<String, dynamic> match, String userPuuid) {
    final participants = match['info']['participants'] as List;
    final userData = participants.firstWhere(
          (p) => p['puuid'] == userPuuid,
      orElse: () => throw Exception("사용자 정보를 찾을 수 없습니다."),
    );

    final championName = userData['championName'];
    final champLevel = userData['champLevel'];
    final kills = userData['kills'];
    final deaths = userData['deaths'];
    final assists = userData['assists'];
    final cs = userData['totalMinionsKilled'];

    final kda = deaths == 0 ? (kills + assists).toString() : ((kills + assists) / deaths).toStringAsFixed(2);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 왼쪽: 챔피언 이미지 + 레벨
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Image.network(
              'https://ddragon.leagueoflegends.com/cdn/14.10.1/img/champion/$championName.png',
              width: 48,
              height: 48,
            ),
            CircleAvatar(
              radius: 10,
              backgroundColor: Colors.black54,
              child: Text(
                champLevel.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ],
        ),

        const SizedBox(width: 12),

        // 오른쪽: 스탯 정보 + 아이템
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$kills / $deaths / $assists', style: const TextStyle(color: Colors.white, fontSize: 16)),
            Text('KDA: $kda  •  CS: $cs  •  레벨 $champLevel', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 6),
            _buildItemRowSection(userData), // ✅ 아이템, MVP 태그 등
          ],
        ),
      ],
    );
  }

  // KDA 관련 섹션
  Widget _buildKDASection(Map<String, dynamic> match, String userPuuid) {
    final participants = match['info']['participants'] as List;
    final userData = participants.firstWhere(
          (p) => p['puuid'] == userPuuid,
      orElse: () => throw Exception("사용자 정보를 찾을 수 없습니다."),
    );

    final kills = userData['kills'];
    final deaths = userData['deaths'];
    final assists = userData['assists'];
    final kda = deaths == 0 ? (kills + assists).toString() : ((kills + assists) / deaths).toStringAsFixed(2);
    final cs = userData['totalMinionsKilled'] + userData['neutralMinionsKilled'];
    final killParticipation = (userData['challenges']?['killParticipation'] ?? 0.0) * 100;
    final lane = userData['teamPosition'] ?? 'NONE';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('KDA: $kda  •  CS: $cs',
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text('킬관여율: ${killParticipation.toStringAsFixed(0)}%  •  포지션: $lane',
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildItemRowSection(Map<String, dynamic> userData) {
    // 아이템 ID (0은 빈 슬롯)
    final itemIds = List.generate(7, (i) => userData['item$i'] ?? 0);

    return Row(
      children: itemIds.map<Widget>((id) {
        if (id == 0) {
          return Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Image.network(
            'https://ddragon.leagueoflegends.com/cdn/14.10.1/img/item/$id.png',
            width: 28,
            height: 28,
            errorBuilder: (_, __, ___) => Container(
              width: 28,
              height: 28,
              color: Colors.grey,
              child: const Icon(Icons.help_outline, size: 16),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTeamSection(Map<String, dynamic> match) {
    final participants = match['info']['participants'] as List;

    // 팀 나누기
    final blueTeam = participants.where((p) => p['teamId'] == 100).toList();
    final redTeam = participants.where((p) => p['teamId'] == 200).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTeamColumn(blueTeam),
        _buildTeamColumn(redTeam),
      ],
    );
  }

  Widget _buildTeamColumn(List<dynamic> team) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: team.map((player) {
        final champion = player['championName'];
        final name = player['riotIdGameName'] ?? 'Unknown';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Image.network(
                'https://ddragon.leagueoflegends.com/cdn/14.10.1/img/champion/$champion.png',
                width: 20,
                height: 20,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
              const SizedBox(width: 6),
              Text(name, style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
        );
      }).toList(),
    );
  }
}