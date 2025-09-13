import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:movie_splash/app_name.dart';
import 'package:movie_splash/download_apk_helper.dart';
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
  late AnimationController _categoryController;
  late Animation<double> _logoAnimation;
  late Animation<double> _categoryAnimation;

  final CarouselSliderController _carouselController =
  CarouselSliderController();
  int _currentCarouselIndex = 0;
  bool _isLoading = true;
  String _selectedCategory = 'latest';

  final Map<String, List<MoviePoster>> _moviesByCategory = {};

  List<MoviePoster> get _currentMovies =>
      _moviesByCategory[_selectedCategory] ?? [];

  int _movieCount = 0;

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

        if (categories.isNotEmpty) {
          _selectedCategory = categories.first;
          _currentCarouselIndex = 0;
        }

        await Future.wait([
          getCount(),
          ...categories.map((category) => _loadMoviesForCategory(category)),
        ]);

        setState(() {});
      }
    } catch (e) {
      print("Error loading categories: $e");
    } finally {
      setState(() {
        _isCategoryLoading = false;
      });
    }
  }

  Future<void> getCount() async {
    final res = await FirebaseFirestore.instance
        .collection('web')
        .doc("movie_count")
        .get();
    _movieCount = res.data()!['count'];
  }

  Future<void> _loadMoviesForCategory(String category) async {
    try {
      print("Loading movies for category: $category");

      final collectionRes = await FirebaseFirestore.instance
          .collection(category)
          .get();

      if (collectionRes.docs.isNotEmpty) {
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
            print(
              "Loaded ${movies.length} movies from document 'web/$category'",
            );
          }
        }
      }
    } catch (e) {
      print("Error loading movies for category '$category': $e");
      _moviesByCategory[category] = [];
    }
  }

  void _setupAnimations() {
    _logoController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _categoryController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _categoryAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _categoryController, curve: Curves.easeInOut),
    );

    _logoController.forward();
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
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: _isLoading ? _buildLoadingScreen() : _buildMainContent(),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isUltraSmallMobile = screenWidth <= 280;
        final isSmallMobile = screenWidth <= 360;
        final isMobile = screenWidth <= 600;
        final isTablet = screenWidth > 600 && screenWidth <= 800;
        final isDesktop = screenWidth > 800;

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
                      padding: EdgeInsets.all(
                        isUltraSmallMobile ? 12 :
                        isSmallMobile ? 15 :
                        isMobile ? 18 :
                        isTablet ? 22 :
                        25, // Desktop
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2979FF), Color(0xFF1976D2)],
                        ),
                        borderRadius: BorderRadius.circular(
                          isUltraSmallMobile ? 12 :
                          isSmallMobile ? 15 :
                          isMobile ? 18 :
                          20, // Desktop & Tablet
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2979FF).withOpacity(0.3),
                            blurRadius: isUltraSmallMobile ? 15 : isSmallMobile ? 18 : 20,
                            spreadRadius: isUltraSmallMobile ? 3 : isSmallMobile ? 4 : 5,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/logo.png',
                        height: isUltraSmallMobile ? 35 :
                        isSmallMobile ? 45 :
                        isMobile ? 55 :
                        isTablet ? 65 :
                        75, // Desktop
                        width: isUltraSmallMobile ? 35 :
                        isSmallMobile ? 45 :
                        isMobile ? 55 :
                        isTablet ? 65 :
                        75, // Desktop
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: isUltraSmallMobile ? 20 : 30),
              AppNameText(fontSize: isUltraSmallMobile ? 32 : isSmallMobile ? 40 : 48),
              SizedBox(height: isUltraSmallMobile ? 6 : 10),
              Text(
                'Endless Entertainment — Cinematic Hits & Quick Reels',
                style: TextStyle(
                  fontSize: isUltraSmallMobile ? 12 : isSmallMobile ? 16 : 18,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isUltraSmallMobile = screenWidth <= 280;
        final isDesktop = screenWidth > 800;
        final isTablet = screenWidth > 600 && screenWidth <= 800;
        final isMobile = screenWidth <= 600;
        final isSmallMobile = screenWidth <= 360;

        return Column(
          children: [
            _buildFixedHeader(isDesktop, isTablet, isMobile, isSmallMobile, isUltraSmallMobile),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeroSection(
                      isDesktop,
                      isTablet,
                      isMobile,
                      isSmallMobile,
                      isUltraSmallMobile,
                    ),
                    _buildMovieCarousel(
                      isDesktop,
                      isTablet,
                      isMobile,
                      isSmallMobile,
                      isUltraSmallMobile,
                    ),
                    _buildFAQSection(
                      isDesktop,
                      isTablet,
                      isMobile,
                      isSmallMobile,
                      isUltraSmallMobile,
                    ),
                    _buildSocialSection(
                      isDesktop,
                      isTablet,
                      isMobile,
                      isSmallMobile,
                      isUltraSmallMobile,
                    ),
                    SizedBox(
                      height: isUltraSmallMobile ? 70 : isSmallMobile ? 80 : isMobile ? 90 : 20,
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
              isUltraSmallMobile,
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
      bool isUltraSmallMobile,
      ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop
            ? 80
            : isTablet
            ? 40
            : isUltraSmallMobile
            ? 8
            : isSmallMobile
            ? 12
            : 20,
        vertical: isUltraSmallMobile ? 8 : isSmallMobile ? 12 : 20,
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
                          padding: EdgeInsets.all(
                            isUltraSmallMobile ? 4 : isSmallMobile ? 6 : 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2979FF), Color(0xFF1976D2)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.asset(
                            'assets/logo.png',
                            height: isUltraSmallMobile ? 12 : isSmallMobile ? 16 : 24,
                            width: isUltraSmallMobile ? 12 : isSmallMobile ? 16 : 24,
                          ),
                        ),
                        SizedBox(width: isUltraSmallMobile ? 6 : isSmallMobile ? 8 : 12),
                        Flexible(
                          child: AppNameText(
                            fontSize: isUltraSmallMobile ? 14 : isSmallMobile ? 18 : 24,
                          ),
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
                          '$_movieCount+ Movie',
                            textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isUltraSmallMobile
                                ? 10
                                : isSmallMobile
                                ? 12
                                : isDesktop
                                ? 20
                                : 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2979FF),
                          ),
                        ),
                        Text(
                          'And Adult Series',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isUltraSmallMobile
                                ? 8
                                : isSmallMobile
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
      bool isUltraSmallMobile,
      ) {
    return Container(
      height: isDesktop
          ? 300
          : isTablet
          ? 270
          : isUltraSmallMobile
          ? 150
          : isSmallMobile
          ? 170
          : 220,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop
            ? 80
            : isTablet
            ? 40
            : isUltraSmallMobile
            ? 8
            : isSmallMobile
            ? 12
            : 20,
      ),
      child: AnimationLimiter(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _logoAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _logoAnimation.value,
                  child: Container(
                    padding: EdgeInsets.all(
                      isUltraSmallMobile ? 12 :
                      isSmallMobile ? 15 :
                      isMobile ? 18 :
                      isTablet ? 22 :
                      25, // Desktop
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2979FF), Color(0xFF1976D2)],
                      ),
                      borderRadius: BorderRadius.circular(
                        isUltraSmallMobile ? 12 :
                        isSmallMobile ? 15 :
                        isMobile ? 18 :
                        20, // Desktop & Tablet
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2979FF).withOpacity(0.3),
                          blurRadius: isUltraSmallMobile ? 15 : isSmallMobile ? 18 : 20,
                          spreadRadius: isUltraSmallMobile ? 3 : isSmallMobile ? 4 : 5,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/logo.png',
                      height: isUltraSmallMobile ? 35 :
                      isSmallMobile ? 45 :
                      isMobile ? 55 :
                      isTablet ? 65 :
                      75, // Desktop
                      width: isUltraSmallMobile ? 35 :
                      isSmallMobile ? 45 :
                      isMobile ? 55 :
                      isTablet ? 65 :
                      75, // Desktop
                    ),
                  ),
                );
              },
            ),
            SizedBox(
              height: isUltraSmallMobile ? 6 : isSmallMobile ? 8 : 10,
            ),
            AppNameText(
              fontSize: isUltraSmallMobile ? 12 : 16,
            ),
            SizedBox(height: isUltraSmallMobile ? 8 : isSmallMobile ? 10 : 20),
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
                          fontSize: isUltraSmallMobile
                              ? 10
                              : isSmallMobile
                              ? 12
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
      bool isUltraSmallMobile,
      ) {
    return Container(
      height: isDesktop
          ? 600
          : isTablet
          ? 500
          : isUltraSmallMobile
          ? 300
          : isSmallMobile
          ? 350
          : 400,
      margin: EdgeInsets.symmetric(
        vertical: isUltraSmallMobile ? 15 : isSmallMobile ? 20 : 40,
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop
                  ? 80
                  : isTablet
                  ? 40
                  : isUltraSmallMobile
                  ? 8
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
                    fontSize: isUltraSmallMobile
                        ? 16
                        : isSmallMobile
                        ? 18
                        : isDesktop
                        ? 28
                        : 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: isUltraSmallMobile ? 10 : isSmallMobile ? 12 : 20),
                _buildGenreChips(isDesktop, isTablet, isMobile, isSmallMobile, isUltraSmallMobile),
              ],
            ),
          ),
          SizedBox(height: isUltraSmallMobile ? 15 : isSmallMobile ? 20 : 30),
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
                        final double itemWidth =
                            constraints.maxHeight * aspectRatio;
                        final double viewportFraction =
                            itemWidth / constraints.maxWidth;

                        if (_currentMovies.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.movie_outlined,
                                  size: isUltraSmallMobile ? 48 : 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: isUltraSmallMobile ? 12 : 16),
                                Text(
                                  'No movies found for $_selectedCategory',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: isUltraSmallMobile ? 10 : 12,
                                  ),
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
                              isUltraSmallMobile,
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
          SizedBox(height: isUltraSmallMobile ? 10 : isSmallMobile ? 15 : 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _currentMovies.asMap().entries.map((entry) {
              return Container(
                width: isUltraSmallMobile ? 4.0 : isSmallMobile ? 6.0 : 8.0,
                height: isUltraSmallMobile ? 4.0 : isSmallMobile ? 6.0 : 8.0,
                margin: EdgeInsets.symmetric(horizontal: isUltraSmallMobile ? 2.0 : 3.0),
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
      bool isDesktop,
      bool isTablet,
      bool isMobile,
      bool isSmallMobile,
      bool isUltraSmallMobile,
      ) {
    if (_isCategoryLoading) {
      return CircularProgressIndicator(
        strokeWidth: isUltraSmallMobile ? 2 : 3,
      );
    }

    final genres = categories;
    return Wrap(
      spacing: isUltraSmallMobile ? 4 : isSmallMobile ? 6 : 10,
      runSpacing: isUltraSmallMobile ? 4 : isSmallMobile ? 6 : 10,
      children: genres.map((genre) {
        final isActive = genre == _selectedCategory;
        return _buildHoverButton(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: EdgeInsets.symmetric(
              horizontal: isUltraSmallMobile ? 8 : isSmallMobile ? 12 : 18,
              vertical: isUltraSmallMobile ? 6 : isSmallMobile ? 8 : 12,
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
                fontSize: isUltraSmallMobile
                    ? 9
                    : isSmallMobile
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
      bool isUltraSmallMobile,
      ) {
    return AnimationConfiguration.staggeredList(
      position: 0,
      duration: const Duration(milliseconds: 1000),
      child: ScaleAnimation(
        scale: 0.8,
        child: FadeInAnimation(
          child: _buildHoverButton(
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: isUltraSmallMobile ? 2 : isSmallMobile ? 4 : 8,
              ),
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
                                strokeWidth: isUltraSmallMobile ? 1 : isSmallMobile ? 2 : 3,
                                value: loadingProgress.expectedTotalBytes != null
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
                                size: isUltraSmallMobile ? 30 : isSmallMobile ? 40 : 60,
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
                      bottom: isUltraSmallMobile ? 8 : isSmallMobile ? 10 : 16,
                      left: isUltraSmallMobile ? 8 : isSmallMobile ? 10 : 16,
                      right: isUltraSmallMobile ? 8 : isSmallMobile ? 10 : 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            movie.title,
                            style: TextStyle(
                              fontSize: isUltraSmallMobile
                                  ? 10
                                  : isSmallMobile
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
                          SizedBox(height: isUltraSmallMobile ? 2 : isSmallMobile ? 4 : 6),
                          Text(
                            '${movie.genre}',
                            style: TextStyle(
                              fontSize: isUltraSmallMobile
                                  ? 8
                                  : isSmallMobile
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
                      top: isUltraSmallMobile ? 8 : isSmallMobile ? 10 : 12,
                      right: isUltraSmallMobile ? 8 : isSmallMobile ? 10 : 12,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isUltraSmallMobile ? 4 : isSmallMobile ? 6 : 10,
                          vertical: isUltraSmallMobile ? 2 : isSmallMobile ? 4 : 6,
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
                              size: isUltraSmallMobile ? 8 : isSmallMobile ? 10 : 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              movie.rating.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isUltraSmallMobile ? 7 : isSmallMobile ? 9 : 11,
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
      bool isUltraSmallMobile,
      ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop
            ? 80
            : isTablet
            ? 40
            : isUltraSmallMobile
            ? 8
            : isSmallMobile
            ? 12
            : 20,
        vertical: isUltraSmallMobile ? 15 : isSmallMobile ? 20 : 40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FAQ',
            style: TextStyle(
              fontSize: isUltraSmallMobile ? 18 : isSmallMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isUltraSmallMobile ? 12 : isSmallMobile ? 15 : 30),
          _buildFAQItem(
            '1. How to download NetPrimeX app on Google Play?',
            'Due to the policy of Google, NetPrimeX don\'t publish in Google Play. NetPrimeX is safe and you can download NetPrimeX on Our Official Website.',
            isDesktop,
            isTablet,
            isMobile,
            isSmallMobile,
            isUltraSmallMobile,
          ),
          SizedBox(height: isUltraSmallMobile ? 8 : isSmallMobile ? 10 : 20),
          _buildFAQItem(
            '2. How to Install NetPrimeX on iPhone, iPad or PC?',
            'NetPrimeX do not publish iOS or Windows version.',
            isDesktop,
            isTablet,
            isMobile,
            isSmallMobile,
            isUltraSmallMobile,
          ),
          SizedBox(height: isUltraSmallMobile ? 8 : isSmallMobile ? 10 : 20),
          _buildFAQItem(
            '3. What is NetPrimeX?',
            'NetPrimeX is quite possibly, the most popular Indian movie streaming app for Android. It is used by millions of users in India to stream the latest Trending Movies, Hot Music, Videos and TV shows - usually to an Android device, but it also works on other platforms.',
            isDesktop,
            isTablet,
            isMobile,
            isSmallMobile,
            isUltraSmallMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(
      String question,
      String answer,
      bool isDesktop,
      bool isTablet,
      bool isMobile,
      bool isSmallMobile,
      bool isUltraSmallMobile,
      ) {
    return AnimationConfiguration.staggeredList(
      position: 0,
      duration: const Duration(milliseconds: 800),
      child: SlideAnimation(
        horizontalOffset: 100.0,
        child: FadeInAnimation(
          child: _buildHoverButton(
            child: Container(
              padding: EdgeInsets.all(
                isUltraSmallMobile ? 10 : isSmallMobile ? 12 : 20,
              ),
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
                      fontSize: isUltraSmallMobile
                          ? 10
                          : isSmallMobile
                          ? 12
                          : isDesktop
                          ? 18
                          : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: isUltraSmallMobile ? 4 : isSmallMobile ? 6 : 10),
                  Text(
                    answer,
                    style: TextStyle(
                      fontSize: isUltraSmallMobile
                          ? 8
                          : isSmallMobile
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
      bool isUltraSmallMobile,
      ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop
            ? 80
            : isTablet
            ? 40
            : isUltraSmallMobile
            ? 8
            : isSmallMobile
            ? 12
            : 20,
        vertical: isUltraSmallMobile ? 15 : isSmallMobile ? 20 : 40,
      ),
      child: Column(
        children: [
          Text(
            'If you can\'t download normally',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isUltraSmallMobile ? 12 : isSmallMobile ? 14 : 18,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isUltraSmallMobile ? 4 : isSmallMobile ? 6 : 10),
          Text(
            'Join the group to get the latest download link',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isUltraSmallMobile ? 10 : isSmallMobile ? 12 : 16,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: isUltraSmallMobile ? 15 : isSmallMobile ? 20 : 30),
          Wrap(
            spacing: isUltraSmallMobile ? 10 : isSmallMobile ? 15 : 25,
            runSpacing: isUltraSmallMobile ? 10 : isSmallMobile ? 15 : 20,
            alignment: WrapAlignment.center,
            children: [
              _buildSocialButton(
                'Instagram',
                "assets/instagram.png",
                isDesktop,
                isTablet,
                isMobile,
                isSmallMobile,
                isUltraSmallMobile,
                true,
              ),
              _buildSocialButton(
                'Telegram',
                "assets/telegram.png",
                isDesktop,
                isTablet,
                isMobile,
                isSmallMobile,
                isUltraSmallMobile,
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
      bool isDesktop,
      bool isTablet,
      bool isMobile,
      bool isSmallMobile,
      bool isUltraSmallMobile,
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
                horizontal: isUltraSmallMobile
                    ? 12
                    : isSmallMobile
                    ? 16
                    : isDesktop
                    ? 40
                    : 24,
                vertical: isUltraSmallMobile
                    ? 4
                    : isSmallMobile
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
                    height: (isUltraSmallMobile
                        ? 12
                        : isSmallMobile
                        ? 16
                        : isDesktop
                        ? 24
                        : 20) *
                        2,
                    width: (isUltraSmallMobile
                        ? 12
                        : isSmallMobile
                        ? 16
                        : isDesktop
                        ? 24
                        : 20) *
                        2,
                  ),
                  SizedBox(width: isUltraSmallMobile ? 4 : isSmallMobile ? 6 : 10),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isUltraSmallMobile
                          ? 10
                          : isSmallMobile
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
      bool isUltraSmallMobile,
      ) {
    return Container(
      padding: EdgeInsets.all(
        isUltraSmallMobile
            ? 6
            : isSmallMobile
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
            minHeight: isUltraSmallMobile
                ? 40
                : isDesktop
                ? 70
                : isTablet
                ? 60
                : isSmallMobile
                ? 50
                : 55,
            maxHeight: isUltraSmallMobile
                ? 60
                : isDesktop
                ? 90
                : isTablet
                ? 80
                : isSmallMobile
                ? 70
                : 75,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isUltraSmallMobile ? 8 : isSmallMobile ? 12 : 20,
            vertical: isUltraSmallMobile ? 6 : isSmallMobile ? 10 : 15,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(isUltraSmallMobile ? 12 : isSmallMobile ? 15 : 20),
            border: Border.all(color: const Color(0xFF2979FF).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isUltraSmallMobile ? 6 : isSmallMobile ? 8 : 12),
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
                  height: isUltraSmallMobile ? 12 : isSmallMobile ? 16 : 20,
                  width: isUltraSmallMobile ? 12 : isSmallMobile ? 16 : 20,
                ),
              ),
              SizedBox(width: isUltraSmallMobile ? 8 : isSmallMobile ? 12 : 14),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: AppNameText(
                        fontSize: isUltraSmallMobile
                            ? 10
                            : isSmallMobile
                            ? 12
                            : isDesktop
                            ? 14
                            : 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Flexible(
                      child: Text(
                        'Movie & Stream',
                        style: TextStyle(
                          fontSize: isUltraSmallMobile
                              ? 7
                              : isSmallMobile
                              ? 9
                              : isDesktop
                              ? 10
                              : 9,
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
                    horizontal: isUltraSmallMobile
                        ? 12
                        : isSmallMobile
                        ? 16
                        : isDesktop
                        ? 28
                        : 20,
                    vertical: isUltraSmallMobile
                        ? 6
                        : isSmallMobile
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
                        size: isUltraSmallMobile
                            ? 10
                            : isSmallMobile
                            ? 12
                            : isDesktop
                            ? 18
                            : 16,
                      ),
                      SizedBox(width: isUltraSmallMobile ? 3 : isSmallMobile ? 4 : 8),
                      Flexible(
                        child: Text(
                          'Download',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isUltraSmallMobile
                                ? 9
                                : isSmallMobile
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
