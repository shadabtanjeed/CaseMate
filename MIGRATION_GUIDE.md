# Migration Guide: Clean Architecture Implementation

## Completed Changes ✅

### 1. Folder Structure Migration

- ✅ Created new clean architecture folder structure
- ✅ Moved all screens to feature-based folders
- ✅ Separated theme into core layer
- ✅ Created entity and model layers
- ✅ Deleted old folder structure

### 2. File Reorganization

- ✅ `lib/screens/*` → `lib/features/*/presentation/screens/`
- ✅ `lib/theme/app_theme.dart` → `lib/core/theme/app_theme.dart`
- ✅ `lib/models/lawyer.dart` → Split into entities and models

### 3. Import Path Updates

- ✅ Updated all screen imports in `main.dart`
- ✅ Updated theme imports in all screen files
- ✅ Created feature export files for easy imports

### 4. Documentation

- ✅ Created `ARCHITECTURE.md` with structure overview
- ✅ Created `ARCHITECTURE_FLOW.md` with diagrams and examples
- ✅ Created this migration guide

## Current Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── legal_category.dart
│   ├── theme/
│   │   └── app_theme.dart
│   ├── utils/
│   └── core.dart (barrel file)
│
├── features/
│   ├── auth/
│   │   ├── presentation/screens/
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   ├── splash_screen.dart
│   │   │   └── onboarding_screen.dart
│   │   └── auth.dart (barrel file)
│   │
│   ├── lawyer/
│   │   ├── data/models/
│   │   │   ├── lawyer_model.dart
│   │   │   └── review_model.dart
│   │   ├── domain/entities/
│   │   │   ├── lawyer_entity.dart
│   │   │   └── review_entity.dart
│   │   ├── presentation/screens/
│   │   │   ├── lawyer_discovery_screen.dart
│   │   │   ├── lawyer_detail_screen.dart
│   │   │   └── lawyer_dashboard_screen.dart
│   │   └── lawyer.dart (barrel file)
│   │
│   ├── booking/
│   │   ├── data/models/
│   │   │   ├── time_slot_model.dart
│   │   │   └── consultation_model.dart
│   │   ├── domain/entities/
│   │   │   ├── time_slot_entity.dart
│   │   │   └── consultation_entity.dart
│   │   ├── presentation/screens/
│   │   │   └── booking_screen.dart
│   │   └── booking.dart (barrel file)
│   │
│   ├── video_call/
│   │   ├── presentation/screens/
│   │   │   └── video_call_screen.dart
│   │   └── video_call.dart (barrel file)
│   │
│   ├── chat/
│   │   ├── presentation/screens/
│   │   │   └── chatbot_screen.dart
│   │   └── chat.dart (barrel file)
│   │
│   ├── profile/
│   │   ├── presentation/screens/
│   │   │   ├── home_screen.dart
│   │   │   └── profile_screen.dart
│   │   └── profile.dart (barrel file)
│   │
│   └── notifications/
│       ├── presentation/screens/
│       │   └── notifications_screen.dart
│       └── notifications.dart (barrel file)
│
└── main.dart
```

## Next Steps (TODO) 📋

### Phase 1: State Management Setup

- [ ] Choose state management solution (BLoC/Cubit/Riverpod/Provider)
- [ ] Add dependencies to `pubspec.yaml`
- [ ] Create BLoC/Cubit/Provider structure for each feature
- [ ] Implement events and states for features

### Phase 2: Repository Pattern Implementation

- [ ] Create repository interfaces in `domain/repositories/`
- [ ] Implement repositories in `data/repositories/`
- [ ] Add error handling (Either pattern or exceptions)
- [ ] Create failure classes

### Phase 3: Use Cases Implementation

- [ ] Create use cases for each feature in `domain/usecases/`
- [ ] Examples:
  - `GetLawyersUseCase`
  - `SearchLawyersUseCase`
  - `BookConsultationUseCase`
  - `LoginUseCase`
  - `RegisterUseCase`

### Phase 4: Data Sources

- [ ] Create remote data source interfaces
- [ ] Implement API clients
- [ ] Add local data sources (SQLite/Hive/SharedPreferences)
- [ ] Implement caching strategy

### Phase 5: Dependency Injection

- [ ] Add `get_it` or `injectable` package
- [ ] Create injection container
- [ ] Register all dependencies
- [ ] Update main.dart to initialize DI

### Phase 6: Testing

- [ ] Unit tests for use cases
- [ ] Unit tests for repositories
- [ ] Widget tests for screens
- [ ] Integration tests

### Phase 7: Additional Improvements

- [ ] Add constants files (API endpoints, app strings)
- [ ] Create common widgets in core
- [ ] Add error handling utilities
- [ ] Implement logging
- [ ] Add analytics integration

## How to Use the New Structure

### Import Examples

**Option 1: Direct imports (current)**

```dart
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/lawyer/presentation/screens/lawyer_discovery_screen.dart';
import 'core/theme/app_theme.dart';
```

**Option 2: Using barrel files (recommended for future)**

```dart
import 'features/auth/auth.dart';
import 'features/lawyer/lawyer.dart';
import 'core/core.dart';
```

### Adding a New Feature

1. Create feature folder structure:

```bash
mkdir -p lib/features/new_feature/{data/{datasources,models,repositories},domain/{entities,repositories,usecases},presentation/{screens,widgets}}
```

2. Create entities in `domain/entities/`
3. Create models in `data/models/` (extend entities)
4. Create repository interface in `domain/repositories/`
5. Implement repository in `data/repositories/`
6. Create use cases in `domain/usecases/`
7. Create screens and widgets in `presentation/`
8. Add state management (BLoC/Cubit)

### Example: Adding GetLawyersUseCase

```dart
// lib/features/lawyer/domain/usecases/get_lawyers.dart
class GetLawyersUseCase {
  final LawyerRepository repository;

  GetLawyersUseCase(this.repository);

  Future<Either<Failure, List<LawyerEntity>>> call({
    String? specialization,
    String? location,
  }) async {
    return await repository.getLawyers(
      specialization: specialization,
      location: location,
    );
  }
}
```

## Benefits Achieved

1. ✅ **Clear Separation of Concerns**: Each layer has its own responsibility
2. ✅ **Feature-based Organization**: Easy to locate and modify feature code
3. ✅ **Scalability**: Can add new features without affecting existing code
4. ✅ **Testability**: Prepared for comprehensive testing
5. ✅ **Maintainability**: Easier to understand and modify

## Migration Checklist

- [x] Create new folder structure
- [x] Move screen files
- [x] Move theme files
- [x] Create entity files
- [x] Create model files
- [x] Update import statements
- [x] Create barrel export files
- [x] Create documentation
- [x] Delete old folders
- [ ] Add state management
- [ ] Implement repositories
- [ ] Add use cases
- [ ] Add data sources
- [ ] Setup dependency injection
- [ ] Write tests

## Notes

- All existing functionality has been preserved
- No behavior changes were made
- Only file structure and imports were modified
- App should run exactly as before
