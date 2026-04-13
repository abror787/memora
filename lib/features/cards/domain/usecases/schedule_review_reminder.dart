import '../../../../core/services/notification_service.dart';
import '../../../settings/data/models/reminder_settings.dart';
import '../../../settings/domain/repositories/reminder_settings_repository.dart';
import '../repositories/card_repository.dart';

class ScheduleReviewReminder {
  final CardRepository cardRepository;
  final ReminderSettingsRepository settingsRepository;
  final NotificationService notificationService;

  ScheduleReviewReminder({
    required this.cardRepository,
    required this.settingsRepository,
    required this.notificationService,
  });

  Future<void> call(Duration interval) async {
    final cardsToReview = await cardRepository.getCardsForReview();
    final settings = ReminderSettings(
      isEnabled: true,
      reminderInterval: interval,
    );

    await settingsRepository.saveSettings(settings);
    await notificationService.scheduleReviewReminder(
      delay: interval,
      cardsToReviewCount: cardsToReview.length,
    );
  }

  Future<void> cancel() async {
    await notificationService.cancelReviewReminder();
    final currentSettings = await settingsRepository.getSettings();
    await settingsRepository.saveSettings(
      currentSettings.copyWith(isEnabled: false),
    );
  }
}
