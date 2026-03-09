import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tower/features/game/domain/repositories/team_repository.dart';
import 'package:tower/features/game/domain/repositories/match_repository.dart';
import 'package:tower/features/game/presentation/pages/game_page.dart';
import 'package:tower/features/game/presentation/pages/lobby_page.dart';
import 'package:tower/features/game/presentation/pages/leaderboard_page.dart';
import 'package:tower/features/game/data/repositories/firebase_team_repository.dart';
import 'package:tower/features/game/data/repositories/firebase_match_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const TowerGameApp());
}

class TowerGameApp extends StatelessWidget {
  const TowerGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    final TeamRepository teamRepository = FirebaseTeamRepository();
    final MatchRepository matchRepository = FirebaseMatchRepository();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tower Math Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(
            builder: (_) => LobbyPage(
              teamRepository: teamRepository,
              matchRepository: matchRepository,
            ),
          );
        }

        if (settings.name == '/game') {
          final args = settings.arguments as Map<String, dynamic>?;
          final teamId = args != null && args['teamId'] != null
              ? args['teamId'] as String
              : null;
          final teamName = args != null && args['teamName'] != null
              ? args['teamName'] as String
              : 'Unknown';
          final playerIndex = args != null && args['playerIndex'] != null
              ? args['playerIndex'] as int
              : 0;

          return MaterialPageRoute(
            builder: (_) => GamePage(
              teamId: teamId,
              teamName: teamName,
              playerIndex: playerIndex,
              teamRepository: teamRepository,
            ),
            settings: settings,
          );
        }

        if (settings.name == '/leaderboard') {
          return MaterialPageRoute(
            builder: (_) => LeaderboardPage(teamRepository: teamRepository),
            settings: settings,
          );
        }

        return null;
      },
    );
  }
}
