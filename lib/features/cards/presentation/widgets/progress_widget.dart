import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ProgressWidget extends StatelessWidget {
  final int totalPoints;
  final int level;
  final int cardsStudied;
  final int totalCards;

  const ProgressWidget({
    super.key,
    required this.totalPoints,
    required this.level,
    required this.cardsStudied,
    required this.totalCards,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalCards > 0 ? cardsStudied / totalCards : 0.0;
    final pointsToNextLevel = (level + 1) * 100 - totalPoints;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.star_rounded,
                value: '$totalPoints',
                label: 'Очки',
                color: AppColors.warning,
              ),
              _buildStatItem(
                icon: Icons.trending_up_rounded,
                value: '$level',
                label: 'Уровень',
                color: AppColors.primary,
              ),
              _buildStatItem(
                icon: Icons.style_rounded,
                value: '$cardsStudied',
                label: 'Изучено',
                color: AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Прогресс изучения',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '$cardsStudied / $totalCards',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: constraints.maxWidth * progress,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          if (pointsToNextLevel > 0 && pointsToNextLevel <= 100) ...[
            const SizedBox(height: 12),
            Text(
              'До следующего уровня: $pointsToNextLevel очков',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
