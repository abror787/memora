# Memora 🧠
Flashcard learning app built with Flutter. Uses spaced repetition (Leitner system) to help you memorize anything effectively.

> **v1.0** — First release. Core learning loop is complete. More features coming in future versions.

## Features
- Create flashcards with question & answer
- Spaced repetition algorithm — interval doubles on correct answer, resets on wrong
- Review sessions with live progress tracking
- Statistics page — accuracy, points, level, max streak
- Gamification — earn points, level up
- Push notification reminders with custom intervals
- Fully offline — no internet required

## Tech Stack
- **Flutter** - UI Framework
- **BLoC** - State Management
- **Isar** - Local Database
- **GoRouter** - Navigation
- **flutter_local_notifications** - Push Reminders

## Architecture
Clean Architecture with strict layer separation:
```
lib/
├── core/
│   ├── components/       # Reusable widgets
│   ├── router/           # GoRouter config
│   └── theme/            # Material 3 theme
└── features/
    └── cards/
        ├── data/          # Isar models, repository impl
        ├── domain/        # Entities, use cases, interfaces
        └── presentation/  # BLoC, pages, widgets
```

## Spaced Repetition Algorithm
```
✅ Correct:  interval = min(interval × 2, 30 days)
❌ Wrong:    interval = 1 day (reset)
```
Cards start at 1-day interval. Each correct answer doubles it up to 30 days max.

## Getting Started
1. Clone the repository
2. Install dependencies: `flutter pub get`
3. Generate Isar schemas: `dart run build_runner build`
4. Run the app: `flutter run`

## Screenshots
![Image](https://github.com/abror787/memora/blob/04b902da785e936ab75739f762bb1f249945608a/1main_screen.jpg)

![Image](https://github.com/abror787/memora/blob/04b902da785e936ab75739f762bb1f249945608a/timer_screen2.jpg)

![Image](https://github.com/abror787/memora/blob/04b902da785e936ab75739f762bb1f249945608a/notification3.jpg)

![Image](https://github.com/abror787/memora/blob/04b902da785e936ab75739f762bb1f249945608a/statistics_screen4.jpg)

![Image](https://github.com/abror787/memora/blob/04b902da785e936ab75739f762bb1f249945608a/new_card_screen5.jpg)

![Image](https://github.com/abror787/memora/blob/04b902da785e936ab75739f762bb1f249945608a/repeat_screen6.jpg)

![Image](https://github.com/abror787/memora/blob/04b902da785e936ab75739f762bb1f249945608a/check_memory_screen7.jpg)

![Image](https://github.com/abror787/memora/blob/04b902da785e936ab75739f762bb1f249945608a/check_right_or_wrong_screen8.jpg)

![Image](https://github.com/abror787/memora/blob/04b902da785e936ab75739f762bb1f249945608a/result_screen9.jpg)

## Roadmap
- [ ] Dark mode
- [ ] Card decks / categories
- [ ] Import from CSV
- [ ] Cloud sync (Firebase / Supabase)
- [ ] AI-generated flashcards

---
Built with using Flutter
