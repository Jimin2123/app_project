import 'package:flutter/material.dart';
import 'package:project/component/MatchHistoryCard.dart';

class MatchHistoryList extends StatelessWidget {
  final List<Map<String, dynamic>> matches;
  final String userPuuid;

  const MatchHistoryList({
    super.key,
    required this.matches,
    required this.userPuuid,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        return MatchCard(
          match: match,
          userPuuid: userPuuid,
        );
      },
    );
  }
}