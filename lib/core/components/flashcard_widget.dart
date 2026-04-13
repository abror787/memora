import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class FlashcardWidget extends StatelessWidget {
  final String question;
  final String? answer;
  final bool showAnswer;
  final VoidCallback? onShowAnswer;

  const FlashcardWidget({
    super.key,
    required this.question,
    this.answer,
    this.showAnswer = false,
    this.onShowAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'ВОПРОС',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            question,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          if (showAnswer && answer != null) ...[
            const SizedBox(height: 32),
            const Divider(color: AppColors.border),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'ОТВЕТ',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              answer!,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.success,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          if (!showAnswer && onShowAnswer != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onShowAnswer,
                child: const Text('Показать ответ'),
              ),
            ),
        ],
      ),
    );
  }
}
