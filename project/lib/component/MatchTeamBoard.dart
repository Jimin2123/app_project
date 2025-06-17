import 'package:flutter/material.dart';

class MatchTeamBoard extends StatelessWidget {
  final List<dynamic> participants;
  final String userPuuid;

  const MatchTeamBoard({
    super.key,
    required this.participants,
    required this.userPuuid,
  });

  @override
  Widget build(BuildContext context) {
    final blueTeam = participants.where((p) => p['teamId'] == 100).toList();
    final redTeam = participants.where((p) => p['teamId'] == 200).toList();

    // 사용자 기준 팀 정보
    final user = participants.firstWhere((p) => p['puuid'] == userPuuid);
    final userTeamId = user['teamId'];
    final userWin = user['win'] == true;

    // 승패 텍스트
    final redWin = userTeamId == 200 ? userWin : !userWin;
    final blueWin = !redWin;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTeamBlockRowTitle(title: '레드팀', isWin: redWin),
        _buildTeamBlock(redTeam),
        const SizedBox(height: 10),
        _buildMatchStatsRow(redTeam, blueTeam),
        const SizedBox(height: 10),
        _buildTeamBlockRowTitle(title: '블루팀', isWin: blueWin),
        _buildTeamBlock(blueTeam),
      ],
    );
  }

  Widget _buildTeamBlockRowTitle({required String title, required bool isWin}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: isWin ? Colors.red[800] : Colors.blue[800],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${isWin ? '승리' : '패배'} • $title',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildTeamBlock( List team) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2B2B40),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: team.map((player) => _buildPlayerRow(player)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMatchStatsRow(List redTeam, List blueTeam) {
    final redKills = redTeam.fold<int>(0, (sum, p) => sum + (p['kills'] ?? 0) as int);
    final blueKills = blueTeam.fold<int>(0, (sum, p) => sum + (p['kills'] ?? 0) as int);
    final redGold = redTeam.fold<int>(0, (sum, p) => sum + (p['goldEarned'] ?? 0) as int);
    final blueGold = blueTeam.fold<int>(0, (sum, p) => sum + (p['goldEarned'] ?? 0) as int);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF222233),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildStatRow("Total Kill", redKills, blueKills, color: Colors.pink),
          const SizedBox(height: 4),
          _buildStatRow("Total Gold", redGold, blueGold, color: Colors.blue),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, int red, int blue, {required Color color}) {
    return Row(
      children: [
        Expanded(
          child: Center(
            child: Text(
              "$blue",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Center(
            child: Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              "$red",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerRow(Map<String, dynamic> p) {
    final champ = p['championName'];
    final name = p['riotIdGameName'] ?? 'Unknown';
    final kills = p['kills'];
    final deaths = p['deaths'];
    final assists = p['assists'];
    final kda = deaths == 0 ? (kills + assists).toString() : ((kills + assists) / deaths).toStringAsFixed(2);
    final kp = ((p['challenges']?['killParticipation'] ?? 0.0) * 100).toStringAsFixed(0);
    final cs = p['totalMinionsKilled'] + p['neutralMinionsKilled'];
    final items = List.generate(7, (i) => p['item$i'] ?? 0);
    final damage = p['totalDamageDealtToChampions'] ?? 0;
    final taken = p['totalDamageTaken'] ?? 0;
    final max = (damage > taken) ? damage : taken;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        children: [
          // 챔피언 아이콘
          Image.network(
            'https://ddragon.leagueoflegends.com/cdn/15.11.1/img/champion/$champ.png',
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 6),

          // 이름 + 스탯
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 12)),
                Text('KDA: $kills/$deaths/$assists  •  킬관여 $kp%  •  CS $cs',
                    style: const TextStyle(color: Colors.white70, fontSize: 11)),
                Row(
                  children: [
                    Text('딜: $damage', style: const TextStyle(color: Colors.redAccent, fontSize: 10)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: max == 0 ? 0.0 : damage / max,
                        color: Colors.redAccent,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text('피해: $taken', style: const TextStyle(color: Colors.blueAccent, fontSize: 10)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: max == 0 ? 0.0 : taken / max,
                        color: Colors.blueAccent,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 6),

          // 아이템
          Wrap(
            spacing: 2,
            runSpacing: 2,
            children: items.map((id) {
              return Container(
                width: 22,
                height: 22,
                color: id == 0 ? Colors.grey[800] : null,
                child: id == 0
                    ? null
                    : Image.network(
                  'https://ddragon.leagueoflegends.com/cdn/15.11.1/img/item/$id.png',
                  fit: BoxFit.cover,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}