import 'package:flutter/material.dart';
import 'package:tower/features/game/domain/repositories/team_repository.dart';
import 'package:tower/features/game/data/entities/team.dart';

class LeaderboardPage extends StatelessWidget {
  final TeamRepository teamRepository;

  const LeaderboardPage({super.key, required this.teamRepository});

  double _bestProgress(Team team) {
    if (team.players.isEmpty || team.target == 0) return 0.0;
    final nonNull = team.players.where((v) => v != null).cast<int>();
    if (nonNull.isEmpty) return 0.0;
    final best = nonNull.reduce((a, b) => a > b ? a : b);
    return (best / team.target).clamp(0.0, 1.0);
  }

  int _completedCount(Team team) {
    return team.players.where((v) => v != null && v == team.target).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: StreamBuilder<List<Team>>(
        stream: teamRepository.teamsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final teams = List<Team>.from(snapshot.data!);

          teams.sort((a, b) {
            final completedDiff = _completedCount(b) - _completedCount(a);
            if (completedDiff != 0) return completedDiff;
            final progressDiff = _bestProgress(b).compareTo(_bestProgress(a));
            if (progressDiff != 0) return progressDiff;
            return a.name.compareTo(b.name);
          });

          if (teams.isEmpty) {
            return const Center(child: Text('No teams yet.'));
          }

          return ListView.builder(
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final team = teams[index];
              final rank = index + 1;
              final completed = _completedCount(team);
              final progress = _bestProgress(team);

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      child: Text(
                        '$rank',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      team.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Target: ${team.target}'),
                        const SizedBox(height: 4),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: progress),
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                          builder: (context, value, _) {
                            return LinearProgressIndicator(
                              value: value,
                              minHeight: 6,
                              backgroundColor: Colors.grey.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Completed towers: $completed • Best progress: ${(progress * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
