import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:async';

class NetPrimeHome extends StatefulWidget {
  const NetPrimeHome({super.key});

  @override
  State<NetPrimeHome> createState() => _NetPrimeHomeState();
}

class _NetPrimeHomeState extends State<NetPrimeHome>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _backgroundController;
  late Animation<double> _logoAnimation;
  late Animation<Color?> _backgroundAnimation;

  final CarouselSliderController _carouselController = CarouselSliderController();
  int _currentCarouselIndex = 0;
  bool _isLoading = true;

  final List<MovieData> _featuredMovies = [
    MovieData(
      title: "Legends",
      category: "Action • Adventure",
      rating: 4.8,
      year: "2024",
      image: "https://via.placeholder.com/400x600/FF4444/FFFFFF?text=LEGENDS",
    ),
    MovieData(
      title: "Mystery Island",
      category: "Thriller • Mystery",
      rating: 4.6,
      year: "2024",
      image: "https://via.placeholder.com/400x600/4444FF/FFFFFF?text=MYSTERY",
    ),
    MovieData(
      title: "Space Odyssey",
      category: "Sci-Fi • Drama",
      rating: 4.9,
      year: "2024",
      image: "https://via.placeholder.com/400x600/44FF44/FFFFFF?text=SPACE",
    ),
  ];

  final List<MovieGrid> _movieCategories = [
    MovieGrid(category: "Latest Movies", movies: [
      "https://via.placeholder.com/200x300/FF6B6B/FFFFFF?text=LATEST+1",
      "https://via.placeholder.com/200x300/4ECDC4/FFFFFF?text=LATEST+2",
      "https://via.placeholder.com/200x300/45B7D1/FFFFFF?text=LATEST+3",
      "https://via.placeholder.com/200x300/96CEB4/FFFFFF?text=LATEST+4",
      "https://via.placeholder.com/200x300/FFEAA7/FFFFFF?text=LATEST+5",
      "https://via.placeholder.com/200x300/DDA0DD/FFFFFF?text=LATEST+6",
    ]),
    MovieGrid(category: "Popular Series", movies: [
      "https://via.placeholder.com/200x300/FF7675/FFFFFF?text=SERIES+1",
      "https://via.placeholder.com/200x300/6C5CE7/FFFFFF?text=SERIES+2",
      "https://via.placeholder.com/200x300/A29BFE/FFFFFF?text=SERIES+3",
      "https://via.placeholder.com/200x300/FD79A8/FFFFFF?text=SERIES+4",
      "https://via.placeholder.com/200x300/00B894/FFFFFF?text=SERIES+5",
      "https://via.placeholder.com/200x300/E17055/FFFFFF?text=SERIES+6",
    ]),
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _simulateLoading();
  }

  void _setupAnimations() {
    _logoController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _backgroundAnimation = ColorTween(
      begin: const Color(0xFF0D0D0D),
      end: const Color(0xFF1A1A2E),
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));

    _logoController.forward();
    _backgroundController.repeat(reverse: true);
  }

  void _simulateLoading() {
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _backgroundAnimation.value ?? const Color(0xFF0D0D0D),
                  const Color(0xFF0D0D0D),
                ],
              ),
            ),
            child: _isLoading ? _buildLoadingScreen() : _buildMainContent(),
          );
        },
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _logoAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _logoAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 30),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: const Text(
              'NetPrime',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Your private cinema',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;
        final isMobile = constraints.maxWidth < 600;

        return SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(isDesktop, isMobile),
              _buildHeroSection(isDesktop, isMobile),
              _buildPhoneCarousel(isDesktop, isMobile),
              _buildDownloadSection(isDesktop, isMobile),
              _buildFAQSection(isDesktop, isMobile),
              _buildSocialSection(isDesktop, isMobile),
              _buildFooter(isDesktop, isMobile),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDesktop, bool isMobile) {
    return AnimationLimiter(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 80 : 20,
          vertical: 20,
        ),
        child: AnimationConfiguration.staggeredList(
          position: 0,
          duration: const Duration(milliseconds: 800),
          child: SlideAnimation(
            verticalOffset: -50.0,
            child: FadeInAnimation(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'NetPrime',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '100,000+',
                        style: TextStyle(
                          fontSize: isDesktop ? 20 : 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4ECDC4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Movies FREE!',
                        style: TextStyle(
                          fontSize: isDesktop ? 16 : 14,
                          color: const Color(0xFF4ECDC4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(bool isDesktop, bool isMobile) {
    return Container(
      height: isDesktop ? 500 : 350,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 20,
      ),
      child: AnimationLimiter(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimationConfiguration.staggeredList(
              position: 0,
              duration: const Duration(milliseconds: 1200),
              child: SlideAnimation(
                verticalOffset: 100.0,
                child: FadeInAnimation(
                  child: Text(
                    'NetPrime',
                    style: TextStyle(
                      fontSize: isDesktop ? 80 : 48,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
                        ).createShader(
                          const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                        ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            AnimationConfiguration.staggeredList(
              position: 1,
              duration: const Duration(milliseconds: 1200),
              child: SlideAnimation(
                verticalOffset: 100.0,
                child: FadeInAnimation(
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'Your private cinema',
                        textStyle: TextStyle(
                          fontSize: isDesktop ? 28 : 20,
                          color: Colors.grey[300],
                        ),
                        speed: const Duration(milliseconds: 100),
                      ),
                    ],
                    isRepeatingAnimation: true,
                    repeatForever: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneCarousel(bool isDesktop, bool isMobile) {
    return Container(
      height: isDesktop ? 600 : 400,
      margin: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Expanded(
            child: CarouselSlider(
              carouselController: _carouselController,
              options: CarouselOptions(
                height: double.infinity,
                viewportFraction: isDesktop ? 0.4 : 0.8,
                enableInfiniteScroll: true,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 4),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: true,
                enlargeFactor: 0.3,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentCarouselIndex = index;
                  });
                },
              ),
              items: [
                _buildPhoneFrame(isDesktop, isMobile, 0),
                _buildPhoneFrame(isDesktop, isMobile, 1),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [0, 1].map((index) {
              return Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentCarouselIndex == index
                      ? const Color(0xFF4ECDC4)
                      : Colors.grey[600],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneFrame(bool isDesktop, bool isMobile, int phoneType) {
    return AnimationConfiguration.staggeredList(
      position: phoneType,
      duration: const Duration(milliseconds: 1000),
      child: ScaleAnimation(
        scale: 0.8,
        child: FadeInAnimation(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey[900]!,
                  Colors.grey[800]!,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4ECDC4).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D0D0D),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: phoneType == 0
                      ? _buildPhoneContent1(isMobile)
                      : _buildPhoneContent2(isMobile),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneContent1(bool isMobile) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Status bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '9:41',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 12 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.signal_cellular_4_bar,
                        color: Colors.white, size: isMobile ? 12 : 14),
                    const SizedBox(width: 4),
                    Icon(Icons.wifi,
                        color: Colors.white, size: isMobile ? 12 : 14),
                    const SizedBox(width: 4),
                    Icon(Icons.battery_full,
                        color: Colors.white, size: isMobile ? 12 : 14),
                  ],
                ),
              ],
            ),
          ),

          // App header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: isMobile ? 16 : 20,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'NetPrime',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Featured movie card
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFFF6B6B).withOpacity(0.8),
                    const Color(0xFF4ECDC4).withOpacity(0.8),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Legends',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 18 : 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Action • 2024',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: isMobile ? 12 : 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: const Color(0xFFFF6B6B),
                        size: isMobile ? 20 : 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Movie grid
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Latest Movies',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.grey[800]!,
                              Colors.grey[700]!,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.movie_outlined,
                            color: Colors.grey[400],
                            size: isMobile ? 16 : 20,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneContent2(bool isMobile) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Status bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '9:41',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 12 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.signal_cellular_4_bar,
                        color: Colors.white, size: isMobile ? 12 : 14),
                    const SizedBox(width: 4),
                    Icon(Icons.wifi,
                        color: Colors.white, size: isMobile ? 12 : 14),
                    const SizedBox(width: 4),
                    Icon(Icons.battery_full,
                        color: Colors.white, size: isMobile ? 12 : 14),
                  ],
                ),
              ],
            ),
          ),

          // Categories
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCategoryButton('🎭', 'Drama', isMobile),
                    _buildCategoryButton('🔥', 'Action', isMobile),
                    _buildCategoryButton('😂', 'Comedy', isMobile),
                  ],
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      final colors = [
                        [const Color(0xFFE74C3C), const Color(0xFFC0392B)],
                        [const Color(0xFF9B59B6), const Color(0xFF8E44AD)],
                        [const Color(0xFF3498DB), const Color(0xFF2980B9)],
                        [const Color(0xFF1ABC9C), const Color(0xFF16A085)],
                      ];

                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: colors[index % colors.length],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: colors[index % colors.length][0].withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '4.${8 + index}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isMobile ? 10 : 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              left: 8,
                              right: 8,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Movie ${index + 1}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isMobile ? 12 : 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '2024 • Action',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: isMobile ? 10 : 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String emoji, String title, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF4ECDC4).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: TextStyle(fontSize: isMobile ? 12 : 14),
          ),
          const SizedBox(width: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 10 : 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadSection(bool isDesktop, bool isMobile) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 40),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 20,
      ),
      child: AnimationConfiguration.staggeredList(
        position: 2,
        duration: const Duration(milliseconds: 1000),
        child: SlideAnimation(
          verticalOffset: 100.0,
          child: FadeInAnimation(
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFFF6B6B).withOpacity(0.8),
                    const Color(0xFF4ECDC4).withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4ECDC4).withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.download_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Download APP',
                          style: TextStyle(
                            fontSize: isDesktop ? 20 : 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0D0D0D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAQSection(bool isDesktop, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 20,
        vertical: 40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FAQ',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 30),
          _buildFAQItem(
            '1. How to download NetPrime app on Google Play?',
            'Due to the policy of Google, NetPrime don\'t publish in Google Play. NetPrime is safe and you can download NetPrime on Our Official Website.',
            isDesktop,
          ),
          const SizedBox(height: 20),
          _buildFAQItem(
            '2. How to Install NetPrime on iPhone, iPad or PC?',
            'NetPrime do not publish iOS or Windows version.',
            isDesktop,
          ),
          const SizedBox(height: 20),
          _buildFAQItem(
            '3. What is NetPrime?',
            'NetPrime is quite possibly, the most popular Indian movie streaming app for Android. It is used by millions of users in India to stream the latest Trending Movies, Hot Music, Videos and TV shows - usually to an Android device, but it also works on other platforms.',
            isDesktop,
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer, bool isDesktop) {
    return AnimationConfiguration.staggeredList(
      position: 0,
      duration: const Duration(milliseconds: 800),
      child: SlideAnimation(
        horizontalOffset: 100.0,
        child: FadeInAnimation(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.grey[700]!,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question,
                  style: TextStyle(
                    fontSize: isDesktop ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  answer,
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : 14,
                    color: Colors.grey[300],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialSection(bool isDesktop, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 20,
        vertical: 40,
      ),
      child: Column(
        children: [
          const Text(
            'If you can\'t download normally',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Join the group to get the latest download link',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialButton(
                'WhatsApp',
                Colors.green,
                Icons.chat,
                isDesktop,
              ),
              const SizedBox(width: 20),
              _buildSocialButton(
                'Telegram',
                const Color(0xFF0088CC),
                Icons.send,
                isDesktop,
              ),
            ],
          ),
          const SizedBox(height: 40),
          _buildGetStartedSection(isDesktop, isMobile),
        ],
      ),
    );
  }

  Widget _buildSocialButton(
      String title,
      Color color,
      IconData icon,
      bool isDesktop,
      ) {
    return AnimationConfiguration.staggeredList(
      position: 0,
      duration: const Duration(milliseconds: 600),
      child: ScaleAnimation(
        scale: 0.8,
        child: FadeInAnimation(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 30 : 20,
              vertical: 15,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: isDesktop ? 24 : 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 16 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGetStartedSection(bool isDesktop, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF4ECDC4).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Get start with NetPrime',
                  style: TextStyle(
                    fontSize: isDesktop ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Movie & Stream',
                  style: TextStyle(
                    fontSize: isDesktop ? 14 : 12,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Download',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isDesktop, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0D0D0D),
            Colors.grey[900]!,
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            'NetPrime - Your Private Cinema',
            style: TextStyle(
              fontSize: isDesktop ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '© 2025 NetPrime. All rights reserved.',
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}

class MovieData {
  final String title;
  final String category;
  final double rating;
  final String year;
  final String image;

  MovieData({
    required this.title,
    required this.category,
    required this.rating,
    required this.year,
    required this.image,
  });
}

class MovieGrid {
  final String category;
  final List<String> movies;

  MovieGrid({
    required this.category,
    required this.movies,
  });
}




