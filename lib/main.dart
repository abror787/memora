import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'features/cards/data/models/card_model.dart';
import 'features/cards/data/repositories/card_repository_impl.dart';
import 'features/cards/domain/usecases/add_card.dart';
import 'features/cards/domain/usecases/get_all_cards.dart';
import 'features/cards/domain/usecases/get_cards_for_review.dart';
import 'features/cards/domain/usecases/update_card_interval.dart';
import 'features/cards/domain/usecases/delete_card.dart';
import 'features/cards/domain/usecases/update_card.dart';
import 'features/cards/domain/usecases/schedule_review_reminder.dart';
import 'features/cards/presentation/bloc/cards_bloc.dart';
import 'features/settings/data/repositories/reminder_settings_repository_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Isar? isar;
  try {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [CardModelSchema],
      directory: dir.path,
    );
  } catch (e) {
    debugPrint('Isar initialization error: $e');
  }

  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  runApp(MemoraApp(
    isar: isar,
    notificationService: notificationService,
  ));
}

class MemoraApp extends StatefulWidget {
  final Isar? isar;
  final NotificationService notificationService;

  const MemoraApp({
    super.key,
    this.isar,
    required this.notificationService,
  });

  @override
  State<MemoraApp> createState() => _MemoraAppState();
}

class _MemoraAppState extends State<MemoraApp> with WidgetsBindingObserver {
  late final ReminderSettingsRepositoryImpl _reminderSettingsRepository;
  StreamSubscription<NotificationAction>? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupNotificationListener();
  }

  void _setupNotificationListener() {
    _notificationSubscription =
        widget.notificationService.onNotificationAction.listen((action) {
      debugPrint('Notification action received: $action');

      switch (action) {
        case NotificationAction.reviewNow:
          _handleReviewNow();
          break;
        case NotificationAction.snooze15:
          _handleSnooze15();
          break;
        case NotificationAction.openApp:
          break;
      }
    });
  }

  void _handleReviewNow() {
    if (mounted) {
      widget.notificationService.cancelAllNotifications();
      _reminderSettingsRepository.clearSettings();
      GoRouter.of(context).push('/review');
    }
  }

  void _handleSnooze15() {
    widget.notificationService.scheduleReviewReminder(
      delay: const Duration(minutes: 15),
      cardsToReviewCount: 1,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notificationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isar == null) {
      return MaterialApp(
        title: 'Memora',
        home: Scaffold(
          body: Center(
            child: Text('Ошибка инициализации базы данных'),
          ),
        ),
      );
    }

    _reminderSettingsRepository = ReminderSettingsRepositoryImpl();

    final cardRepository = CardRepositoryImpl(widget.isar!);

    final getAllCards = GetAllCards(cardRepository);
    final getCardsForReview = GetCardsForReview(cardRepository);
    final addCard = AddCard(cardRepository);
    final updateCardInterval = UpdateCardInterval(cardRepository);
    final deleteCard = DeleteCard(cardRepository);
    final updateCard = UpdateCard(cardRepository);
    final scheduleReviewReminder = ScheduleReviewReminder(
      cardRepository: cardRepository,
      settingsRepository: _reminderSettingsRepository,
      notificationService: widget.notificationService,
    );

    return BlocProvider(
      create: (context) => CardsBloc(
        getAllCards: getAllCards,
        getCardsForReview: getCardsForReview,
        addCard: addCard,
        updateCardInterval: updateCardInterval,
        deleteCard: deleteCard,
        updateCard: updateCard,
        scheduleReviewReminder: scheduleReviewReminder,
        reminderSettingsRepository: _reminderSettingsRepository,
      ),
      child: MaterialApp.router(
        title: 'Memora',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
