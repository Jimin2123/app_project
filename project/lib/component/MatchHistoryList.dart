import 'package:flutter/material.dart';

class MatchHistoryList extends StatelessWidget {
  final List<Map<String, dynamic>> matches;

  const MatchHistoryList({super.key, required this.matches});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        return Card(
          color: match['win'] ? Colors.blue[700] : Colors.red[700],
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            title: Text(
              '${match['champion']} - ${match['kills']}/${match['deaths']}/${match['assists']}',
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              '${match['gameMode']} / ${match['gameDuration']}초',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        );
      },
    );
  }
}