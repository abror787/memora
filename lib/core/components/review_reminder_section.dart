import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/notification_service.dart';
import '../../features/cards/presentation/bloc/cards_bloc.dart';
import '../../features/cards/presentation/bloc/cards_event.dart';
import '../../features/cards/presentation/bloc/cards_state.dart';

class ReviewReminderSection extends StatefulWidget {
  const ReviewReminderSection({super.key});

  @override
  State<ReviewReminderSection> createState() => _ReviewReminderSectionState();
}

class _ReviewReminderSectionState extends State<ReviewReminderSection> {
  final _hoursController = TextEditingController(text: '0');
  final _minutesController = TextEditingController(text: '0');
  final _secondsController = TextEditingController(text: '5');
  Duration? _selectedInterval;

  static const List<_IntervalChip> _presetIntervals = [
    _IntervalChip(label: '15 мин', duration: Duration(minutes: 15)),
    _IntervalChip(label: '30 мин', duration: Duration(minutes: 30)),
    _IntervalChip(label: '1 час', duration: Duration(hours: 1)),
    _IntervalChip(label: '3 часа', duration: Duration(hours: 3)),
    _IntervalChip(label: '5 часов', duration: Duration(hours: 5)),
    _IntervalChip(label: '8 часов', duration: Duration(hours: 8)),
  ];

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  Duration _getManualDuration() {
    final hours = int.tryParse(_hoursController.text) ?? 0;
    final minutes = int.tryParse(_minutesController.text) ?? 0;
    final seconds = int.tryParse(_secondsController.text) ?? 0;
    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }

  void _onChipSelected(Duration duration) {
    setState(() {
      _selectedInterval = duration;
      _hoursController.text = duration.inHours.toString();
      _minutesController.text = (duration.inMinutes % 60).toString();
      _secondsController.text = (duration.inSeconds % 60).toString();
    });
  }

  void _scheduleReminder() {
    final interval = _selectedInterval ?? _getManualDuration();
    if (interval.inSeconds > 0) {
      context.read<CardsBloc>().add(ScheduleReminderEvent(interval: interval));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Напоминание установлено на ${_formatDuration(interval)}',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _testNotification() async {
    final notificationService = NotificationService();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Тестовое уведомление через 3 сек...'),
        backgroundColor: AppColors.warning,
        duration: Duration(seconds: 2),
      ),
    );

    await notificationService.showImmediateNotification(
      title: 'Memora — тест!',
      body: 'У тебя 5 карточек ждут повторения',
      payload: 'test',
    );
  }

  void _cancelReminder() {
    context.read<CardsBloc>().add(CancelReminderEvent());
    setState(() {
      _selectedInterval = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Напоминание отменено'),
        backgroundColor: AppColors.textSecondary,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours} ч. ${duration.inMinutes % 60} мин.';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} мин.';
    }
    return '${duration.inSeconds} сек.';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CardsBloc, CardsState>(
      builder: (context, state) {
        final reminderEnabled = state.reminderSettings?.isEnabled ?? false;
        final currentInterval = state.reminderSettings?.reminderInterval;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Напоминания о повторении',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        if (reminderEnabled && currentInterval != null)
                          Text(
                            'Через ${_formatDuration(currentInterval)}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.primary,
                                    ),
                          ),
                      ],
                    ),
                  ),
                  Switch(
                    value: reminderEnabled,
                    onChanged: (value) {
                      if (value) {
                        _scheduleReminder();
                      } else {
                        _cancelReminder();
                      }
                    },
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
              if (reminderEnabled) ...[
                const SizedBox(height: 20),
                Text(
                  'Выберите интервал',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _presetIntervals.map((chip) {
                    final isSelected = _selectedInterval == chip.duration ||
                        (currentInterval == chip.duration &&
                            _selectedInterval == null);
                    return _IntervalChipButton(
                      chip: chip,
                      isSelected: isSelected,
                      onTap: () => _onChipSelected(chip.duration),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Text(
                  'Или введите вручную',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _TimeInputField(
                        controller: _hoursController,
                        label: 'Часы',
                        maxValue: 23,
                        onChanged: () =>
                            setState(() => _selectedInterval = null),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        ':',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _TimeInputField(
                        controller: _minutesController,
                        label: 'Минуты',
                        maxValue: 59,
                        onChanged: () =>
                            setState(() => _selectedInterval = null),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        ':',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _TimeInputField(
                        controller: _secondsController,
                        label: 'Секунды',
                        maxValue: 59,
                        onChanged: () =>
                            setState(() => _selectedInterval = null),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _scheduleReminder,
                    icon: const Icon(Icons.timer_rounded, size: 20),
                    label: const Text('Запустить таймер'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _testNotification,
                    icon: const Icon(Icons.notification_add_rounded, size: 20),
                    label: const Text('Тест уведомления'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.warning,
                      side: const BorderSide(color: AppColors.warning),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _IntervalChip {
  final String label;
  final Duration duration;

  const _IntervalChip({required this.label, required this.duration});
}

class _IntervalChipButton extends StatelessWidget {
  final _IntervalChip chip;
  final bool isSelected;
  final VoidCallback onTap;

  const _IntervalChipButton({
    required this.chip,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            chip.label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxValue;
  final VoidCallback onChanged;

  const _TimeInputField({
    required this.controller,
    required this.label,
    required this.maxValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: controller,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(2),
          ],
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}
