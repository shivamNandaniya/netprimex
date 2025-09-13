import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:movie_splash/app_name.dart';
import 'package:movie_splash/download_apk_helper.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:js_interop' as html;

class NetPrimeHome extends StatefulWidget {
  const NetPrimeHome({super.key});

  @override
  State<NetPrimeHome> createState() => _NetPrimeHomeState();
}

class _NetPrimeHomeState extends State<NetPrimeHome>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _backgroundController;
  late AnimationController _categoryController;
  late Animation<double> _logoAnimation;
  late Animation<Color?> _backgroundAnimation;
  late Animation<double> _categoryAnimation;

  final CarouselSliderController _carouselController =
  CarouselSliderController();
  int _currentCarouselIndex = 0;
  bool _isLoading = true;
  String _selectedCategory = 'latest'; // Changed to match Firebase structure

  // Complete movie data with categories
  final Map<String, List<MoviePoster>> _moviesByCategory = {};

  List<MoviePoster> get _currentMovies =>
      _moviesByCategory[_selectedCategory] ?? [];

  @override
  void initState() {
    super.initState();
    _getCategory();
    _setupAnimations();
    _simulateLoading();
  }

  List categories = [];
  bool _isCategoryLoading = false;

  Future<void> _getCategory() async {
    setState(() {
      _isCategoryLoading = true;
    });

    try {
      final res = await FirebaseFirestore.instance
          .collection('web')
          .doc("category")
          .get();

      if (res.exists && res.data() != null) {
        categories = res.data()!['category'];
        print("Categories loaded: $categories");

        // Use Future.wait to properly handle async operations
        await Future.wait(
            categories.map((category) => _loadMoviesForCategory(category))
        );

        // Set the first category as selected if available
        if (categories.isNotEmpty) {
          _selectedCategory = categories.first;
        }
      }
    } catch (e) {
      print("Error loading categories: $e");
    } finally {
      setState(() {
        _isCategoryLoading = false;
      });
    }
  }

  Future<void> _loadMoviesForCategory(String category) async {
    try {
      print("Loading movies for category: $category");

      // Try fetching from collection first (like 'latest' collection)
      final collectionRes = await FirebaseFirestore.instance
          .collection(category)
          .get();

      if (collectionRes.docs.isNotEmpty) {
        // If collection exists and has documents
        final movies = collectionRes.docs.map((doc) {
          final data = doc.data();
          return MoviePoster(
            title: data['name'] ?? 'Unknown Title',
            genre: data['description'] ?? 'Unknown Genre',
            rating: data['rating'] ?? '0.0',
            imageUrl: data['img'] ?? '',
          );
        }).toList();

        _moviesByCategory[category] = movies;
        print("Loaded ${movies.length} movies from collection '$category'");
      } else {
        // Fallback: Try fetching from web/{category} document
        final docRes = await FirebaseFirestore.instance
            .collection('web')
            .doc(category)
            .get();

        if (docRes.exists && docRes.data() != null) {
          final movieData = docRes.data()!['movie'];
          if (movieData != null && movieData is List) {
            final movies = movieData.map<MoviePoster>((e) {
              return MoviePoster(
                title: e['name'] ?? 'Unknown Title',
                genre: e['description'] ?? 'Unknown Genre',
                rating: e['rating'] ?? '0.0',
                imageUrl: e['img'] ?? '',
              );
            }).toList();

            _moviesByCategory[category] = movies;
            print("Loaded ${movies.length} movies from document 'web/$category'");
          }
        }
      }
    } catch (e) {
      print("Error loading movies for category '$category': $e");
      _moviesByCategory[category] = []; // Set empty list on error
    }
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

    _categoryController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _backgroundAnimation =
        ColorTween(
          begin: const Color(0xFF0D0D0D),
          end: const Color(0xFF1A1A2E),
        ).animate(
          CurvedAnimation(
            parent: _backgroundController,
            curve: Curves.easeInOut,
          ),
        );

    _categoryAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _categoryController, curve: Curves.easeInOut),
    );

    _logoController.forward();
    _backgroundController.repeat(reverse: true);
    _categoryController.forward();
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

  void _changeCategory(String category) {
    if (_selectedCategory != category) {
      _categoryController.reset();
      setState(() {
        _selectedCategory = category;
        _currentCarouselIndex = 0;
      });
      _categoryController.forward();
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _backgroundController.dispose();
    _categoryController.dispose();
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
                      colors: [Color(0xFF2979FF), Color(0xFF1976D2)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2979FF).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Image.asset('assets/logo.png', height: 60, width: 60),
                ),
              );
            },
          ),
          const SizedBox(height: 30),
          AppNameText(fontSize: 48),
          const SizedBox(height: 10),
          const Text(
            'Endless Entertainment — Cinematic Hits & Quick Reels',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isDesktop = screenWidth > 800;
        final isTablet = screenWidth > 600 && screenWidth <= 800;
        final isMobile = screenWidth <= 600;
        final isSmallMobile = screenWidth <= 360;

        return Column(
          children: [
            // Fixed Header
            _buildFixedHeader(isDesktop, isTablet, isMobile, isSmallMobile),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeroSection(
                      isDesktop,
                      isTablet,
                      isMobile,
                      isSmallMobile,
                    ),
                    _buildMovieCarousel(
                      isDesktop,
                      isTablet,
                      isMobile,
                      isSmallMobile,
                    ),
                    _buildFAQSection(
                      isDesktop,
                      isTablet,
                      isMobile,
                      isSmallMobile,
                    ),
                    _buildSocialSection(
                      isDesktop,
                      isTablet,
                      isMobile,
                      isSmallMobile,
                    ),
                    SizedBox(
                      height: isSmallMobile
                          ? 80
                          : isMobile
                          ? 90
                          : 20,
                    ),
                  ],
                ),
              ),
            ),

            _buildFixedBottomSection(
              isDesktop,
              isTablet,
              isMobile,
              isSmallMobile,
            ),
          ],
        );
      },
    );
  }

  Widget _buildFixedHeader(
      bool isDesktop,
      bool isTablet,
      bool isMobile,
      bool isSmallMobile,
      ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop
            ? 80
            : isTablet
            ? 40
            : isSmallMobile
            ? 12
            : 20,
        vertical: isSmallMobile ? 12 : 20,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D).withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AnimationLimiter(
        child: AnimationConfiguration.staggeredList(
          position: 0,
          duration: const Duration(milliseconds: 800),
          child: SlideAnimation(
            verticalOffset: -50.0,
            child: FadeInAnimation(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 2,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(isSmallMobile ? 6 : 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2979FF), Color(0xFF1976D2)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.asset(
                            'assets/logo.png',
                            height: isSmallMobile ? 16 : 24,
                            width: isSmallMobile ? 16 : 24,
                          ),
                        ),
                        SizedBox(width: isSmallMobile ? 8 : 12),
                        Flexible(
                          child: AppNameText(fontSize: isSmallMobile ? 18 : 24),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '100,000+',
                          style: TextStyle(
                            fontSize: isSmallMobile
                                ? 12
                                : isDesktop
                                ? 20
                                : 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2979FF),
                          ),
                        ),
                        Text(
                          'Movies FREE!',
                          style: TextStyle(
                            fontSize: isSmallMobile
                                ? 10
                                : isDesktop
                                ? 16
                                : 14,
                            color: const Color(0xFF2979FF),
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

  Widget _buildHeroSection(
      bool isDesktop,
      bool isTablet,
      bool isMobile,
      bool isSmallMobile,
      ) {
    return Container(
      height: isDesktop
          ? 300
          : isTablet
          ? 250
          : isSmallMobile
          ? 150
          : 200,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop
            ? 80
            : isTablet
            ? 40
            : isSmallMobile
            ? 12
            : 20,
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
                  child: AppNameText(
                    fontSize: isSmallMobile
                        ? 32
                        : isDesktop
                        ? 80
                        : 48,
                  ),
                ),
              ),
            ),
            SizedBox(height: isSmallMobile ? 10 : 20),
            AnimationConfiguration.staggeredList(
              position: 1,
              duration: const Duration(milliseconds: 1200),
              child: SlideAnimation(
                verticalOffset: 100.0,
                child: FadeInAnimation(
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'Endless Entertainment — Cinematic Hits & Quick Reels',
                        textAlign: TextAlign.center,
                        textStyle: TextStyle(
                          fontSize: isSmallMobile
                              ? 14
                              : isDesktop
                              ? 28
                              : 20,
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

  Widget _buildMovieCarousel(
      bool isDesktop,
      bool isTablet,
      bool isMobile,
      bool isSmallMobile,
      ) {
    return Container(
      height: isDesktop
          ? 600
          : isTablet
          ? 500
          : isSmallMobile
          ? 350
          : 400,
      margin: EdgeInsets.symmetric(vertical: isSmallMobile ? 20 : 40),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop
                  ? 80
                  : isTablet
                  ? 40
                  : isSmallMobile
                  ? 12
                  : 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Movies',
                  style: TextStyle(
                    fontSize: isSmallMobile
                        ? 18
                        : isDesktop
                        ? 28
                        : 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: isSmallMobile ? 12 : 20),
                _buildGenreChips(isSmallMobile, isMobile, isTablet, isDesktop),
              ],
            ),
          ),
          SizedBox(height: isSmallMobile ? 20 : 30),
          Expanded(
            child: AnimatedBuilder(
              animation: _categoryAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.8 + (_categoryAnimation.value * 0.2),
                  child: Opacity(
                    opacity: _categoryAnimation.value,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double aspectRatio = 2 / 3;
                        final double itemWidth = constraints.maxHeight * aspectRatio;
                        final double viewportFraction = itemWidth / constraints.maxWidth;

                        if (_currentMovies.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.movie_outlined,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No movies found for $_selectedCategory',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        }

                        return CarouselSlider(
                          key: ValueKey(_selectedCategory),
                          carouselController: _carouselController,
                          options: CarouselOptions(
                            height: double.infinity,
                            viewportFraction: viewportFraction,
                            enableInfiniteScroll: true,
                            autoPlay: true,
                            autoPlayInterval: const Duration(seconds: 3),
                            autoPlayAnimationDuration: const Duration(
                              milliseconds: 800,
                            ),
                            autoPlayCurve: Curves.fastOutSlowIn,
                            enlargeCenterPage: true,
                            enlargeFactor: 0.2,
                            onPageChanged: (index, reason) {
                              setState(() {
                                _currentCarouselIndex = index;
                              });
                            },
                          ),
                          items: _currentMovies.map((movie) {
                            return _buildMoviePosterCard(
                              movie,
                              isDesktop,
                              isTablet,
                              isMobile,
                              isSmallMobile,
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: isSmallMobile ? 15 : 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _currentMovies.asMap().entries.map((entry) {
              return Container(
                width: isSmallMobile ? 6.0 : 8.0,
                height: isSmallMobile ? 6.0 : 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 3.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentCarouselIndex == entry.key
                      ? const Color(0xFF2979FF)
                      : Colors.grey[600],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreChips(
      bool isSmallMobile,
      bool isMobile,
      bool isTablet,
      bool isDesktop,
      ) {
    if (_isCategoryLoading) {
      return CircularProgressIndicator();
    }

    final genres = categories;
    return Wrap(
      spacing: isSmallMobile ? 6 : 10,
      runSpacing: isSmallMobile ? 6 : 10,
      children: genres.map((genre) {
        final isActive = genre == _selectedCategory;
        return _buildHoverButton(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: EdgeInsets.symmetric(
              horizontal: isSmallMobile ? 12 : 18,
              vertical: isSmallMobile ? 8 : 12,
            ),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF2979FF) : Colors.transparent,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isActive ? const Color(0xFF2979FF) : Colors.grey[600]!,
                width: 2,
              ),
              boxShadow: isActive
                  ? [
                BoxShadow(
                  color: const Color(0xFF2979FF).withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ]
                  : null,
            ),
            child: Text(
              genre,
              style: TextStyle(
                fontSize: isSmallMobile
                    ? 11
                    : isMobile
                    ? 13
                    : 15,
                color: isActive ? Colors.white : Colors.grey[300],
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
          onTap: () => _changeCategory(genre),
          hoverScale: 1.05,
        );
      }).toList(),
    );
  }

  Widget _buildMoviePosterCard(
      MoviePoster movie,
      bool isDesktop,
      bool isTablet,
      bool isMobile,
      bool isSmallMobile,
      ) {
    return AnimationConfiguration.staggeredList(
      position: 0,
      duration: const Duration(milliseconds: 1000),
      child: ScaleAnimation(
        scale: 0.8,
        child: FadeInAnimation(
          child: _buildHoverButton(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: isSmallMobile ? 4 : 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    blurRadius: 20,
                    spreadRadius: 3,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.grey[800]!, Colors.grey[900]!],
                        ),
                      ),
                      child: Image.network(
                        movie.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.grey[800]!, Colors.grey[900]!],
                              ),
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: const Color(0xFF2979FF),
                                strokeWidth: isSmallMobile ? 2 : 3,
                                value:
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.grey[800]!, Colors.grey[900]!],
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.movie_outlined,
                                size: isSmallMobile ? 40 : 60,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: isSmallMobile ? 10 : 16,
                      left: isSmallMobile ? 10 : 16,
                      right: isSmallMobile ? 10 : 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            movie.title,
                            style: TextStyle(
                              fontSize: isSmallMobile
                                  ? 12
                                  : isDesktop
                                  ? 16
                                  : 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.8),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: isSmallMobile ? 4 : 6),
                          Text(
                            '${movie.genre}',
                            style: TextStyle(
                              fontSize: isSmallMobile
                                  ? 9
                                  : isDesktop
                                  ? 12
                                  : 10,
                              color: Colors.grey[300],
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.8),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: isSmallMobile ? 10 : 12,
                      right: isSmallMobile ? 10 : 12,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallMobile ? 6 : 10,
                          vertical: isSmallMobile ? 4 : 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.amber.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: isSmallMobile ? 10 : 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              movie.rating.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallMobile ? 9 : 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              print('Movie ${movie.title} tapped!');
            },
            hoverScale: 1.05,
          ),
        ),
      ),
    );
  }

  Widget _buildFAQSection(
      bool isDesktop,
      bool isTablet,
      bool isMobile,
      bool isSmallMobile,
      ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop
            ? 80
            : isTablet
            ? 40
            : isSmallMobile
            ? 12
            : 20,
        vertical: isSmallMobile ? 20 : 40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FAQ',
            style: TextStyle(
              fontSize: isSmallMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isSmallMobile ? 15 : 30),
          _buildFAQItem(
            '1. How to download NetPrimeX app on Google Play?',
            'Due to the policy of Google, NetPrimeX don\'t publish in Google Play. NetPrimeX is safe and you can download NetPrimeX on Our Official Website.',
            isSmallMobile,
            isMobile,
            isTablet,
            isDesktop,
          ),
          SizedBox(height: isSmallMobile ? 10 : 20),
          _buildFAQItem(
            '2. How to Install NetPrimeX on iPhone, iPad or PC?',
            'NetPrimeX do not publish iOS or Windows version.',
            isSmallMobile,
            isMobile,
            isTablet,
            isDesktop,
          ),
          SizedBox(height: isSmallMobile ? 10 : 20),
          _buildFAQItem(
            '3. What is NetPrimeX?',
            'NetPrimeX is quite possibly, the most popular Indian movie streaming app for Android. It is used by millions of users in India to stream the latest Trending Movies, Hot Music, Videos and TV shows - usually to an Android device, but it also works on other platforms.',
            isSmallMobile,
            isMobile,
            isTablet,
            isDesktop,
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(
      String question,
      String answer,
      bool isSmallMobile,
      bool isMobile,
      bool isTablet,
      bool isDesktop,
      ) {
    return AnimationConfiguration.staggeredList(
      position: 0,
      duration: const Duration(milliseconds: 800),
      child: SlideAnimation(
        horizontalOffset: 100.0,
        child: FadeInAnimation(
          child: _buildHoverButton(
            child: Container(
              padding: EdgeInsets.all(isSmallMobile ? 12 : 20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey[700]!, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question,
                    style: TextStyle(
                      fontSize: isSmallMobile
                          ? 12
                          : isDesktop
                          ? 18
                          : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: isSmallMobile ? 6 : 10),
                  Text(
                    answer,
                    style: TextStyle(
                      fontSize: isSmallMobile
                          ? 10
                          : isDesktop
                          ? 16
                          : 14,
                      color: Colors.grey[300],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              print('FAQ item tapped: $question');
            },
            hoverScale: 1.02,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialSection(
      bool isDesktop,
      bool isTablet,
      bool isMobile,
      bool isSmallMobile,
      ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop
            ? 80
            : isTablet
            ? 40
            : isSmallMobile
            ? 12
            : 20,
        vertical: isSmallMobile ? 20 : 40,
      ),
      child: Column(
        children: [
          Text(
            'If you can\'t download normally',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmallMobile ? 14 : 18,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isSmallMobile ? 6 : 10),
          Text(
            'Join the group to get the latest download link',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmallMobile ? 12 : 16,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: isSmallMobile ? 20 : 30),
          Wrap(
            spacing: isSmallMobile ? 15 : 25,
            runSpacing: isSmallMobile ? 15 : 20,
            alignment: WrapAlignment.center,
            children: [
              _buildSocialButton(
                'Instagram',
                "assets/instagram.png",
                isSmallMobile,
                isMobile,
                isTablet,
                isDesktop,
                true,
              ),
              _buildSocialButton(
                'Telegram',
                "assets/telegram.png",
                isSmallMobile,
                isMobile,
                isTablet,
                isDesktop,
                false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(
      String title,
      String img,
      bool isSmallMobile,
      bool isMobile,
      bool isTablet,
      bool isDesktop,
      bool isInsta,
      ) {
    return AnimationConfiguration.staggeredList(
      position: 0,
      duration: const Duration(milliseconds: 600),
      child: ScaleAnimation(
        scale: 0.8,
        child: FadeInAnimation(
          child: _buildHoverButton(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallMobile
                    ? 16
                    : isDesktop
                    ? 40
                    : 24,
                vertical: isSmallMobile
                    ? 6
                    : isDesktop
                    ? 10
                    : 8,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Color(0xff2979ff), width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    img,
                    height:
                    (isSmallMobile
                        ? 16
                        : isDesktop
                        ? 24
                        : 20) *
                        2,
                    width:
                    (isSmallMobile
                        ? 16
                        : isDesktop
                        ? 24
                        : 20) *
                        2,
                  ),
                  SizedBox(width: isSmallMobile ? 6 : 10),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallMobile
                          ? 12
                          : isDesktop
                          ? 16
                          : 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              if (isInsta) {
                launchInstagram();
              } else {
                launchTelegram();
              }
            },
            hoverScale: 1.1,
          ),
        ),
      ),
    );
  }

  Widget _buildFixedBottomSection(
      bool isDesktop,
      bool isTablet,
      bool isMobile,
      bool isSmallMobile,
      ) {
    return Container(
      padding: EdgeInsets.all(
        isSmallMobile
            ? 8
            : isDesktop
            ? 15
            : 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D).withOpacity(0.95),
        border: Border(top: BorderSide(color: Colors.grey[800]!, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          constraints: BoxConstraints(
            minHeight: isDesktop
                ? 70
                : isTablet
                ? 60
                : isSmallMobile
                ? 50
                : 55,
            maxHeight: isDesktop
                ? 90
                : isTablet
                ? 80
                : isSmallMobile
                ? 70
                : 75,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isSmallMobile ? 12 : 20,
            vertical: isSmallMobile ? 10 : 15,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(isSmallMobile ? 15 : 20),
            border: Border.all(color: const Color(0xFF2979FF).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isSmallMobile ? 8 : 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2979FF), Color(0xFF1976D2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Image.asset(
                  'assets/logo.png',
                  height: isSmallMobile ? 16 : 22,
                  width: isSmallMobile ? 16 : 22,
                ),
              ),

              SizedBox(width: isSmallMobile ? 12 : 18),

              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          Text(
                            'Get start with ',
                            style: TextStyle(
                              fontSize: isSmallMobile
                                  ? 12
                                  : isDesktop
                                  ? 16
                                  : 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          AppNameText(
                            fontSize: isSmallMobile
                                ? 12
                                : isDesktop
                                ? 16
                                : 14,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Flexible(
                      child: Text(
                        'Movie & Stream',
                        style: TextStyle(
                          fontSize: isSmallMobile
                              ? 9
                              : isDesktop
                              ? 12
                              : 11,
                          color: Colors.grey[400],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              Spacer(),

              _buildHoverButton(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallMobile
                        ? 16
                        : isDesktop
                        ? 28
                        : 24,
                    vertical: isSmallMobile
                        ? 10
                        : isDesktop
                        ? 16
                        : 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF2979FF),
                        Color(0xFF1E88E5),
                        Color(0xFF1976D2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2979FF).withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.download_rounded,
                        color: Colors.white,
                        size: isSmallMobile
                            ? 14
                            : isDesktop
                            ? 18
                            : 16,
                      ),
                      SizedBox(width: isSmallMobile ? 4 : 8),
                      Flexible(
                        child: Text(
                          'Download',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallMobile
                                ? 12
                                : isDesktop
                                ? 15
                                : 14,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () async {
                  await downloadFileFromUrl("assets/app.apk", "movie");
                },
                hoverScale: 1.05,
                hoverShadowColor: const Color(0xFF2979FF),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHoverButton({
    required Widget child,
    required VoidCallback onTap,
    double hoverScale = 1.05,
    Color? hoverShadowColor,
  }) {
    return _HoverButton(
      child: child,
      onTap: onTap,
      hoverScale: hoverScale,
      hoverShadowColor: hoverShadowColor,
    );
  }
}

class _HoverButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double hoverScale;
  final Color? hoverShadowColor;

  const _HoverButton({
    required this.child,
    required this.onTap,
    this.hoverScale = 1.05,
    this.hoverShadowColor,
  });

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.hoverScale,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
        _controller.forward();
        if (!kIsWeb) {
          HapticFeedback.lightImpact();
        }
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
        _controller.reverse();
      },
      child: GestureDetector(
        onTap: () {
          if (!kIsWeb) {
            HapticFeedback.mediumImpact();
          }
          widget.onTap();
        },
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  boxShadow: _isHovered && widget.hoverShadowColor != null
                      ? [
                    BoxShadow(
                      color: widget.hoverShadowColor!.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 4,
                      offset: const Offset(0, 8),
                    ),
                  ]
                      : _isHovered
                      ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 3,
                      offset: const Offset(0, 5),
                    ),
                  ]
                      : null,
                ),
                child: widget.child,
              ),
            );
          },
        ),
      ),
    );
  }
}

class MoviePoster {
  final String title;
  final String genre;
  final String rating;
  final String imageUrl;

  MoviePoster({
    required this.title,
    required this.genre,
    required this.rating,
    required this.imageUrl,
  });
}
