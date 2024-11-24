import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'signup_page.dart';
import 'login_page.dart';

class WelcomePage extends StatefulWidget {
  static const String id = 'welcome_page';

  const WelcomePage({super.key});

  @override
  WelcomePageState createState() => WelcomePageState();
}

class WelcomePageState extends State<WelcomePage> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil for responsive font and size
    ScreenUtil.init(context, designSize: const Size(375, 812));

    return Scaffold(
      body: Stack(
        children: [
          // Enhanced background: diagonal gradient with subtle blur
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7F3DFF), Color(0xFFF2F2F9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.transparent),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    buildPage(
                      image: "assets/images/control.png",
                      title: "Effortless Expense Tracking", // Text updated - "Gain total control of your money"
                      subtitle:
                      "Snap a photo of your receipts, and let us handle the rest. Simplify your expense management like never before.", // Text updated -  "Become your own money manager and make every cent count",
                    ),
                    buildPage(
                      image: "assets/images/track.png",

                      title: "Turn Receipts into Insights", // Text updated - "Know where your money goes",
                      subtitle:
                      "Automatically categorize your spending and unlock detailed reports for smarter financial decisions.", // Text updated -  "Track your transactions easily with categories and reports",
                    ),
                    buildPage(
                      image: "assets/images/plan.png",
                      title: "Plan Ahead",
                      subtitle: "Set budgets for each category to stay in control.",
                    ),
                  ],
                ),
              ),
              // Smooth Page Indicator
              SmoothPageIndicator(
                controller: _pageController,
                count: 3,
                effect: ExpandingDotsEffect(
                  dotColor: const Color(0xFFE0E0E0),
                  activeDotColor: const Color(0xFF7F3DFF),
                  dotHeight: 10.h,
                  dotWidth: 10.w,
                  expansionFactor: 4,
                ),
              ),
              const SizedBox(height: 40), // Adjusted spacing
              // Enhanced buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7F3DFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28.0), // Smooth rounded corners
                        ),
                        shadowColor: Colors.black.withOpacity(0.15), // Subtle shadow
                        elevation: 8, // Elevated look
                        minimumSize: const Size.fromHeight(56), // Button height
                      ),
                      onPressed: () async {
                        await showLoadingDialog(context);
                        if (mounted) {
                          Navigator.pushNamed(context, SignUpPage.id); // Fixed navigation
                        }
                      },
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'SF Pro Rounded',
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF7F3DFF), width: 2), // Border styling
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28.0), // Smooth rounded corners
                        ),
                        minimumSize: const Size.fromHeight(56), // Button height
                      ),
                      onPressed: () async {
                        await showLoadingDialog(context);
                        if (mounted) {
                          Navigator.pushNamed(context, LogInPage.id); // Fixed navigation
                        }
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'SF Pro Rounded',
                          color: const Color(0xFF7F3DFF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50), // Adjusted bottom spacing
            ],
          ),
        ],
      ),
    );
  }

  Widget buildPage({
    required String image,
    required String title,
    required String subtitle,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start, // Adjusted alignment
      children: [
        const SizedBox(height: 80), // Add more spacing at the top
        Image.asset(
          image,
          fit: BoxFit.contain,
          height: 240.h, // Increased image height
        ),
        const SizedBox(height: 30), // Add spacing between image and text
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'SF Pro Rounded', // Modern Apple-like font
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: [Color(0xFF7F3DFF), Color(0xFFB84DFF)],
              ).createShader(const Rect.fromLTWH(0, 0, 200, 70)), // Gradient text
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF616161),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  // Updated loading dialog with Future handling
  Future<void> showLoadingDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    await Future.delayed(const Duration(seconds: 1)); // Simulate loading delay
    Navigator.pop(context); // Close dialog
  }
}
