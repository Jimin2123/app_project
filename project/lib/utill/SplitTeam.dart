Map<String, List<Map<String, dynamic>>> splitTeams(List<dynamic> participants) {
  final blueTeam = <Map<String, dynamic>>[];
  final redTeam = <Map<String, dynamic>>[];

  for(final p in participants) {
    final player = {
      'championName': p['championName'],
      'riotIdGameName': p['riotIdGameName'],
      'champLevel': p['champLevel'],
      'damageDealt': p['totalDamageDealt'],
      'damageTaken': p['totalDamageTaken'],
      'lane': p['individualPosition'] ?? p['teamPosition'],
      'kda': '${p['kills']} / ${p['deaths']} / ${p['assists']}',
      "spell1" : p['spell1Casts'],
      "spell2" : p['spell2Casts'],
    };

    if (p['teamId'] == 100) {
      blueTeam.add(player);
    } else if (p['teamId'] == 200) {
      redTeam.add(player);
    }
  }
  }