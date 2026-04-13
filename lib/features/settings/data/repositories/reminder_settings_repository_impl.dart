import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/reminder_settings_repository.dart';
import '../models/reminder_settings.dart';

class ReminderSettingsRepositoryImpl implements ReminderSettingsRepository {
  static const String _keyEnabled = 'reminder_enabled';
  static const String _keyIntervalMinutes = 'reminder_interval_minutes';

  @override
  Future<ReminderSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool(_keyEnabled) ?? false;
    final intervalMinutes = prefs.getInt(_keyIntervalMinutes);

    return ReminderSettings(
      isEnabled: isEnabled,
      reminderInterval:
          intervalMinutes != null ? Duration(minutes: intervalMinutes) : null,
    );
  }

  @override
  Future<void> saveSettings(ReminderSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnabled, settings.isEnabled);
    if (settings.reminderInterval != null) {
      await prefs.setInt(
        _keyIntervalMinutes,
        settings.reminderInterval!.inMinutes,
      );
    } else {
      await prefs.remove(_keyIntervalMinutes);
    }
  }

  @override
  Future<void> clearSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyEnabled);
    await prefs.remove(_keyIntervalMinutes);
  }
}
