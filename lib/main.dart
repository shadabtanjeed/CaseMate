import 'package:flutter/material.dart';
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
import 'features/lawyer/presentation/screens/lawyer_dashboard_screen.dart';
import 'features/notifications/presentation/screens/notifications_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
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
  int _selectedLawyerId = 1;

  void _navigateTo(String screen) {
    setState(() {
      _currentScreen = screen;
    });
  }

  void _handleLogin() {
    setState(() {
      _currentScreen = 'home';
    });
    _showSnackbar('Welcome back!');
  }

  void _handleRegister() {
    setState(() {
      _currentScreen = 'home';
    });
    _showSnackbar('Account created successfully!');
  }

  void _handleLogout() {
    setState(() {
      _currentScreen = 'login';
    });
    _showSnackbar('Logged out successfully');
  }

  void _handleSelectLawyer(int lawyerId) {
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
          onLogin: _handleLogin,
          onNavigateToRegister: () => _navigateTo('register'),
        );

      case 'register':
        return RegisterScreen(
          onRegister: _handleRegister,
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

      case 'lawyer-dashboard':
        return LawyerDashboardScreen(onBack: () => _navigateTo('home'));

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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Navigate to Screen',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildScreenChip('Splash', 'splash'),
                _buildScreenChip('Onboarding', 'onboarding'),
                _buildScreenChip('Login', 'login'),
                _buildScreenChip('Register', 'register'),
                _buildScreenChip('Home', 'home'),
                _buildScreenChip('Chatbot', 'chatbot'),
                _buildScreenChip('Lawyers', 'lawyers'),
                _buildScreenChip('Lawyer Detail', 'lawyer-detail'),
                _buildScreenChip('Booking', 'booking'),
                _buildScreenChip('Video Call', 'video-call'),
                _buildScreenChip('Profile', 'profile'),
                _buildScreenChip('Dashboard', 'lawyer-dashboard'),
                _buildScreenChip('Notifications', 'notifications'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenChip(String label, String screen) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        Navigator.pop(context);
        _navigateTo(screen);
      },
      backgroundColor:
          _currentScreen == screen ? AppTheme.primaryBlue : AppTheme.background,
      labelStyle: TextStyle(
        color: _currentScreen == screen ? Colors.white : AppTheme.textPrimary,
      ),
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
