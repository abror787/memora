About
Memora helps you memorize anything using scientifically proven spaced repetition. Create flashcards, review them daily, and the algorithm manages your schedule automatically — cards you know get pushed further out, cards you struggle with come back sooner.

This is v1.0 — a fully working first release. Core learning loop is complete. New features and improvements are planned (see Roadmap).


Features

Create flashcards with question & answer
Spaced repetition via Leitner algorithm
Review sessions with progress tracking
Learning statistics (accuracy, points, level, streaks)
Gamification — points system and levels
Local push notification reminders with custom intervals
Fully offline — no internet required
Clean Material 3 UI


Tech Stack
FrameworkFlutter / DartState Managementflutter_blocNavigationGoRouterLocal DatabaseIsarArchitectureClean ArchitectureNotificationsflutter_local_notifications

Architecture
The project follows Clean Architecture with three strict layers:
presentation  →  domain  ←  data
lib/
├── core/
│   ├── components/
│   ├── router/
│   └── theme/
└── features/
    └── cards/
        ├── data/
        │   ├── models/
        │   └── repositories/
        ├── domain/
        │   ├── entities/
        │   ├── repositories/
        │   └── usecases/
        └── presentation/
            ├── bloc/
            ├── pages/
            └── widgets/

Getting Started
Prerequisites

Flutter SDK >=3.0.0
Dart SDK >=3.0.0

Installation
bash# Clone the repo
git clone https://github.com/abror787/memora.git
cd memora

# Install dependencies
flutter pub get

# Generate Isar schemas
dart run build_runner build

# Run the app
flutter run

Spaced Repetition Algorithm
✅ Correct answer:  interval = min(interval × 2, 30 days)
❌ Wrong answer:    interval = 1 day (reset)
Cards start with a 1-day interval. Each correct answer doubles the interval up to a maximum of 30 days. Wrong answers reset the card back to day 1.
