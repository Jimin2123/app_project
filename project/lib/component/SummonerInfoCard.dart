import 'package:flutter/material.dart';

class SummonerInfoCard extends StatelessWidget {
  final Map<String, dynamic> summoner;

  const SummonerInfoCard({super.key, required this.summoner});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.blueGrey[800],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Image.network(
              'https://ddragon.leagueoflegends.com/cdn/14.10.1/img/profileicon/${summoner['profileIconId']}.png',
              width: 60,
              height: 60,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(summoner['name'], style: const TextStyle(color: Colors.white, fontSize: 18)),
                Text('레벨: ${summoner['summonerLevel']}', style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}