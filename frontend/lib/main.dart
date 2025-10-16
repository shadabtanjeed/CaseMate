import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/onboarding_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/profile/presentation/screens/home_screen.dart';
import 'features/chat/presentation/screens/chatbot_screen.dart';
import 'features/lawyer/presentation/screens/lawyer_discovery_screen.dart';
import 'features/lawyer/presentation/screens/lawyer_detail_screen.dart';
import 'features/booking/presentation/screens/booking_screen.dart';
import 'features/video_call/presentation/screens/video_call_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/notifications/presentation/screens/notifications_screen.dart';
import 'features/lawyer/lawyer_home_screen.dart';
import 'features/lawyer/lawyer_clients_screen.dart';
import 'features/lawyer/lawyer_schedule_screen.dart';
import 'features/lawyer/lawyer_cases_screen.dart';
import 'features/lawyer/lawyer_reviews_screen.dart';
import 'features/lawyer/lawyer_earnings_screen.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LegalAssist',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const AppNavigator(),
    );
  }
}

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  String _currentScreen = 'splash';
  String _selectedLawyerId = '';

  void _navigateTo(String screen) {
    setState(() {
      _currentScreen = screen;
    });
  }

  void _handleLogin([String? role]) {
    setState(() {
      if (role == 'lawyer') {
        _currentScreen = 'lawyer-home';
      } else {
        _currentScreen = 'home';
      }
    });
    _showSnackbar('Welcome back!');
  }

  void _handleRegister() {
    setState(() {
      _currentScreen = 'login';
    });
    _showSnackbar('Account created successfully! Please login.');
  }

  void _handleLogout() {
    setState(() {
      _currentScreen = 'login';
    });
    _showSnackbar('Logged out successfully');
  }

  void _handleSelectLawyer(String lawyerId) {
    setState(() {
      _selectedLawyerId = lawyerId;
      _currentScreen = 'lawyer-detail';
    });
  }

  void _handleBookingConfirm() {
    setState(() {
      _currentScreen = 'home';
    });
    _showSnackbar('Booking confirmed successfully!');
  }

  void _handleEndCall() {
    setState(() {
      _currentScreen = 'home';
    });
    _showSnackbar('Call ended');
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppTheme.primaryBlue,
      ),
    );
  }

  Widget _buildScreen() {
    switch (_currentScreen) {
      case 'splash':
        return SplashScreen(onComplete: () => _navigateTo('onboarding'));

      case 'onboarding':
        return OnboardingScreen(onComplete: () => _navigateTo('login'));

      case 'login':
        return LoginScreen(
          onLoginSuccess: _handleLogin,
          onNavigateToRegister: () => _navigateTo('register'),
        );

      case 'register':
        return RegisterScreen(
          onRegisterSuccess: _handleRegister,
          onNavigateToLogin: () => _navigateTo('login'),
        );

      case 'home':
        return HomeScreen(
          onNavigateToChatbot: () => _navigateTo('chatbot'),
          onNavigateToLawyers: () => _navigateTo('lawyers'),
          onNavigateToProfile: () => _navigateTo('profile'),
          onNavigateToNotifications: () => _navigateTo('notifications'),
        );

      case 'chatbot':
        return ChatbotScreen(
          onBack: () => _navigateTo('home'),
          onSuggestLawyers: () => _navigateTo('lawyers'),
        );

      case 'lawyers':
        return LawyerDiscoveryScreen(
          onBack: () => _navigateTo('home'),
          onSelectLawyer: _handleSelectLawyer,
        );

      case 'lawyer-detail':
        return LawyerDetailScreen(
          lawyerId: _selectedLawyerId,
          onBack: () => _navigateTo('lawyers'),
          onBookConsultation: () => _navigateTo('booking'),
        );

      case 'booking':
        return BookingScreen(
          onBack: () => _navigateTo('lawyer-detail'),
          onConfirm: _handleBookingConfirm,
        );

      case 'video-call':
        return VideoCallScreen(onEndCall: _handleEndCall);

      case 'profile':
        return ProfileScreen(
          onBack: () => _navigateTo('home'),
          onLogout: _handleLogout,
        );

      case 'lawyer-home':
        return LawyerHomeScreen(
          onNavigateToClients: () => _navigateTo('lawyer-clients'),
          onNavigateToSchedule: () => _navigateTo('lawyer-schedule'),
          onNavigateToEarnings: () => _navigateTo('lawyer-earnings'),
          onNavigateToProfile: () => _navigateTo('profile'),
          onNavigateToNotifications: () => _navigateTo('notifications'),
          onNavigateToReviews: () => _navigateTo('lawyer-reviews'),
          onNavigateToCases: () => _navigateTo('lawyer-cases'),
        );

      case 'lawyer-clients':
        return LawyerClientsScreen(onBack: () => _navigateTo('lawyer-home'));

      case 'lawyer-schedule':
        return LawyerScheduleScreen(onBack: () => _navigateTo('lawyer-home'));

      case 'lawyer-cases':
        return LawyerCasesScreen(onBack: () => _navigateTo('lawyer-home'));

      case 'lawyer-reviews':
        return LawyerReviewsScreen(onBack: () => _navigateTo('lawyer-home'));

      case 'lawyer-earnings':
        return LawyerEarningsScreen(onBack: () => _navigateTo('lawyer-home'));

      case 'notifications':
        return NotificationsScreen(onBack: () => _navigateTo('home'));

      default:
        return SplashScreen(onComplete: () => _navigateTo('onboarding'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildScreen(),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => _showScreenSelector(context),
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.settings, color: Colors.white),
      ),
      floatingActionButtonLocation: _MidLeftFabLocation(),
    );
  }

  void _showScreenSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.navigation, color: AppTheme.primaryBlue),
                    const SizedBox(width: 8),
                    const Text(
                      'Navigate to Screen',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Quick access to all screens',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                _buildSection('Auth Screens', [
                  _buildScreenChip('Splash', 'splash'),
                  _buildScreenChip('Onboarding', 'onboarding'),
                  _buildScreenChip('Login', 'login'),
                  _buildScreenChip('Register', 'register'),
                ]),
                const SizedBox(height: 16),
                _buildSection('Main Screens', [
                  _buildScreenChip('Home', 'home'),
                  _buildScreenChip('Chatbot', 'chatbot'),
                  _buildScreenChip('Profile', 'profile'),
                  _buildScreenChip('Notifications', 'notifications'),
                ]),
                const SizedBox(height: 16),
                _buildSection('Client Lawyer Screens', [
                  _buildScreenChip('Lawyers', 'lawyers'),
                  _buildScreenChip('Lawyer Detail', 'lawyer-detail'),
                  _buildScreenChip('Booking', 'booking'),
                  _buildScreenChip('Video Call', 'video-call'),
                ]),
                const SizedBox(height: 16),
                _buildSection('Lawyer Portal', [
                  _buildScreenChip('Lawyer Home', 'lawyer-home'),
                  _buildScreenChip('Clients', 'lawyer-clients'),
                  _buildScreenChip('Schedule', 'lawyer-schedule'),
                  _buildScreenChip('Cases', 'lawyer-cases'),
                  _buildScreenChip('Reviews', 'lawyer-reviews'),
                  _buildScreenChip('Earnings', 'lawyer-earnings'),
                ]),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> chips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: chips,
        ),
      ],
    );
  }

  Widget _buildScreenChip(String label, String screen) {
    final isActive = _currentScreen == screen;
    return ActionChip(
      label: Text(label),
      onPressed: () {
        Navigator.pop(context);
        _navigateTo(screen);
      },
      backgroundColor:
          isActive ? AppTheme.primaryBlue : Theme.of(context).cardColor,
      side: BorderSide(
        color: isActive ? AppTheme.primaryBlue : Theme.of(context).dividerColor,
        width: 1,
      ),
      labelStyle: TextStyle(
        color: isActive
            ? Colors.white
            : Theme.of(context).textTheme.bodyLarge?.color,
        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
      ),
      elevation: isActive ? 2 : 0,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}

class _MidLeftFabLocation extends FloatingActionButtonLocation {
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    const double fabX = 16.0; // Left margin
    final double fabY = scaffoldGeometry.scaffoldSize.height / 2 -
        scaffoldGeometry.floatingActionButtonSize.height / 2;
    return Offset(fabX, fabY);
  }
}
