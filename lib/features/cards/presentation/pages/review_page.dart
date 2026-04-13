import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/components/components.dart';
import '../../domain/entities/card_entity.dart';
import '../bloc/cards_bloc.dart';
import '../bloc/cards_event.dart';
import '../bloc/cards_state.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  bool _showAnswer = false;
  int _currentIndex = 0;
  int _correctCount = 0;
  int _incorrectCount = 0;
  List<CardEntity> _sessionCards = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCards();
    });
  }

  void _loadCards() {
    final state = context.read<CardsBloc>().state;
    if (state is ReviewCardsLoaded && state.reviewCards.isNotEmpty) {
      _sessionCards = List<CardEntity>.from(state.reviewCards);
    } else {
      context.read<CardsBloc>().add(LoadReviewCards());
    }
  }

  void _onAnswer(bool isCorrect) {
    if (_sessionCards.isEmpty) return;

    final state = context.read<CardsBloc>().state;
    if (state is ReviewCardsLoaded && state.reviewCards.isNotEmpty) {
      final currentCard = _sessionCards[_currentIndex];

      context.read<CardsBloc>().add(
            CardAnsweredEvent(card: currentCard, isSuccess: isCorrect),
          );

      if (isCorrect) {
        _correctCount++;
      } else {
        _incorrectCount++;
      }

      if (_currentIndex < _sessionCards.length - 1) {
        setState(() {
          _showAnswer = false;
          _currentIndex++;
        });
      } else {
        setState(() {
          _currentIndex++;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Повторение'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            context.read<CardsBloc>().add(LoadAllCards());
            context.pop();
          },
        ),
      ),
      body: BlocListener<CardsBloc, CardsState>(
        listenWhen: (previous, current) {
          // Обновляем sessionCards когда загрузились новые карточки для review
          if (current is ReviewCardsLoaded) {
            if (previous is! ReviewCardsLoaded ||
                (previous as ReviewCardsLoaded).reviewCards.length !=
                    current.reviewCards.length) {
              return true;
            }
          }
          return false;
        },
        listener: (context, state) {
          if (state is ReviewCardsLoaded && state.reviewCards.isNotEmpty) {
            setState(() {
              _sessionCards = List<CardEntity>.from(state.reviewCards);
            });
          }
        },
        child: BlocBuilder<CardsBloc, CardsState>(
          builder: (context, state) {
            if (state is CardsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CardsError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 64,
                        color: AppColors.error.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        text: 'Повторить',
                        onPressed: () {
                          context.read<CardsBloc>().add(LoadReviewCards());
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is ReviewCardsLoaded) {
              final cards = state.reviewCards;

              if (_sessionCards.isEmpty && cards.isNotEmpty) {
                _sessionCards = List<CardEntity>.from(cards);
              }

              if (cards.isEmpty) {
                return _buildEmptyState(context);
              }

              if (_currentIndex >= _sessionCards.length) {
                return _buildCompletedState(context);
              }

              final currentCard = _sessionCards[_currentIndex];
              final progress = (_currentIndex) / _sessionCards.length;

              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildProgressBar(
                          progress, _currentIndex, _sessionCards.length),
                      const SizedBox(height: 20),
                      _buildScoreIndicator(),
                      const SizedBox(height: 24),
                      Expanded(
                        child: _buildFlashcard(
                            currentCard.question, currentCard.answer),
                      ),
                      const SizedBox(height: 24),
                      _buildActionButtons(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            }

            return const Center(child: Text('Загрузка...'));
          },
        ),
      ),
    );
  }

  Widget _buildProgressBar(double progress, int current, int total) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$current / $total',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ScoreChip(
          icon: Icons.check_rounded,
          count: _correctCount,
          color: AppColors.success,
        ),
        const SizedBox(width: 16),
        _ScoreChip(
          icon: Icons.close_rounded,
          count: _incorrectCount,
          color: AppColors.error,
        ),
      ],
    );
  }

  Widget _buildFlashcard(String question, String answer) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          if (_showAnswer) ...[
            const Divider(height: 1),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.05),
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
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
                      answer,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppColors.success,
                              ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Expanded(
              child: Center(
                child: Text(
                  'Нажмите кнопку ниже,\nчтобы увидеть ответ',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (!_showAnswer) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            setState(() => _showAnswer = true);
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Показать ответ'),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 56,
            child: OutlinedButton(
              onPressed: () => _onAnswer(false),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.close_rounded, size: 22),
                  const SizedBox(width: 8),
                  const Text('Не знаю'),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: () => _onAnswer(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_rounded, size: 22),
                  const SizedBox(width: 8),
                  const Text('Знаю'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.celebration_rounded,
                  size: 64,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Отличная работа!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Нет карточек для повторения.\nПриходите позже!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('На главную'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedState(BuildContext context) {
    final total = _correctCount + _incorrectCount;
    final percentage = total > 0 ? (_correctCount / total * 100).round() : 0;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: percentage >= 70
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.warning.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                percentage >= 70
                    ? Icons.emoji_events_rounded
                    : Icons.thumb_up_rounded,
                size: 80,
                color: percentage >= 70 ? AppColors.success : AppColors.warning,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              percentage >= 70 ? 'Отлично!' : 'Хорошая работа!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Сессия завершена',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w700,
                      color: percentage >= 70
                          ? AppColors.success
                          : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ResultColumn(
                        icon: Icons.check_circle_rounded,
                        count: _correctCount,
                        label: 'Правильно',
                        color: AppColors.success,
                      ),
                      Container(
                        width: 1,
                        height: 50,
                        color: AppColors.border,
                      ),
                      _ResultColumn(
                        icon: Icons.cancel_rounded,
                        count: _incorrectCount,
                        label: 'Ошибки',
                        color: AppColors.error,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showAnswer = false;
                    _currentIndex = 0;
                    _correctCount = 0;
                    _incorrectCount = 0;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh_rounded, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      'Повторить эти же карточки ещё раз',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () {
                  // Загружаем полный список перед возвратом
                  context.read<CardsBloc>().add(LoadAllCards());
                  context.pop();
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.home_rounded, color: AppColors.textSecondary),
                    SizedBox(width: 12),
                    Text(
                      'Вернуться на главную',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;

  const _ScoreChip({
    required this.icon,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: color,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultColumn extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  final Color color;

  const _ResultColumn({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
