import 'package:flutter/material.dart';
import 'package:project/component/SummonerInfoCard.dart';
import 'package:project/component/RankInfoCard.dart';
import 'package:project/component/MatchHistoryList.dart';

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
    // 솔로 랭크 정보 추출
    final soloRank = rankInfo.firstWhere(
          (entry) => entry['queueType'] == 'RANKED_SOLO_5x5',
      orElse: () => {},
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('${summoner['name']} 님의 전적'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SummonerInfoCard(summoner: summoner),
            if (soloRank.isNotEmpty) ...[
              const SizedBox(height: 12),
              RankInfoCard(rank: soloRank),
            ],
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                '최근 경기',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            MatchHistoryList(
              matches: matchHistory,
              userPuuid: summoner['puuid'],
            ),
          ],
        ),
      ),
    );
  }
}