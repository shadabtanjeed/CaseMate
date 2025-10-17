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
import 'features/video_call/presentation/screens/video_call_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/notifications/presentation/screens/notifications_screen.dart';
import 'features/lawyer/lawyer_home_screen.dart';
import 'features/lawyer/lawyer_clients_screen.dart';
import 'features/lawyer/lawyer_schedule_screen.dart';
import 'features/auth/data/datasources/auth_local_datasources.dart';
import 'features/auth/data/models/user_model.dart';
import 'features/lawyer/lawyer_cases_screen.dart';
import 'features/lawyer/lawyer_reviews_screen.dart';
import 'features/lawyer/lawyer_earnings_screen.dart';
import 'features/profile/presentation/screens/userpovsessions_screen.dart';

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
  bool _openAvailabilityTab = false;
  String? _selectedSpecialization;

  void _navigateTo(String screen) {
    setState(() {
      _currentScreen = screen;
    });
    // debug trace so we can see navigation activity in logs
    debugPrint('[AppNavigator] navigateTo: $_currentScreen');
  }

  void _navigateToLawyersWithSpecialization(String? spec) {
    setState(() {
      _selectedSpecialization = spec;
      _currentScreen = 'lawyers';
    });
    debugPrint('[AppNavigator] navigateToLawyersWithSpecialization: $_selectedSpecialization');
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
    debugPrint('[AppNavigator] handleLogin -> $_currentScreen (role=$role)');
  }

  void _handleRegister() {
    setState(() {
      _currentScreen = 'login';
    });
    _showSnackbar('Account created successfully! Please login.');
    debugPrint('[AppNavigator] handleRegister -> login');
  }

  void _handleLogout() {
    setState(() {
      _currentScreen = 'login';
    });
    _showSnackbar('Logged out successfully');
    debugPrint('[AppNavigator] handleLogout -> login');
  }

  void _handleSelectLawyer(String lawyerId) {
    setState(() {
      _selectedLawyerId = lawyerId;
      _currentScreen = 'lawyer-detail';
      _openAvailabilityTab = false;
    });
    debugPrint('[AppNavigator] handleSelectLawyer -> $_selectedLawyerId');
  }

  void _handleBookNowLawyer(String lawyerId) {
    setState(() {
      _selectedLawyerId = lawyerId;
      _currentScreen = 'lawyer-detail';
      _openAvailabilityTab = true;
    });
    _showSnackbar('Booking confirmed successfully!');
    debugPrint('[AppNavigator] handleBookingConfirm -> home');
  }

  void _handleEndCall() {
    setState(() {
      _currentScreen = 'home';
    });
    _showSnackbar('Call ended');
    debugPrint('[AppNavigator] handleEndCall -> home');
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.fixed,
        backgroundColor: AppTheme.primaryBlue,
        duration: const Duration(milliseconds: 1500),
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
          onNavigateToLawyers: (String? spec) => _navigateToLawyersWithSpecialization(spec),
          onNavigateToSessions: () => _navigateTo('sessions'),
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
          onBookNowLawyer: _handleBookNowLawyer,
          initialSpecialization: _selectedSpecialization,
        );

      case 'lawyer-detail':
        return LawyerDetailScreen(
          lawyerId: _selectedLawyerId,
          onBack: () {
            _openAvailabilityTab = false;
            _navigateTo('lawyers');
          },
          onBookConsultation: () => _navigateTo('booking'),
          initialTabIndex: _openAvailabilityTab ? 2 : 0,
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
        return FutureBuilder<UserModel?>(
          future: AuthLocalDataSourceImpl().getUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final user = snapshot.data;
            final email = user?.email ?? '';
            return LawyerScheduleScreen(
              onBack: () => _navigateTo('lawyer-home'),
              currentLawyerEmail: email,
            );
          },
        );

      case 'lawyer-cases':
        return LawyerCasesScreen(onBack: () => _navigateTo('lawyer-home'));

      case 'lawyer-reviews':
        return LawyerReviewsScreen(onBack: () => _navigateTo('lawyer-home'));

      case 'lawyer-earnings':
        return LawyerEarningsScreen(onBack: () => _navigateTo('lawyer-home'));

      case 'notifications':
        return NotificationsScreen(onBack: () => _navigateTo('home'));

      case 'sessions':
        return UserPovSessionsScreen(onBack: () => _navigateTo('home'));

      default:
        return SplashScreen(onComplete: () => _navigateTo('onboarding'));
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    try {
      body = _buildScreen();
    } catch (e, st) {
      // Show a visible error widget instead of a white screen so we can debug
      final msg = 'Error building screen: $e\n${st.toString().split('\n').take(8).join('\n')}';
      debugPrint('[AppNavigator] $msg');
      body = Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Text(
            msg,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      body: body,
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
                const Row(
                  children: [
                    Icon(Icons.navigation, color: AppTheme.primaryBlue),
                    SizedBox(width: 8),
                    Text(
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
