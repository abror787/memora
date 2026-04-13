import '../../data/models/reminder_settings.dart';

abstract class ReminderSettingsRepository {
  Future<ReminderSettings> getSettings();
  Future<void> saveSettings(ReminderSettings settings);
  Future<void> clearSettings();
}
