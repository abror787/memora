import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../cards/presentation/bloc/cards_bloc.dart';
import '../../../cards/presentation/bloc/cards_state.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Статистика'),
      ),
      body: SafeArea(
        child: BlocBuilder<CardsBloc, CardsState>(
          builder: (context, state) {
            if (state is CardsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CardsLoaded) {
              final cards = state.cards;
              final totalCards = cards.length;
              final totalSuccess =
                  cards.fold<int>(0, (sum, c) => sum + c.successCount);
              final totalFails =
                  cards.fold<int>(0, (sum, c) => sum + c.failCount);
              final totalAnswers = totalSuccess + totalFails;
              final accuracy = totalAnswers > 0
                  ? (totalSuccess / totalAnswers * 100).round()
                  : 0;
              final cardsStudied =
                  cards.where((c) => c.successCount > 0).length;
              final totalPoints = totalSuccess * 10;
              final level = totalPoints ~/ 100;
              final streak = _calculateStreak(cards);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MainStatCard(
                      accuracy: accuracy,
                      totalPoints: totalPoints,
                      level: level,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _StatTile(
                            icon: Icons.style_rounded,
                            value: '$totalCards',
                            label: 'Всего',
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatTile(
                            icon: Icons.check_circle_rounded,
                            value: '$cardsStudied',
                            label: 'Изучено',
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _StatTile(
                            icon: Icons.thumb_up_rounded,
                            value: '$totalSuccess',
                            label: 'Правильно',
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatTile(
                            icon: Icons.thumb_down_rounded,
                            value: '$totalFails',
                            label: 'Ошибки',
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _StatTile(
                      icon: Icons.local_fire_department_rounded,
                      value: '$streak',
                      label: 'Макс. серия',
                      color: AppColors.warning,
                      fullWidth: true,
                    ),
                    const SizedBox(height: 28),
                    if (cards.isNotEmpty) ...[
                      Text(
                        'Детали по карточкам',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      ...cards.map((card) {
                        final cardTotal = card.successCount + card.failCount;
                        final cardAccuracy = cardTotal > 0
                            ? (card.successCount / cardTotal * 100).round()
                            : 0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _CardDetailItem(
                            question: card.question,
                            accuracy: cardAccuracy,
                            success: card.successCount,
                            fails: card.failCount,
                            interval: card.interval,
                          ),
                        );
                      }),
                    ],
                    const SizedBox(height: 100),
                  ],
                ),
              );
            }

            return const Center(child: Text('Нет данных'));
          },
        ),
      ),
    );
  }

  int _calculateStreak(List cards) {
    if (cards.isEmpty) return 0;

    int maxStreak = 0;
    int currentStreak = 0;

    for (final card in cards) {
      if (card.successCount > card.failCount) {
        currentStreak++;
        if (currentStreak > maxStreak) {
          maxStreak = currentStreak;
        }
      } else {
        currentStreak = 0;
      }
    }

    return maxStreak;
  }
}

class _MainStatCard extends StatelessWidget {
  final int accuracy;
  final int totalPoints;
  final int level;

  const _MainStatCard({
    required this.accuracy,
    required this.totalPoints,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            'Точность',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '$accuracy%',
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _MiniStat(
                icon: Icons.star_rounded,
                value: '$totalPoints',
                label: 'Очки',
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              _MiniStat(
                icon: Icons.trending_up_rounded,
                value: '$level',
                label: 'Уровень',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _MiniStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.warning, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool fullWidth;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardDetailItem extends StatelessWidget {
  final String question;
  final int accuracy;
  final int success;
  final int fails;
  final int interval;

  const _CardDetailItem({
    required this.question,
    required this.accuracy,
    required this.success,
    required this.fails,
    required this.interval,
  });

  Color get _accuracyColor {
    if (accuracy >= 80) return AppColors.success;
    if (accuracy >= 50) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _accuracyColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '$accuracy%',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _accuracyColor,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.check_rounded,
                        size: 14, color: AppColors.success),
                    const SizedBox(width: 2),
                    Text(
                      '$success',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.success,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.close_rounded, size: 14, color: AppColors.error),
                    const SizedBox(width: 2),
                    Text(
                      '$fails',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.error,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${interval}д',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
