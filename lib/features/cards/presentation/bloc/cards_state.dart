import 'package:equatable/equatable.dart';
import '../../domain/entities/card_entity.dart';
import '../../../settings/data/models/reminder_settings.dart';

abstract class CardsState extends Equatable {
  final ReminderSettings? reminderSettings;

  const CardsState({this.reminderSettings});

  @override
  List<Object?> get props => [reminderSettings];
}

class CardsInitial extends CardsState {
  const CardsInitial({super.reminderSettings});
}

class CardsLoading extends CardsState {
  const CardsLoading({super.reminderSettings});
}

class CardsLoaded extends CardsState {
  final List<CardEntity> cards;

  const CardsLoaded(this.cards, {super.reminderSettings});

  CardsLoaded copyWith({
    List<CardEntity>? cards,
    ReminderSettings? reminderSettings,
  }) {
    return CardsLoaded(
      cards ?? this.cards,
      reminderSettings: reminderSettings ?? this.reminderSettings,
    );
  }

  @override
  List<Object?> get props => [cards, reminderSettings];
}

class ReviewCardsLoaded extends CardsState {
  final List<CardEntity> reviewCards;

  const ReviewCardsLoaded(this.reviewCards, {super.reminderSettings});

  @override
  List<Object?> get props => [reviewCards, reminderSettings];
}

class CardsError extends CardsState {
  final String message;

  const CardsError(this.message, {super.reminderSettings});

  @override
  List<Object?> get props => [message, reminderSettings];
}

class ReminderScheduled extends CardsState {
  final Duration interval;

  const ReminderScheduled(this.interval, {super.reminderSettings});

  @override
  List<Object?> get props => [interval, reminderSettings];
}

class ReminderCancelled extends CardsState {
  const ReminderCancelled({super.reminderSettings});
}
