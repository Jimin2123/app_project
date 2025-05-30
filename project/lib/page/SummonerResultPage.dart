import 'package:flutter/material.dart';
import 'package:project/component/SummonerInfoCard.dart';
import 'package:project/component/MatchHistoryList.dart';
import 'package:project/component/RankInfoCard.dart';

class SummonerResultPage extends StatelessWidget {
  final Map<String, dynamic> summoner;
  final List<Map<String, dynamic>> matchHistory;
  final List<Map<String, dynamic>> rankInfo;

  const SummonerResultPage({
    super.key,
    required this.summoner,
    required this.matchHistory,
    required this.rankInfo,
  });

  @override
  Widget build(BuildContext context) {
    // 솔랭 랭크만 추출
    final soloRank = rankInfo.firstWhere(
          (entry) => entry['queueType'] == 'RANKED_SOLO_5x5',
      orElse: () => {},
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('${summoner['name']} 님의 전적'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SummonerInfoCard(summoner: summoner),
            if (soloRank.isNotEmpty)
              RankInfoCard(rank: soloRank),
            const SizedBox(height: 12),
            MatchHistoryList(matches: matchHistory),
          ],
        ),
      ),
    );
  }
}