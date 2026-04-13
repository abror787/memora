import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/components/components.dart';
import '../../domain/entities/card_entity.dart';
import '../bloc/cards_bloc.dart';
import '../bloc/cards_event.dart';
import '../bloc/cards_state.dart';
import '../widgets/card_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<CardsBloc>().add(LoadAllCards());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<CardsBloc, CardsState>(
          buildWhen: (previous, current) {
            if (previous is CardsLoading && current is CardsLoading) {
              return false;
            }
            if (previous is CardsError && current is CardsError) {
              return false;
            }
            return true;
          },
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
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              );
            }

            List<CardEntity> cards = [];
            if (state is CardsLoaded) {
              cards = state.cards;
            } else if (state is ReviewCardsLoaded) {
              cards = state.reviewCards;
            }

            final totalSuccess =
                cards.fold<int>(0, (sum, c) => sum + c.successCount);
            final totalPoints = totalSuccess * 10;

            final now = DateTime.now();
            final cardsToReview = cards
                .where((c) =>
                    c.nextReviewDate.isBefore(now) ||
                    c.nextReviewDate.isAtSameMomentAs(now))
                .length;

            final studiedCount = cards.where((c) => c.successCount > 0).length;

            List<CardEntity> filteredCards;
            switch (_selectedTab) {
              case 1:
                filteredCards = cards.where((c) => c.successCount > 0).toList();
                break;
              case 2:
                filteredCards = cards
                    .where((c) =>
                        c.nextReviewDate.isBefore(now) ||
                        c.nextReviewDate.isAtSameMomentAs(now))
                    .toList();
                break;
              default:
                filteredCards = cards;
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context, totalPoints),
                        const SizedBox(height: 24),
                        _buildStatsRow(
                            context, cards.length, studiedCount, cardsToReview),
                        const SizedBox(height: 24),
                        if (_selectedTab == 2 && cardsToReview > 0) ...[
                          _ClickableReviewBanner(
                            cardsToReview: cardsToReview,
                            onTap: () => context.push('/review'),
                          ),
                          const SizedBox(height: 24),
                        ],
                        const ReviewReminderSection(),
                        const SizedBox(height: 24),
                        Text(
                          _selectedTab == 0
                              ? 'Все карточки'
                              : _selectedTab == 1
                                  ? 'Изученные'
                                  : 'К повторению',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                if (filteredCards.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyFilteredState(context),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final card = filteredCards[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: CardWidget(
                              key: ValueKey(card.id ?? card.question.hashCode),
                              card: card,
                              onTap: () => _showCardPreview(context, card),
                            ),
                          );
                        },
                        childCount: filteredCards.length,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCardModal(context),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int totalPoints) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Memora',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Учись эффективно',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded,
                  color: AppColors.warning, size: 20),
              const SizedBox(width: 4),
              Text(
                '$totalPoints',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(
      BuildContext context, int total, int studied, int toReview) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedTab = 0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _selectedTab == 0
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      _selectedTab == 0 ? AppColors.primary : AppColors.border,
                  width: _selectedTab == 0 ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.style_outlined,
                      color: _selectedTab == 0
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      size: 24),
                  const SizedBox(height: 8),
                  Text(
                    '$total',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _selectedTab == 0
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text('Всего', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedTab = 1),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _selectedTab == 1
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      _selectedTab == 1 ? AppColors.success : AppColors.border,
                  width: _selectedTab == 1 ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.check_circle_outline,
                      color: _selectedTab == 1
                          ? AppColors.success
                          : AppColors.textSecondary,
                      size: 24),
                  const SizedBox(height: 8),
                  Text(
                    '$studied',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _selectedTab == 1
                              ? AppColors.success
                              : AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text('Изучено', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedTab = 2),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _selectedTab == 2
                    ? AppColors.secondary.withValues(alpha: 0.1)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _selectedTab == 2
                      ? AppColors.secondary
                      : AppColors.border,
                  width: _selectedTab == 2 ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.refresh_rounded,
                      color: _selectedTab == 2
                          ? AppColors.secondary
                          : AppColors.textSecondary,
                      size: 24),
                  const SizedBox(height: 8),
                  Text(
                    '$toReview',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _selectedTab == 2
                              ? AppColors.secondary
                              : AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text('К повторению',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyFilteredState(BuildContext context) {
    String message;
    IconData icon;
    switch (_selectedTab) {
      case 1:
        message = 'Пока нет изученных карточек.\nНачните повторять карточки!';
        icon = Icons.school_outlined;
        break;
      case 2:
        message = 'Нет карточек для повторения.\nПриходите позже!';
        icon = Icons.check_circle_outline;
        break;
      default:
        return _buildEmptyState(context);
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Начни обучение',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Создай свою первую карточку,\nчтобы начать учиться',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showAddCardModal(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Создать карточку'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCardPreview(BuildContext context, CardEntity card) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _CardPreviewSheet(card: card),
    );
  }

  void _showAddCardModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddCardModal(),
    );
  }
}

class _ClickableReviewBanner extends StatefulWidget {
  final int cardsToReview;
  final VoidCallback onTap;

  const _ClickableReviewBanner({
    required this.cardsToReview,
    required this.onTap,
  });

  @override
  State<_ClickableReviewBanner> createState() => _ClickableReviewBannerState();
}

class _ClickableReviewBannerState extends State<_ClickableReviewBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(20),
            splashColor: Colors.white.withValues(alpha: 0.2),
            highlightColor: Colors.white.withValues(alpha: 0.1),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Готов к повторению',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.cardsToReview} ${_pluralize(widget.cardsToReview, 'карточка', 'карточки', 'карточек')} ждут тебя',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _pluralize(int count, String one, String few, String many) {
    if (count % 10 == 1 && count % 100 != 11) return one;
    if (count % 10 >= 2 &&
        count % 10 <= 4 &&
        (count % 100 < 10 || count % 100 >= 20)) return few;
    return many;
  }
}

class _CardPreviewSheet extends StatelessWidget {
  final CardEntity card;

  const _CardPreviewSheet({required this.card});

  bool get _isDue =>
      card.nextReviewDate.isBefore(DateTime.now()) ||
      card.nextReviewDate.isAtSameMomentAs(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (_isDue ? AppColors.success : AppColors.primary)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isDue ? Icons.refresh_rounded : Icons.schedule_rounded,
                      size: 14,
                      color: _isDue ? AppColors.success : AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isDue ? 'К повторению' : 'Через ${card.interval} дн.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _isDue ? AppColors.success : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Icon(Icons.thumb_up_rounded,
                  size: 16, color: AppColors.success),
              const SizedBox(width: 4),
              Text(
                '${card.successCount}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.thumb_down_rounded,
                  size: 16, color: AppColors.error),
              const SizedBox(width: 4),
              Text(
                '${card.failCount}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Вопрос',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(card.question, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 20),
          Text(
            'Ответ',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            card.answer,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.push('/review');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Начать повторение'),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}

class AddCardModal extends StatefulWidget {
  const AddCardModal({super.key});

  @override
  State<AddCardModal> createState() => _AddCardModalState();
}

class _AddCardModalState extends State<AddCardModal> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _saveCard() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      context.read<CardsBloc>().add(
            AddCardEvent(
              question: _questionController.text.trim(),
              answer: _answerController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CardsBloc, CardsState>(
      listener: (context, state) {
        if (state is CardsLoaded) {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Новая карточка',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _questionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Вопрос',
                  hintText: 'Введите вопрос...',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите вопрос';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _answerController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Ответ',
                  hintText: 'Введите ответ...',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите ответ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveCard,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
