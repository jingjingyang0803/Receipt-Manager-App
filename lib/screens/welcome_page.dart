import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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
          // Enhanced background: diagonal gradient with shadow
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7F3DFF), Color(0xFFF2F2F9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
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
                      title: "Effortless Expense Tracking",
                      subtitle:
                      "Snap a photo of your receipts, and let us handle the rest. Simplify your expense management like never before.",
                    ),
                    buildPage(
                      image: "assets/images/track.png",
                      title: "Turn Receipts into Insights",
                      subtitle:
                      "Automatically categorize your spending and unlock detailed reports for smarter financial decisions.",
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
              const SizedBox(height: 24),
              // Enhanced buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7F3DFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        shadowColor: Colors.black.withOpacity(0.2),
                        elevation: 10,
                        minimumSize: const Size.fromHeight(56),
                      ),
                      onPressed: () async {
                        await showLoadingDialog(context);
                        if (mounted) {
                          Navigator.pushNamed(context, 'signup_page'); // Ensure navigation
                        }
                      },
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF7F3DFF)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        minimumSize: const Size.fromHeight(56),
                      ),
                      onPressed: () async {
                        await showLoadingDialog(context);
                        if (mounted) {
                          Navigator.pushNamed(context, 'login_page'); // Ensure navigation
                        }
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF7F3DFF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Image.asset(
              image,
              fit: BoxFit.contain,
              height: 220.h,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF212325),
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
        const SizedBox(height: 32),
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
