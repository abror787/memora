import 'package:equatable/equatable.dart';

class ReminderSettings extends Equatable {
  final bool isEnabled;
  final Duration? reminderInterval;

  const ReminderSettings({
    this.isEnabled = false,
    this.reminderInterval,
  });

  ReminderSettings copyWith({
    bool? isEnabled,
    Duration? reminderInterval,
  }) {
    return ReminderSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      reminderInterval: reminderInterval ?? this.reminderInterval,
    );
  }

  @override
  List<Object?> get props => [isEnabled, reminderInterval];
}
