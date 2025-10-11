import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlide> _slides = [
    OnboardingSlide(
      icon: Icons.chat_bubble_outline,
      title: 'Get Instant Legal Help',
      description: 'Chat with our AI-powered LegalBot for quick answers to your legal questions 24/7',
      color: AppTheme.accentBlue,
    ),
    OnboardingSlide(
      icon: Icons.people_outline,
      title: 'Find Verified Lawyers',
      description: 'Browse through verified lawyers with ratings, reviews, and expertise in your area',
      color: AppTheme.primaryBlue,
    ),
    OnboardingSlide(
      icon: Icons.calendar_today,
      title: 'Book Consultation Sessions',
      description: 'Schedule video consultations at your convenience with experienced legal professionals',
      color: AppTheme.darkBlue,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  return _buildSlide(_slides[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => _buildIndicator(index == _currentPage),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      if (_currentPage < _slides.length - 1)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: widget.onComplete,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppTheme.textSecondary),
                              foregroundColor: AppTheme.textSecondary,
                            ),
                            child: const Text('Skip'),
                          ),
                        ),
                      if (_currentPage < _slides.length - 1)
                        const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          child: Text(
                            _currentPage < _slides.length - 1 
                                ? 'Continue' 
                                : 'Get Started',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(OnboardingSlide slide) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: slide.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              slide.icon,
              size: 96,
              color: slide.color,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            slide.title,
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            slide.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 32 : 8,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryBlue : AppTheme.borderColor,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingSlide {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  OnboardingSlide({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
