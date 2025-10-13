# CaseMate - Clean Architecture Structure

This project follows Clean Architecture principles to ensure maintainability, testability, and scalability.

## Project Structure

```
lib/
├── core/                           # Core functionality shared across features
│   ├── constants/                  # App-wide constants
│   │   └── legal_category.dart
│   ├── theme/                      # App theming
│   │   └── app_theme.dart
│   └── utils/                      # Utility functions and helpers
│
├── features/                       # Feature-based modules
│   ├── auth/                       # Authentication feature
│   │   ├── data/
│   │   │   ├── datasources/        # Remote and local data sources
│   │   │   ├── models/             # Data models (extends entities)
│   │   │   └── repositories/       # Repository implementations
│   │   ├── domain/
│   │   │   ├── entities/           # Business entities
│   │   │   ├── repositories/       # Repository interfaces
│   │   │   └── usecases/           # Business logic/use cases
│   │   └── presentation/
│   │       ├── screens/            # UI screens
│   │       │   ├── login_screen.dart
│   │       │   ├── register_screen.dart
│   │       │   ├── onboarding_screen.dart
│   │       │   └── splash_screen.dart
│   │       └── widgets/            # Feature-specific widgets
│   │
│   ├── lawyer/                     # Lawyer discovery and details
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   │   ├── lawyer_model.dart
│   │   │   │   └── review_model.dart
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── lawyer_entity.dart
│   │   │   │   └── review_entity.dart
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── lawyer_discovery_screen.dart
│   │       │   ├── lawyer_detail_screen.dart
│   │       │   └── lawyer_dashboard_screen.dart
│   │       └── widgets/
│   │
│   ├── booking/                    # Consultation booking
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   │   ├── time_slot_model.dart
│   │   │   │   └── consultation_model.dart
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── time_slot_entity.dart
│   │   │   │   └── consultation_entity.dart
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── booking_screen.dart
│   │       └── widgets/
│   │
│   ├── video_call/                 # Video consultation
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── video_call_screen.dart
│   │       └── widgets/
│   │
│   ├── chat/                       # Chatbot feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── chatbot_screen.dart
│   │       └── widgets/
│   │
│   ├── profile/                    # User profile and home
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── home_screen.dart
│   │       │   └── profile_screen.dart
│   │       └── widgets/
│   │
│   └── notifications/              # Notifications
│       ├── data/
│       ├── domain/
│       └── presentation/
│           ├── screens/
│           │   └── notifications_screen.dart
│           └── widgets/
│
└── main.dart                       # App entry point
```

## Architecture Layers

### 1. **Presentation Layer** (`presentation/`)

- **Screens**: UI pages and navigation
- **Widgets**: Reusable UI components specific to the feature
- **State Management**: Will contain BLoC/Cubit/Provider (to be added)

### 2. **Domain Layer** (`domain/`)

- **Entities**: Core business objects (pure Dart classes)
- **Repositories**: Abstract interfaces defining contracts
- **Use Cases**: Business logic and application-specific rules

### 3. **Data Layer** (`data/`)

- **Models**: Data transfer objects that extend entities
- **Data Sources**: API clients, local database, cache implementations
- **Repositories**: Concrete implementations of domain repository interfaces

## Key Principles

1. **Dependency Rule**: Dependencies point inward (Presentation → Domain ← Data)
2. **Separation of Concerns**: Each layer has a specific responsibility
3. **Testability**: Business logic is independent of frameworks and UI
4. **Scalability**: Easy to add new features without affecting existing code
5. **Maintainability**: Clear structure makes code easier to understand and modify

## Benefits

- ✅ **Independent of Frameworks**: Business logic doesn't depend on Flutter
- ✅ **Testable**: Can test business logic without UI
- ✅ **Independent of UI**: Can change UI without affecting business logic
- ✅ **Independent of Database**: Can swap data sources easily
- ✅ **Independent of External Services**: Business rules don't know about the outside world

## Next Steps for Full Implementation

1. **Add State Management** (e.g., flutter_bloc, riverpod, provider)
2. **Implement Repository Interfaces** in domain layer
3. **Create Repository Implementations** in data layer
4. **Add Use Cases** for business logic
5. **Implement Data Sources** (API clients, local storage)
6. **Add Dependency Injection** (e.g., get_it, injectable)
7. **Add Error Handling** and failure classes
8. **Implement Unit Tests** for each layer

## Migration Notes

- All screens moved from `lib/screens/` to their respective feature folders
- Theme moved from `lib/theme/` to `lib/core/theme/`
- Models separated into entities (domain) and models (data)
- Import paths updated throughout the application
- Original functionality preserved - no behavior changes
