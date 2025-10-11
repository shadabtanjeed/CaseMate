# Clean Architecture Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                         │
│  (UI, Widgets, Screens, State Management)                        │
│                                                                   │
│  • Displays data to user                                         │
│  • Handles user interactions                                     │
│  • Triggers use cases                                            │
│  • Observes state changes                                        │
└────────────────────────────┬──────────────────────────────────────┘
                             │
                             ↓
┌─────────────────────────────────────────────────────────────────┐
│                         DOMAIN LAYER                             │
│  (Entities, Use Cases, Repository Interfaces)                   │
│                                                                   │
│  • Business logic                                                │
│  • Application-specific rules                                    │
│  • Independent of frameworks                                     │
│  • Defines contracts (interfaces)                                │
└────────────────────────────┬──────────────────────────────────────┘
                             │
                             ↓
┌─────────────────────────────────────────────────────────────────┐
│                          DATA LAYER                              │
│  (Models, Repositories, Data Sources)                           │
│                                                                   │
│  • Repository implementations                                    │
│  • API clients                                                   │
│  • Local database                                                │
│  • Data transformation                                           │
└─────────────────────────────────────────────────────────────────┘
                             │
                             ↓
                   ┌─────────┴─────────┐
                   │                   │
                   ↓                   ↓
         ┌──────────────┐    ┌──────────────┐
         │ Remote Data  │    │  Local Data  │
         │   (API)      │    │  (Database)  │
         └──────────────┘    └──────────────┘
```

## Data Flow Example: Loading Lawyers

```
User Action (Tap "Find Lawyers")
         ↓
[Presentation Layer]
LawyerDiscoveryScreen → Triggers event
         ↓
[Domain Layer]
GetLawyersUseCase → Calls repository interface
         ↓
[Data Layer]
LawyerRepositoryImpl → Fetches from data source
         ↓
LawyerRemoteDataSource → Makes API call
         ↓
Returns LawyerModel (converts to LawyerEntity)
         ↓
[Domain Layer]
Returns List<LawyerEntity>
         ↓
[Presentation Layer]
Screen updates with new data
```

## Feature Structure Example: Lawyer Feature

```
features/lawyer/
│
├── data/
│   ├── datasources/
│   │   ├── lawyer_remote_datasource.dart
│   │   └── lawyer_local_datasource.dart
│   ├── models/
│   │   ├── lawyer_model.dart (extends LawyerEntity)
│   │   └── review_model.dart (extends ReviewEntity)
│   └── repositories/
│       └── lawyer_repository_impl.dart (implements LawyerRepository)
│
├── domain/
│   ├── entities/
│   │   ├── lawyer_entity.dart (pure business object)
│   │   └── review_entity.dart
│   ├── repositories/
│   │   └── lawyer_repository.dart (abstract interface)
│   └── usecases/
│       ├── get_lawyers.dart
│       ├── get_lawyer_details.dart
│       └── search_lawyers.dart
│
└── presentation/
    ├── bloc/ (or cubit/, provider/)
    │   ├── lawyer_bloc.dart
    │   ├── lawyer_event.dart
    │   └── lawyer_state.dart
    ├── screens/
    │   ├── lawyer_discovery_screen.dart
    │   ├── lawyer_detail_screen.dart
    │   └── lawyer_dashboard_screen.dart
    └── widgets/
        ├── lawyer_card.dart
        ├── review_card.dart
        └── rating_widget.dart
```

## Dependency Flow

```
main.dart
    ↓
Initialize Dependencies (DI Container)
    ↓
Register Data Sources
    ↓
Register Repositories
    ↓
Register Use Cases
    ↓
Register BLoCs/Cubits
    ↓
Run App
```

## Key Rules

1. **Domain layer** knows nothing about other layers
2. **Data layer** knows about domain entities
3. **Presentation layer** knows about domain entities and use cases
4. Dependencies always point INWARD toward domain
5. Each layer can only access the layer directly inside it
