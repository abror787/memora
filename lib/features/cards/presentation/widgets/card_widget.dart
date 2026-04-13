import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/card_entity.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/cards_bloc.dart';
import '../bloc/cards_event.dart';

class CardWidget extends StatefulWidget {
  final CardEntity card;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CardWidget({
    super.key,
    required this.card,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  bool get _isDue =>
      widget.card.nextReviewDate.isBefore(DateTime.now()) ||
      widget.card.nextReviewDate.isAtSameMomentAs(DateTime.now());

  Color get _statusColor => _isDue ? AppColors.success : AppColors.primary;

  void _showCardOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _CardOptionsSheet(
        card: widget.card,
        onEdit: () {
          Navigator.pop(context);
          _showEditDialog(context);
        },
        onDelete: () {
          Navigator.pop(context);
          _showDeleteConfirmation(context);
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final questionController =
        TextEditingController(text: widget.card.question);
    final answerController = TextEditingController(text: widget.card.answer);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактировать карточку'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: questionController,
                decoration: const InputDecoration(labelText: 'Вопрос'),
                validator: (v) =>
                    v?.trim().isEmpty == true ? 'Введите вопрос' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: answerController,
                decoration: const InputDecoration(labelText: 'Ответ'),
                validator: (v) =>
                    v?.trim().isEmpty == true ? 'Введите ответ' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                context.read<CardsBloc>().add(UpdateCardEvent(
                      card: widget.card,
                      newQuestion: questionController.text.trim(),
                      newAnswer: answerController.text.trim(),
                    ));
                Navigator.pop(context);
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить карточку?'),
        content: const Text('Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CardsBloc>().add(DeleteCardEvent(card: widget.card));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: widget.onTap,
        onLongPress: () => _showCardOptions(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isDue
                              ? Icons.refresh_rounded
                              : Icons.schedule_rounded,
                          size: 14,
                          color: _statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isDue
                              ? 'К повторению'
                              : '${widget.card.interval} дн.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  _StatBadge(
                    icon: Icons.thumb_up_rounded,
                    count: widget.card.successCount,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 10),
                  _StatBadge(
                    icon: Icons.thumb_down_rounded,
                    count: widget.card.failCount,
                    color: AppColors.error,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                widget.card.question,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                widget.card.answer,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardOptionsSheet extends StatelessWidget {
  final CardEntity card;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CardOptionsSheet({
    required this.card,
    required this.onEdit,
    required this.onDelete,
  });

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
        children: [
          Container(
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            card.question,
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.edit_rounded),
            title: const Text('Редактировать'),
            onTap: onEdit,
          ),
          ListTile(
            leading: const Icon(Icons.delete_rounded, color: AppColors.error),
            title:
                const Text('Удалить', style: TextStyle(color: AppColors.error)),
            onTap: onDelete,
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;

  const _StatBadge({
    required this.icon,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
