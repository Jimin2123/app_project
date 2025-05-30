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

    // 🎨 배경색 설정
    final cardColor = isWin ? const Color(0xFF1E2D4F) : const Color(0xFFB34357);

    return Card(
      color: cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Header는 분리된 Box
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(8),
              ),
              child: _buildHeaderSection(match, userData),
            ),
            const SizedBox(height: 12),

            // ✅ 본문 카드
            Card(
              color: Colors.black26,
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildChampionSection(userData),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildKDASection(userData),
                          const SizedBox(height: 6),
                          _buildDamageGraphSection(userData),
                          const SizedBox(height: 6),
                          _buildItemRowSection(userData),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),
            _buildTeamSection(participants),
          ],
        ),
      ),
    );
  }


  Widget _buildHeaderSection(Map<String, dynamic> match, Map<String, dynamic> userData) {
    final gameMode = match['info']['gameMode'];
    final gameEndTimestamp = match['info']['gameEndTimestamp'];
    final gameDuration = match['info']['gameDuration'];
    final isWin = userData['win'] == true;

    final now = DateTime.now().millisecondsSinceEpoch;
    final diffMillis = now - gameEndTimestamp;
    final diffSeconds = (diffMillis / 1000).round();
    final diffMinutes = (diffSeconds / 60).round();
    final diffHours = (diffMinutes / 60).round();
    final diffDays = (diffHours / 24).round();

    String timeAgo;
    if (diffSeconds < 60) {
      timeAgo = '$diffSeconds초 전';
    } else if (diffMinutes < 60) {
      timeAgo = '$diffMinutes분 전';
    } else if (diffHours < 24) {
      timeAgo = '$diffHours시간 전';
    } else {
      timeAgo = '$diffDays일 전';
    }

    final duration = Duration(seconds: gameDuration);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          gameMode,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(
          timeAgo,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        Text(
          '${isWin ? "승리" : "패배"} | ${minutes}분 ${seconds}초',
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildChampionSection(Map<String, dynamic> userData) {
    final championName = userData['championName'];
    final champLevel = userData['champLevel'];
    final kills = userData['kills'];
    final deaths = userData['deaths'];
    final assists = userData['assists'];
    final Map<String, String> spellIdToImageKey = {
      "1": "SummonerBoost",
      "3": "SummonerExhaust",
      "4": "SummonerFlash",
      "6": "SummonerHaste",
      "7": "SummonerHeal",
      "11": "SummonerSmite",
      "12": "SummonerTeleport",
      "14": "SummonerIgnite",
      "21": "SummonerBarrier",
      "32": "SummonerSnowball",
    };

    final spell1Key = spellIdToImageKey[userData['summoner1Id'].toString()]!;
    final spell2Key = spellIdToImageKey[userData['summoner2Id'].toString()]!;

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Image.network(
              'https://ddragon.leagueoflegends.com/cdn/15.11.1/img/champion/$championName.png',
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
        const SizedBox(height: 4),
        Text(
          '$kills / $deaths / $assists',
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 4),
        // 오른쪽: 스펠 및 룬
        Column(
          children: [
            // 스펠
            Image.network(
              'https://ddragon.leagueoflegends.com/cdn/15.11.1/img/spell/$spell1Key.png',
              width: 22,
              height: 22,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 4),
            Image.network(
              'https://ddragon.leagueoflegends.com/cdn/15.11.1/img/spell/$spell2Key.png',
              width: 22,
              height: 22,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKDASection(Map<String, dynamic> userData) {
    final kills = userData['kills'];
    final deaths = userData['deaths'];
    final assists = userData['assists'];
    final cs = userData['totalMinionsKilled'] + userData['neutralMinionsKilled'];
    final kda = deaths == 0 ? (kills + assists).toString() : ((kills + assists) / deaths).toStringAsFixed(2);
    final killParticipation = (userData['challenges']?['killParticipation'] ?? 0.0) * 100;
    final lane = userData['teamPosition'] ?? 'NONE';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('KDA: $kda  •  CS: $cs', style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text('킬관여율: ${killParticipation.toStringAsFixed(0)}%  •  포지션: $lane', style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildItemRowSection(Map<String, dynamic> userData) {
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
            'https://ddragon.leagueoflegends.com/cdn/15.11.1/img/item/$id.png',
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

  Widget _buildTeamSection(List<dynamic> participants) {
    final blueTeam = participants.where((p) => p['teamId'] == 100).toList();
    final redTeam = participants.where((p) => p['teamId'] == 200).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTeamColumn(blueTeam, CrossAxisAlignment.start),
        _buildTeamColumn(redTeam, CrossAxisAlignment.end),
      ],
    );
  }

  Widget _buildDamageGraphSection(Map<String, dynamic> userData) {
    final damageDealt = userData['totalDamageDealtToChampions'] ?? 0;
    final damageTaken = userData['totalDamageTaken'] ?? 0;

    final maxValue = (damageDealt > damageTaken) ? damageDealt : damageTaken;
    final dealtRatio = maxValue == 0 ? 0.0 : damageDealt / maxValue;
    final takenRatio = maxValue == 0 ? 0.0 : damageTaken / maxValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('딜량: $damageDealt', style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Container(
          width: 120,
          height: 8,
          margin: const EdgeInsets.only(bottom: 6),
          child: LinearProgressIndicator(
            value: dealtRatio,
            backgroundColor: Colors.white24,
            color: Colors.redAccent,
          ),
        ),
        Text('받은 피해량: $damageTaken', style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Container(
          width: 120,
          height: 8,
          child: LinearProgressIndicator(
            value: takenRatio,
            backgroundColor: Colors.white24,
            color: Colors.blueAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamColumn(List<dynamic> team, CrossAxisAlignment alignment) {
    return Column(
      crossAxisAlignment: alignment,
      children: team.map((player) {
        final champion = player['championName'];
        final name = player['riotIdGameName'] ?? 'Unknown';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: alignment == CrossAxisAlignment.end
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              if (alignment == CrossAxisAlignment.start) ...[
                Image.network(
                  'https://ddragon.leagueoflegends.com/cdn/15.11.1/img/champion/$champion.png',
                  width: 20,
                  height: 20,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
                const SizedBox(width: 6),
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 12)),
              ] else ...[
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 12)),
                const SizedBox(width: 6),
                Image.network(
                  'https://ddragon.leagueoflegends.com/cdn/15.11.1/img/champion/$champion.png',
                  width: 20,
                  height: 20,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }


}