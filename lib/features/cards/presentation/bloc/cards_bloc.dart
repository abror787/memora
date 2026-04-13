import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/card_entity.dart';
import '../../domain/usecases/add_card.dart';
import '../../domain/usecases/get_all_cards.dart';
import '../../domain/usecases/get_cards_for_review.dart';
import '../../domain/usecases/update_card_interval.dart';
import '../../domain/usecases/delete_card.dart';
import '../../domain/usecases/update_card.dart';
import '../../domain/usecases/schedule_review_reminder.dart';
import '../../../settings/domain/repositories/reminder_settings_repository.dart';
import 'cards_event.dart';
import 'cards_state.dart';

class CardsBloc extends Bloc<CardsEvent, CardsState> {
  final GetAllCards getAllCards;
  final GetCardsForReview getCardsForReview;
  final AddCard addCard;
  final UpdateCardInterval updateCardInterval;
  final DeleteCard deleteCard;
  final UpdateCard updateCard;
  final ScheduleReviewReminder scheduleReviewReminder;
  final ReminderSettingsRepository reminderSettingsRepository;

  CardsBloc({
    required this.getAllCards,
    required this.getCardsForReview,
    required this.addCard,
    required this.updateCardInterval,
    required this.deleteCard,
    required this.updateCard,
    required this.scheduleReviewReminder,
    required this.reminderSettingsRepository,
  }) : super(const CardsInitial()) {
    on<LoadAllCards>(_onLoadAllCards);
    on<LoadReviewCards>(_onLoadReviewCards);
    on<AddCardEvent>(_onAddCard);
    on<CardAnsweredEvent>(_onCardAnswered);
    on<ScheduleReminderEvent>(_onScheduleReminder);
    on<CancelReminderEvent>(_onCancelReminder);
    on<LoadReminderSettingsEvent>(_onLoadReminderSettings);
    on<DeleteCardEvent>(_onDeleteCard);
    on<UpdateCardEvent>(_onUpdateCard);

    add(LoadReminderSettingsEvent());
    add(LoadAllCards());
  }

  Future<void> _onLoadAllCards(
      LoadAllCards event, Emitter<CardsState> emit) async {
    try {
      final cards = await getAllCards();
      final settings = await reminderSettingsRepository.getSettings();
      emit(CardsLoaded(cards, reminderSettings: settings));
    } catch (e) {
      emit(CardsError(e.toString(), reminderSettings: state.reminderSettings));
    }
  }

  Future<void> _onLoadReviewCards(
      LoadReviewCards event, Emitter<CardsState> emit) async {
    try {
      final cards = await getCardsForReview(forceAll: event.forceAll);
      final settings = await reminderSettingsRepository.getSettings();
      emit(ReviewCardsLoaded(cards, reminderSettings: settings));
    } catch (e) {
      emit(CardsError(e.toString(), reminderSettings: state.reminderSettings));
    }
  }

  Future<void> _onAddCard(AddCardEvent event, Emitter<CardsState> emit) async {
    try {
      await addCard(event.question, event.answer);
      final cards = await getAllCards();
      final settings = await reminderSettingsRepository.getSettings();
      emit(CardsLoaded(cards, reminderSettings: settings));
    } catch (e) {
      emit(CardsError(e.toString(), reminderSettings: state.reminderSettings));
    }
  }

  Future<void> _onCardAnswered(
      CardAnsweredEvent event, Emitter<CardsState> emit) async {
    try {
      await updateCardInterval(event.card, event.isSuccess);

      if (state is ReviewCardsLoaded) {
        final currentCards =
            List<CardEntity>.from((state as ReviewCardsLoaded).reviewCards);

        if (!event.isSuccess) {
          final failedCard = event.card.copyWith(
            interval: 1,
            nextReviewDate: DateTime.now().add(const Duration(days: 1)),
            failCount: event.card.failCount + 1,
          );
          currentCards.add(failedCard);
        }

        emit(ReviewCardsLoaded(
          currentCards,
          reminderSettings: state.reminderSettings,
        ));
      }
    } catch (e) {
      emit(CardsError(e.toString(), reminderSettings: state.reminderSettings));
    }
  }

  Future<void> _onScheduleReminder(
      ScheduleReminderEvent event, Emitter<CardsState> emit) async {
    try {
      await scheduleReviewReminder(event.interval);
      final cards = await getAllCards();
      final settings = await reminderSettingsRepository.getSettings();
      emit(CardsLoaded(
        cards,
        reminderSettings: settings,
      ));
    } catch (e) {
      emit(CardsError(e.toString(), reminderSettings: state.reminderSettings));
    }
  }

  Future<void> _onCancelReminder(
      CancelReminderEvent event, Emitter<CardsState> emit) async {
    try {
      await scheduleReviewReminder.cancel();
      final cards = await getAllCards();
      final settings = await reminderSettingsRepository.getSettings();
      emit(CardsLoaded(
        cards,
        reminderSettings: settings,
      ));
    } catch (e) {
      emit(CardsError(e.toString(), reminderSettings: state.reminderSettings));
    }
  }

  Future<void> _onLoadReminderSettings(
      LoadReminderSettingsEvent event, Emitter<CardsState> emit) async {
    try {
      final settings = await reminderSettingsRepository.getSettings();
      if (state is CardsLoaded) {
        emit((state as CardsLoaded).copyWith(reminderSettings: settings));
      } else if (state is CardsInitial) {
        emit(CardsLoaded(const [], reminderSettings: settings));
      }
    } catch (e) {
      debugPrint('Error loading reminder settings: $e');
    }
  }

  Future<void> _onDeleteCard(
      DeleteCardEvent event, Emitter<CardsState> emit) async {
    try {
      if (event.card.id != null) {
        await deleteCard(event.card.id!);
      }
      final cards = await getAllCards();
      final settings = await reminderSettingsRepository.getSettings();
      emit(CardsLoaded(cards, reminderSettings: settings));
    } catch (e) {
      emit(CardsError(e.toString(), reminderSettings: state.reminderSettings));
    }
  }

  Future<void> _onUpdateCard(
      UpdateCardEvent event, Emitter<CardsState> emit) async {
    try {
      final updatedCard = event.card.copyWith(
        question: event.newQuestion,
        answer: event.newAnswer,
      );
      await updateCard(updatedCard);
      final cards = await getAllCards();
      final settings = await reminderSettingsRepository.getSettings();
      emit(CardsLoaded(cards, reminderSettings: settings));
    } catch (e) {
      emit(CardsError(e.toString(), reminderSettings: state.reminderSettings));
    }
  }
}
