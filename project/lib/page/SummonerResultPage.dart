import 'package:flutter/material.dart';
import 'package:project/component/MatchHistoryList.dart';
import 'package:project/component/SummonerInfoCard.dart';

class SummonerResultPage extends StatelessWidget {
  final Map<String, dynamic> summoner;
  final List<Map<String, dynamic>> matchHistory;

  const SummonerResultPage({
    super.key,
    required this.summoner,
    required this.matchHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${summoner['name']} 전적')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SummonerInfoCard(summoner: summoner),
            const SizedBox(height: 10),
            MatchHistoryList(matches: matchHistory),
          ],
        ),
      ),
    );
  }
}