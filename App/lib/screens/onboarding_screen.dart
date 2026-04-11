import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finishOnboarding() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool('has_onboarded', true);
    // Setting the provider state will immediately trigger the router redirect to /pair!
    ref.read(onboardingProvider.notifier).state = true;
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF20B2AA);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button at the top
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finishOnboarding,
                child: Text(
                  'SKIP',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // Swipeable Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (idx) {
                  setState(() => _currentPage = idx);
                },
                children: [
                  _buildPage(
                    icon: Icons.auto_awesome,
                    iconColor: Colors.blueAccent,
                    title: 'Welcome to CodeTwin',
                    description:
                        'The autonomous AI pair programmer living right in your pocket. Control, monitor, and guide your desktop IDE agent natively from anywhere.',
                  ),
                  _buildPage(
                    icon: Icons.terminal,
                    iconColor: Colors.purpleAccent,
                    title: 'Bridge The Gap',
                    description:
                        'No more heavy desktop GUIs. Run the CodeTwin CLI daemon directly inside your editor and instantly beam the session straight to this app over secure sockets.',
                  ),
                  _buildPage(
                    icon: Icons.qr_code_scanner,
                    iconColor: primaryColor,
                    title: 'Ready To Connect?',
                    description:
                        'Open your project terminal, type `codetwin start`, and scan the securely generated QR code to link your device instantly.',
                    isLast: true,
                    primaryColor: primaryColor,
                  ),
                ],
              ),
            ),

            // Pagination Dots
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 6,
                    width: _currentPage == index ? 24 : 6,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? primaryColor
                          : Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    bool isLast = false,
    Color? primaryColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with glow
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withValues(alpha: 0.1),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withValues(alpha: 0.2),
                  blurRadius: 30,
                  spreadRadius: 10,
                )
              ],
            ),
            child: Icon(icon, size: 64, color: iconColor),
          ),
          const SizedBox(height: 48),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),

          const SizedBox(height: 64),

          // Big Connect Button at the end!
          if (isLast && primaryColor != null)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _finishOnboarding,
                style: FilledButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'SCAN QR CODE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
