# LegalAssist - Flutter Implementation

A professional, cross-platform legal assistance mobile application built with Flutter.

## Features

### Screens Implemented

1. **Splash Screen** - Animated logo entry with gradient background
2. **Onboarding** - 3 slides introducing app features with smooth page transitions
3. **Authentication**
   - Login with email/password
   - Registration with User/Lawyer tabs
4. **Home Dashboard** - Categories, chatbot access, and upcoming consultations
5. **Chatbot** - Interactive AI legal assistant with mode selector
6. **Lawyer Discovery** - Search, filter, and browse verified lawyers
7. **Lawyer Detail** - Tabs for About, Reviews, and Available Slots
8. **Booking** - Consultation booking with date/time selection
9. **Video Call** - Full-screen video interface with controls
10. **Profile & Settings** - Account management and preferences
11. **Lawyer Dashboard** - Stats, appointments, and messages for lawyers
12. **Notifications** - List of notifications with read/unread states

### Design System

- **Color Palette**

  - Primary Blue: `#1E88E5`
  - Accent Blue: `#64B5F6`
  - Dark Blue: `#0D47A1`
  - Background: `#F9FAFB`
  - Text Primary: `#212121`
  - Text Secondary: `#757575`

- **Typography** - Google Fonts (Inter)
- **Components** - Custom cards, buttons, and navigation elements
- **Animations** - Smooth transitions and micro-interactions

## Project Structure

```
lib/
├── main.dart                 # App entry point and navigation
├── theme/
│   └── app_theme.dart       # Theme configuration and colors
├── models/
│   └── lawyer.dart          # Data models
└── screens/
    ├── splash_screen.dart
    ├── onboarding_screen.dart
    ├── login_screen.dart
    ├── register_screen.dart
    ├── home_screen.dart
    ├── chatbot_screen.dart
    ├── lawyer_discovery_screen.dart
    ├── lawyer_detail_screen.dart
    ├── booking_screen.dart
    ├── video_call_screen.dart
    ├── profile_screen.dart
    ├── lawyer_dashboard_screen.dart
    └── notifications_screen.dart
```

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / VS Code
- iOS Simulator / Android Emulator

### Installation

1. Install dependencies:

```bash
flutter pub get
```

2. Run the app:

```bash
flutter run
```

### Dependencies

- `google_fonts` - Custom typography
- `intl` - Date formatting
- `flutter_svg` - SVG support

## Navigation

The app includes a floating action button (settings icon) that allows you to quickly navigate between all screens during development.

## Features by Screen

### Home Screen

- Welcome header with user profile
- Search bar for lawyers
- LegalBot quick access card
- Category grid (Criminal, Civil, Family, Property, Corporate, Tax)
- Upcoming consultations list
- Bottom navigation bar

### Chatbot Screen

- Real-time chat interface
- Mode selector (General Advice / Case Analysis)
- Message bubbles with timestamps
- "Find Lawyers" suggestion button
- File attachment and voice input options

### Lawyer Discovery

- Search functionality
- Filter bottom sheet (specialization, rating, experience, fee)
- Lawyer cards with:
  - Profile photo
  - Verification badge
  - Rating and reviews
  - Location and fee
  - "View Profile" and "Book Now" buttons

### Lawyer Detail

- Tab-based navigation (About, Reviews, Available Slots)
- Professional information and biography
- Education and achievements
- Client reviews with ratings
- Available time slots
- "Chat Now" and "Book Consultation" CTAs

### Booking Screen

- Consultation type selection (Video, Phone, Chat)
- Calendar date picker
- Time slot grid
- Booking summary
- Confirmation button

### Video Call Screen

- Full-screen video interface
- Picture-in-picture user video
- Call timer
- Control buttons (mute, video, end call, chat, more)
- Sliding chat overlay

### Profile Screen

- User profile card with stats
- Account information section
- Notification preferences (push, email)
- Privacy & security settings
- Help & support
- Logout option

### Lawyer Dashboard

- Welcome header
- Stats grid (clients, sessions, rating, revenue)
- Tabs for Appointments and Messages
- Appointment management
- Client messages with unread indicators

### Notifications Screen

- Notification cards with icons
- Read/unread states
- Timestamp for each notification
- "Mark All as Read" button
- Empty state when no notifications

## Customization

### Changing Colors

Edit `lib/theme/app_theme.dart` to modify the color scheme:

```dart
static const Color primaryBlue = Color(0xFF1E88E5);
static const Color accentBlue = Color(0xFF64B5F6);
static const Color darkBlue = Color(0xFF0D47A1);
```

### Adding New Screens

1. Create a new file in `lib/screens/`
2. Implement the screen as a `StatelessWidget` or `StatefulWidget`
3. Add navigation logic in `lib/main.dart`

## Best Practices

- All screens use the centralized theme
- Consistent spacing and padding (8, 12, 16, 24, 32)
- Rounded corners (12, 16, 24)
- Material Design 3 components
- Responsive layouts
- Accessibility support

## Future Enhancements

- Real API integration
- State management (Provider, Riverpod, or Bloc)
- Local storage (Hive or SQLite)
- Push notifications
- Video call SDK integration
- Payment gateway integration
- Multi-language support
- Dark mode

## License

This project is a demonstration of a legal assistance mobile app UI/UX design.
