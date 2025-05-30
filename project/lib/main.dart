import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:project/api/RiotApiService.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 생략되어 있었다면 추가!
  await dotenv.load(fileName: ".env");       // 반드시 await 사용
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SummonerTrack',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1C1C2E),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF2A2E45),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF00B4D8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
      home: const SummonerSearchPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SummonerSearchPage extends StatefulWidget {
  const SummonerSearchPage({super.key});

  @override
  State<SummonerSearchPage> createState() => _SummonerSearchPageState();
}

class _SummonerSearchPageState extends State<SummonerSearchPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final RiotApiService _apiService = RiotApiService();

  String _result = '';
  bool _isLoading = false;

  void _search() async {
    final name = _nameController.text.trim();
    final tag = _tagController.text.trim();

    if (name.isEmpty || tag.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('소환사 이름과 태그를 모두 입력해주세요.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      final data = await _apiService.getSummonerByName(name, tag);
      setState(() {
        _result = '''
        닉네임: ${data['gameName']}
        태그: ${data['tagLine']}
        PUUID: ${data['puuid']}
        ''';
      });
    } catch (e) {
      setState(() {
        _result = '에러 발생: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'SummonerTrack',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: '소환사 이름 (예: Hide on bush)',
                  hintStyle: TextStyle(color: Colors.grey),
                  labelText: '소환사 이름',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _tagController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: '태그 (예: KR1)',
                  hintStyle: TextStyle(color: Colors.grey),
                  labelText: '태그',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _search,
                child: _isLoading
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text('검색'),
              ),
              const SizedBox(height: 30),
              if (_result.isNotEmpty)
                Text(_result, style: const TextStyle(fontSize: 14)),
              const Spacer(),
              const Text(
                'Powered by Riot Games API',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}