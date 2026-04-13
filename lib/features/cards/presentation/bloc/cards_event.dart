import 'package:equatable/equatable.dart';
import '../../domain/entities/card_entity.dart';

abstract class CardsEvent extends Equatable {
  const CardsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllCards extends CardsEvent {}

class LoadReviewCards extends CardsEvent {
  final bool forceAll;

  const LoadReviewCards({this.forceAll = false});

  @override
  List<Object?> get props => [forceAll];
}

class AddCardEvent extends CardsEvent {
  final String question;
  final String answer;

  const AddCardEvent({required this.question, required this.answer});

  @override
  List<Object?> get props => [question, answer];
}

class CardAnsweredEvent extends CardsEvent {
  final CardEntity card;
  final bool isSuccess;

  const CardAnsweredEvent({required this.card, required this.isSuccess});

  @override
  List<Object?> get props => [card, isSuccess];
}

class ScheduleReminderEvent extends CardsEvent {
  final Duration interval;

  const ScheduleReminderEvent({required this.interval});

  @override
  List<Object?> get props => [interval];
}

class CancelReminderEvent extends CardsEvent {}

class LoadReminderSettingsEvent extends CardsEvent {}

class DeleteCardEvent extends CardsEvent {
  final CardEntity card;

  const DeleteCardEvent({required this.card});

  @override
  List<Object?> get props => [card];
}

class UpdateCardEvent extends CardsEvent {
  final CardEntity card;
  final String newQuestion;
  final String newAnswer;

  const UpdateCardEvent({
    required this.card,
    required this.newQuestion,
    required this.newAnswer,
  });

  @override
  List<Object?> get props => [card, newQuestion, newAnswer];
}
