import 'package:flutter/material.dart';
import 'login.dart';
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      illustration: 'assets/Frame.png',
      title: 'Now reading books\nwill be easier',
      description: 'Discover new worlds, join a vibrant\nreading community. Start your reading\nadventure effortlessly with us.',
      buttonText: 'Continue',
    ),
    OnboardingData(
      illustration: 'assets/Frame (1).png',
      title: 'Your Bookish Soulmate\nAwaits',
      description: 'Let us be your guide to the perfect read.\nDiscover books tailored to your tastes\nfor a truly rewarding experience.',
      buttonText: 'Continue',
    ),
    OnboardingData(
      illustration: 'assets/Frame (2).png',
      title: 'Start Your Adventure',
      description: 'Ready to embark on a quest for\ninspiration and knowledge? Your\nadventure begins now. Let\'s go!',
      buttonText: 'Get Started',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
   
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: TextButton(
                  onPressed: _nextPage,
                  
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return OnboardingPage(data: _pages[index]);
                },
              ),
            ),
            
            
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    width: _currentPage == index ? 12.0 : 8.0,
                    height: 8.0,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? const Color(0xFF6B46C1)
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                ),
              ),
            ),
            
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B46C1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _pages[_currentPage].buttonText,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                 
TextButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Login(), 
      ),
    );
  },
  child: Text(
    'Sign in',
    style: TextStyle(
      fontSize: 13,
      color: const Color(0xFF6B46C1),
      fontWeight: FontWeight.w600,
    ),
  ),
),

                  
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const OnboardingPage({super.key, required this.data});

  @override

Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Illustration
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: Image.asset(
                    data.illustration,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height:15),

                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 10),
               
                Text(
                  data.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      );
    },
  );
}

}

class OnboardingData {
  final String illustration;
  final String title;
  final String description;
  final String buttonText;

  OnboardingData({
    required this.illustration,
    required this.title,
    required this.description,
    required this.buttonText,
  });
}