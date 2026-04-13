# 📱 Memora V1 — Документация проекта

## Содержание

1. [Общее описание](#общее-описание)
2. [Архитектура](#архитектура)
3. [Технологический стек](#технологический-стек)
4. [Структура проекта](#структура-проекта)
5. [Сущности и модели](#сущности-и-модели)
6. [Поток данных (Data Flow)](#поток-данных-data-flow)
7. [Экраны и функциональность](#экраны-и-функциональность)
8. [Система Leitner](#система-leitner)
9. [Геймификация](#геймификация)
10. [Текущее состояние и проблемы](#текущее-состояние-и-проблемы)

---

## 1. Общее описание

**Memora V1** — мобильное Flutter-приложение для интервального повторения карточек по системе Leitner.

### Основные возможности:
- 📝 Создание карточек (вопрос + ответ)
- 🔄 Интервальное повторение (система Leitner)
- 📊 Статистика обучения
- 🏆 Геймификация (очки, уровни)

---

## 2. Архитектура

Проект построен по **Clean Architecture** с разделением на слои:

```
lib/
├── core/                    # Общие компоненты
│   ├── theme/              # Темы (AppTheme)
│   └── router/             # Навигация (GoRouter)
├── features/               # Фичи (по функциональности)
│   ├── cards/             # Основная функциональность карточек
│   │   ├── data/          # Data Layer (репозитории, модели)
│   │   ├── domain/        # Domain Layer (сущности, usecases)
│   │   └── presentation/  # Presentation Layer (Bloc, UI)
│   └── stats/             # Статистика
└── main.dart              # Точка входа
```

### Принципы:
- **Repository Pattern** — абстракция над источником данных
- **UseCase классы** — бизнес-логика отделена от UI
- **Bloc** — state management
- **Isar** — локальная база данных

---

## 3. Технологический стек

| Компонент | Технология | Версия |
|-----------|------------|--------|
| Framework | Flutter | SDK >=3.2.0 |
| Language | Dart | 3.2.x |
| State Management | flutter_bloc | 8.1.3 |
| Local Database | Isar | 3.1.0+1 |
| Navigation | go_router | 13.2.0 |
| Equatable | equatable | 2.0.5 |

---

## 4. Структура проекта

### Файлы проекта:

```
lib/
├── main.dart                                    # Точка входа, инициализация Isar
├── core/
│   ├── theme/app_theme.dart                     # Цвета, стили, темы
│   └── router/app_router.dart                   # Настройка GoRouter
├── features/
│   ├── cards/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── card_model.dart              # Isar модель (сущность БД)
│   │   │   │   └── card_model.g.dart            # Сгенерированный код Isar
│   │   │   └── repositories/
│   │   │       └── card_repository_impl.dart    # Реализация репозитория
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── card_entity.dart             # Доменная сущность
│   │   │   ├── repositories/
│   │   │   │   └── card_repository.dart         # Абстрактный репозиторий
│   │   │   └── usecases/
│   │   │       ├── add_card.dart                # Добавить карточку
│   │   │       ├── get_all_cards.dart           # Получить все карточки
│   │   │       ├── get_cards_for_review.dart    # Получить карточки для повторения
│   │   │       └── update_card_interval.dart     # Обновить интервал
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── cards_bloc.dart               # Основной Bloc
│   │       │   ├── cards_event.dart              # События Bloc
│   │       │   └── cards_state.dart              # Состояния Bloc
│   │       ├── pages/
│   │       │   ├── home_page.dart                # Главный экран
│   │       │   ├── add_card_page.dart            # Добавление карточки
│   │       │   ├── review_page.dart              # Повторение карточек
│   │       │   └── stats_page.dart               # Статистика
│   │       └── widgets/
│   │           ├── card_widget.dart               # Виджет карточки
│   │           └── progress_widget.dart          # Прогресс-виджет
│   └── stats/
│       └── presentation/
│           └── pages/stats_page.dart             # Страница статистики
```

---

## 5. Сущности и модели

### CardEntity (domain layer)

```dart
class CardEntity extends Equatable {
  final int? id;                    // ID в БД (nullable для новых карточек)
  final String question;            // Вопрос
  final String answer;              // Ответ
  final int interval;               // Интервал в днях до следующего повторения
  final DateTime nextReviewDate;    // Дата следующего повторения
  final int successCount;           // Количество правильных ответов
  final int failCount;              // Количество неправильных ответов
}
```

### CardModel (data layer — Isar)

Модель для БД с аннотацией `@collection`. Содержит методы:
- `fromEntity()` — конвертация Entity → Model
- `toEntity()` — конвертация Model → Entity

---

## 6. Поток данных (Data Flow)

```
┌─────────────────────────────────────────────────────────────────┐
│                         UI (Pages)                              │
│  HomePage, AddCardPage, ReviewPage, StatsPage                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Bloc (CardsBloc)                             │
│  Events: LoadAllCards, AddCardEvent, LoadReviewCards,          │
│          CardAnsweredEvent                                      │
│  States: CardsInitial, CardsLoading, CardsLoaded,               │
│          ReviewCardsLoaded, CardsError                         │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      UseCases                                   │
│  GetAllCards, AddCard, GetCardsForReview, UpdateCardInterval    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                  Repository (CardRepository)                   │
│  - getAllCards()                                                │
│  - addCard()                                                    │
│  - getCardsForReview()                                          │
│  - updateCard()                                                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│              Repository Impl (CardRepositoryImpl)              │
│  Работа с Isar: чтение/запись в локальную БД                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     Isar Database                               │
│  Локальное хранилище на устройстве                              │
└─────────────────────────────────────────────────────────────────┘
```

### Инициализация (main.dart):

```dart
void main() async {
  // 1. Инициализация Isar
  final isar = await Isar.open([CardModelSchema], directory: dir.path);
  
  // 2. Создание зависимостей
  final cardRepository = CardRepositoryImpl(isar);
  final getAllCards = GetAllCards(cardRepository);
  // ... остальные use cases
  
  // 3. Создание BlocProvider
  return BlocProvider(
    create: (context) => CardsBloc(
      getAllCards: getAllCards,
      // ... остальные зависимости
    ),
    child: MaterialApp.router(...)
  );
}
```

---

## 7. Экраны и функциональность

### 7.1 HomePage (Главный экран)

**Путь:** `/`

**Отображает:**
- Прогресс-виджет (очки, уровень, изучено/всего)
- Кнопка "Начать повторение" (если есть карточки для повторения)
- Список всех карточек
- FAB для добавления новой карточки

**Действия:**
- Нажатие на кнопку повторения → переход на ReviewPage
- Нажатие FAB → переход на AddCardPage
- Нажатие на иконку статистики → переход на StatsPage

### 7.2 AddCardPage (Добавление карточки)

**Путь:** `/add`

**Поля:**
- Вопрос (question) — обязательное поле
- Ответ (answer) — обязательное поле

**Поведение:**
- При сохранении: добавляет карточку в БД
- После успешного добавления: показывает SnackBar и возвращает на HomePage

**Новая карточка создается с:**
- `interval: 1` (1 день)
- `nextReviewDate: DateTime.now()` (доступна сразу)
- `successCount: 0`
- `failCount: 0`

### 7.3 ReviewPage (Повторение карточек)

**Путь:** `/review`

**Логика:**
- Загружает карточки, готовые к повторению (где `nextReviewDate <= now`)
- Показывает вопрос → пользователь нажимает "Показать ответ" → показывает ответ
- Пользователь выбирает "Знаю" или "Не знаю"
- На основе ответа обновляется интервал карточки (система Leitner)

**Экран завершения:**
- Показывает процент правильных ответов
- Количество правильных/неправильных
- Кнопка возврата на главный экран

### 7.4 StatsPage (Статистика)

**Путь:** `/stats`

**Отображает:**
- Главная карточка: точность (%), очки, уровень
- Карточки: всего, изучено
- Ответы: правильно, ошибки
- Серия (streak) — максимальное количество карточек подряд с преобладанием правильных ответов
- Список всех карточек с их статистикой (точность %, правильно/ошибки, интервал)

---

## 8. Система Leitner

Текущая реализация (упрощенная):

При ответе на карточку:
- **Правильный ответ:** `interval *= 2` (удвоение интервала)
- **Неправильный ответ:** `interval = 1` (сброс до 1 дня)

**Интервалы:**
- День 1 → День 2 → День 4 → День 8 → День 16 → День 32...

**Готовность к повторению:**
Карточка готова к повторению когда `nextReviewDate <= DateTime.now()`

**Обновление даты после ответа:**
```dart
nextReviewDate = DateTime.now().add(Duration(days: interval));
```

---

## 9. Геймификация

### Очки (Points):
- **+10 очков** за каждый правильный ответ
- Формула: `totalPoints = totalSuccess * 10`

### Уровень (Level):
- Формула: `level = totalPoints ~/ 100`
- Пример: 0-99 очков = уровень 0, 100-199 = уровень 1, и т.д.

### Отображение:
- Прогресс-виджет на HomePage показывает очки, уровень, прогресс изучения
- StatsPage показывает детальную статистику

---

## 10. Текущее состояние и проблемы

### ✅ Реализовано:
1. Создание Flutter-проекта с Clean Architecture
2. 4 экрана (Home, AddCard, Review, Stats)
3. Настройка Isar для локальной БД
4. Bloc для state management
5. Система Leitner (базовая реализация)
6. Геймификация (очки, уровни)
7. Защита от крашей (try-catch обёртки)

### ⚠️ Известные проблемы:
1. **Данные могут не отображаться** — иногда карточки не загружаются корректно при запуске
2. **Возможны ошибки при инициализации Isar** — добавлены защитные механизмы, но на некоторых устройствах могут быть проблемы
3. **Упрощенная система Leitner** — текущая реализация не полностью соответствует классической системе Leitner с 5 коробками

### 📋 TODO для доработки:
1. Исправить загрузку данных при старте
2. Улучшить систему Leitner (добавить коробки/уровни)
3. Улучшить UI/UX (новый концепт от пользователя)
4. Добавить дополнительные функции (удаление карточек, редактирование, категории)
5. Добавить тесты

---

## Технические детали

### Навигация (GoRouter):
```dart
static final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(path: '/add', builder: (context, state) => const AddCardPage()),
    GoRoute(path: '/review', builder: (context, state) => const ReviewPage()),
    GoRoute(path: '/stats', builder: (context, state) => const StatsPage()),
  ],
);
```

### Цветовая схема (AppTheme):
```dart
primaryColor: Color(0xFF6366F1)      // Indigo
secondaryColor: Color(0xFF8B5CF6)   // Purple
successColor: Color(0xFF22C55E)     // Green
errorColor: Color(0xFFEF4444)       // Red
backgroundColor: Color(0xFFF8FAFC)  // Light grey
```

### Сборка:
```bash
flutter build apk --debug
# Выход: build\app\outputs\flutter-apk\app-debug.apk
```

---

*Документация создана на основе анализа исходного кода проекта Memora V1.*
*Дата: 06.04.2026*