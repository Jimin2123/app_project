import 'package:flutter/material.dart';
import 'package:project/component/MatchHistoryCard.dart';
import 'package:project/component/SummonerInfoCard.dart';
import 'package:project/component/RankInfoCard.dart';
import 'package:project/api/RiotApiService.dart'; // riotApiService 사용 가정

class SummonerResultPage extends StatefulWidget {
  final Map<String, dynamic> summoner;
  final List<Map<String, dynamic>> rankInfo;
  final RiotApiService riotApiService; // 추가


  const SummonerResultPage({
    super.key,
    required this.summoner,
    required this.rankInfo,
    required this.riotApiService,
  });

  @override
  State<SummonerResultPage> createState() => _SummonerResultPageState();
}

class _SummonerResultPageState extends State<SummonerResultPage> {
  final List<Map<String, dynamic>> _matchHistory = [];
  final ScrollController _scrollController = ScrollController();

  int _start = 0;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchMatches();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      _fetchMatches();
    }
  }

  Future<void> _fetchMatches() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final matchIds = await widget.riotApiService.getMatchIds(widget.summoner['puuid'], start: _start, count: 5);

      if (matchIds.isEmpty) {
        setState(() => _hasMore = false);
      } else {
        final matches = await Future.wait(
          matchIds.map((id) => widget.riotApiService.getMatchDetail(id)),
        );

        setState(() {
          _matchHistory.addAll(matches);
          _start += matchIds.length;
        });
      }
    } catch (e) {
      debugPrint("경기 정보 로딩 실패: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final soloRank = widget.rankInfo.firstWhere(
          (entry) => entry['queueType'] == 'RANKED_SOLO_5x5',
      orElse: () => {},
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.summoner['name']} 님의 전적'),
      ),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          SummonerInfoCard(summoner: widget.summoner),
          if (soloRank.isNotEmpty)
            ...[
              const SizedBox(height: 12),
              RankInfoCard(rank: soloRank),
            ],
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '최근 경기',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ..._matchHistory.map(
                (match) => MatchCard(
              key: ValueKey(match['metadata']?['matchId']),
              match: match,
              userPuuid: widget.summoner['puuid'],
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}