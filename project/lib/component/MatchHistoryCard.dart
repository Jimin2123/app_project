import 'package:flutter/material.dart';
import 'package:project/component/MatchTeamBoard.dart';

class MatchCard extends StatefulWidget {
  final Map<String, dynamic> match;
  final String userPuuid;

  const MatchCard({
    super.key,
    required this.match,
    required this.userPuuid,
  });

  @override
  State<MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends State<MatchCard> {
  bool _isExpanded = false;
  final Map<String, String> spellMap = {
    "1": "SummonerBoost",
    "3": "SummonerExhaust",
    "4": "SummonerFlash",
    "6": "SummonerHaste",
    "7": "SummonerHeal",
    "11": "SummonerSmite",
    "12": "SummonerTeleport",
    "13": "SummonerMana",
    "14": "SummonerIgnite",
    "21": "SummonerBarrier",
    "32": "SummonerSnowball",
  };

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final participants = widget.match['info']['participants'] as List;
    final userData = participants.firstWhere(
          (p) => p['puuid'] == widget.userPuuid,
      orElse: () => throw Exception("사용자 정보를 찾을 수 없습니다."),
    );

    final isWin = userData['win'] == true;
    final cardColor = isWin ? const Color(0xFF1E2D4F) : const Color(0xFFB34357);

    return GestureDetector(
      onTap: _toggleExpanded,
      child: Card(
        color: cardColor,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 요약 정보
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(widget.match, userData),
                  const SizedBox(height: 12),
                  _buildMainBody(userData),
                ],
              ),
            ),

            // 펼쳐졌을 때 팀 정보 추가
            if (_isExpanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: MatchTeamBoard(
                  participants: participants,
                  userPuuid: widget.userPuuid,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> match, Map<String, dynamic> userData) {
    final gameMode = match['info']['gameMode'];
    final endTimestamp = match['info']['gameEndTimestamp'];
    final gameDuration = match['info']['gameDuration'];
    final isWin = userData['win'] == true;

    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = now - endTimestamp;
    final minutesAgo = diff ~/ 60000;
    final hoursAgo = minutesAgo ~/ 60;
    final daysAgo = hoursAgo ~/ 24;

    String timeText;
    if (minutesAgo < 60) {
      timeText = '$minutesAgo분 전';
    } else if (hoursAgo < 24) {
      timeText = '$hoursAgo시간 전';
    } else {
      timeText = '$daysAgo일 전';
    }

    final minutes = gameDuration ~/ 60;
    final seconds = gameDuration % 60;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(gameMode, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        Text(timeText, style: const TextStyle(color: Colors.white70)),
        Text('${isWin ? "승리" : "패배"} | ${minutes}분 ${seconds}초', style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _buildMainBody(Map<String, dynamic> userData) {
    final champion = userData['championName'];
    final level = userData['champLevel'];
    final kills = userData['kills'];
    final deaths = userData['deaths'];
    final assists = userData['assists'];
    final kda = deaths == 0 ? (kills + assists).toString() : ((kills + assists) / deaths).toStringAsFixed(2);
    final cs = userData['totalMinionsKilled'] + userData['neutralMinionsKilled'];
    final killPart = (userData['challenges']?['killParticipation'] ?? 0.0) * 100;

    final damage = userData['totalDamageDealtToChampions'] ?? 0;
    final damageTaken = userData['totalDamageTaken'] ?? 0;
    final max = [damage, damageTaken].reduce((a, b) => a > b ? a : b);
    final damageRatio = max == 0 ? 0.0 : damage / max;
    final takenRatio = max == 0 ? 0.0 : damageTaken / max;

    final itemIds = List.generate(7, (i) => userData['item$i'] ?? 0);

    final spell1Id = userData['summoner1Id'].toString();
    final spell2Id = userData['summoner2Id'].toString();
    final spell1Img = spellMap[spell1Id];
    final spell2Img = spellMap[spell2Id];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Image.network(
                  'https://ddragon.leagueoflegends.com/cdn/15.11.1/img/champion/$champion.png',
                  width: 48,
                  height: 48,
                ),
                CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.black87,
                  child: Text('$level', style: const TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (spell1Img != null)
                  Image.network(
                    'https://ddragon.leagueoflegends.com/cdn/15.11.1/img/spell/$spell1Img.png',
                    width: 22,
                    height: 22,
                  ),
                const SizedBox(width: 4),
                if (spell2Img != null)
                  Image.network(
                    'https://ddragon.leagueoflegends.com/cdn/15.11.1/img/spell/$spell2Img.png',
                    width: 22,
                    height: 22,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text('$kills / $deaths / $assists', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('KDA: $kda  •  CS: $cs', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text('킬관여율: ${killPart.toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 8),
              Row(
                children: itemIds.map((id) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: id == 0
                        ? Container(width: 28, height: 28, color: Colors.grey[700])
                        : Image.network(
                      'https://ddragon.leagueoflegends.com/cdn/15.11.1/img/item/$id.png',
                      width: 28,
                      height: 28,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Text('딜량: $damage', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              LinearProgressIndicator(value: damageRatio, color: Colors.redAccent, backgroundColor: Colors.white24),
              const SizedBox(height: 4),
              Text('받은 피해량: $damageTaken', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              LinearProgressIndicator(value: takenRatio, color: Colors.blueAccent, backgroundColor: Colors.white24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeamSection(List participants) {
    final blue = participants.where((p) => p['teamId'] == 100).toList();
    final red = participants.where((p) => p['teamId'] == 200).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTeamColumn(blue, CrossAxisAlignment.start),
          _buildTeamColumn(red, CrossAxisAlignment.end),
        ],
      ),
    );
  }

  Widget _buildTeamColumn(List team, CrossAxisAlignment alignment) {
    return Column(
      crossAxisAlignment: alignment,
      children: team.map((player) {
        final champ = player['championName'];
        final name = player['riotIdGameName'] ?? 'Unknown';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: alignment == CrossAxisAlignment.start
                ? [
              Image.network(
                'https://ddragon.leagueoflegends.com/cdn/15.11.1/img/champion/$champ.png',
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 4),
              Text(name, style: const TextStyle(color: Colors.white, fontSize: 12)),
            ]
                : [
              Text(name, style: const TextStyle(color: Colors.white, fontSize: 12)),
              const SizedBox(width: 4),
              Image.network(
                'https://ddragon.leagueoflegends.com/cdn/15.11.1/img/champion/$champ.png',
                width: 20,
                height: 20,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}