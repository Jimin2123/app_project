import 'package:flutter/material.dart';

class RankInfoCard extends StatelessWidget {
  final Map<String, dynamic> rank;

  const RankInfoCard({super.key, required this.rank});

  @override
  Widget build(BuildContext context) {
    final tier = rank['tier'] ?? 'Unranked';
    final rankDiv = rank['rank'] ?? '';
    final lp = rank['leaguePoints'] ?? 0;
    final wins = rank['wins'] ?? 0;
    final losses = rank['losses'] ?? 0;
    final winRate = wins + losses > 0 ? (wins / (wins + losses) * 100).toInt() : 0;

    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Image.asset(
              'assets/tier/$tier.webp',
              width: 60,
              height: 60,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$tier $rankDiv', style: const TextStyle(color: Colors.white, fontSize: 18)),
                Text('$lp LP', style: const TextStyle(color: Colors.white70)),
                Text('승률: $winRate% ($wins승 $losses패)', style: const TextStyle(color: Colors.white54)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}