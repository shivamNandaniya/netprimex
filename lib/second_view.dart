import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
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
  late AnimationController _categoryController;
  late Animation<double> _logoAnimation;
  late Animation<Color?> _backgroundAnimation;
  late Animation<double> _categoryAnimation;

  final CarouselSliderController _carouselController = CarouselSliderController();
  int _currentCarouselIndex = 0;
  bool _isLoading = true;
  String _selectedCategory = 'Action';

  // Complete movie data with categories
  final Map<String, List<MoviePoster>> _moviesByCategory = {
    'Action': [
      MoviePoster(
        title: "12 Strong",
        year: "2018",
        genre: "Action, Thriller",
        rating: 6.5,
        imageUrl: "https://image.tmdb.org/t/p/w500/j18021qCeRi3yUBtqd2UFj1c0RQ.jpg",
      ),
      MoviePoster(
        title: "Renegades",
        year: "2018",
        genre: "Action, Adventure",
        rating: 5.4,
        imageUrl: "https://image.tmdb.org/t/p/w500/1gCab6rNv1r6V64cwsU4oEr649Y.jpg",
      ),
      MoviePoster(
        title: "War for the Planet of the Apes",
        year: "2017",
        genre: "Action, Sci-Fi",
        rating: 7.4,
        imageUrl: "https://image.tmdb.org/t/p/w500/3vYhLLxrTtZLysXtIWktmd57Snv.jpg",
      ),
      MoviePoster(
        title: "The Dark Knight",
        year: "2008",
        genre: "Action, Crime, Drama",
        rating: 9.0,
        imageUrl: "https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg",
      ),
    ],
    'Biography': [
      MoviePoster(
        title: "Bohemian Rhapsody",
        year: "2018",
        genre: "Biography, Drama",
        rating: 7.9,
        imageUrl: "https://image.tmdb.org/t/p/w500/lHu1wtNaczFPGFDTrjCSzeLPTKN.jpg",
      ),
      MoviePoster(
        title: "The Theory of Everything",
        year: "2014",
        genre: "Biography, Drama",
        rating: 7.7,
        imageUrl: "https://image.tmdb.org/t/p/w500/kq2MHrRfH6RTfkvyDEmYLmGHE6U.jpg",
      ),
      MoviePoster(
        title: "Green Book",
        year: "2018",
        genre: "Biography, Comedy",
        rating: 8.2,
        imageUrl: "https://image.tmdb.org/t/p/w500/7BsvSuDQuoqhWmU2fL7W2GOcZHU.jpg",
      ),
    ],
    'Sci-Fi': [
      MoviePoster(
        title: "Spider-Man: Into the Spider-Verse",
        year: "2018",
        genre: "Animation, Action",
        rating: 8.4,
        imageUrl: "https://image.tmdb.org/t/p/w500/iiZZdoQBEYBv6id8su7ImL0oCbD.jpg",
      ),
      MoviePoster(
        title: "Blade Runner 2049",
        year: "2017",
        genre: "Sci-Fi, Thriller",
        rating: 8.0,
        imageUrl: "https://image.tmdb.org/t/p/w500/gajva2L0rPYkEWjzgFlBXCAVBE5.jpg",
      ),
      MoviePoster(
        title: "Arrival",
        year: "2016",
        genre: "Sci-Fi, Drama",
        rating: 7.9,
        imageUrl: "https://image.tmdb.org/t/p/w500/yImmxRokQ48PD49ughXdpKTAsAU.jpg",
      ),
    ],
    'Crime': [
      MoviePoster(
        title: "The Godfather",
        year: "1972",
        genre: "Crime, Drama",
        rating: 9.2,
        imageUrl: "https://image.tmdb.org/t/p/w500/3bhkrj58Vtu7enYsRolD1fZdja1.jpg",
      ),
      MoviePoster(
        title: "Goodfellas",
        year: "1990",
        genre: "Crime, Biography",
        rating: 8.7,
        imageUrl: "https://image.tmdb.org/t/p/w500/aKuFiU82s5ISJpGZp7YkIr3kCUd.jpg",
      ),
      MoviePoster(
        title: "Scarface",
        year: "1983",
        genre: "Crime, Drama",
        rating: 8.3,
        imageUrl: "https://image.tmdb.org/t/p/w500/iQ5ztdjvteGeboxtmRdXEChJOHh.jpg",
      ),
    ],
    'Drama': [
      MoviePoster(
        title: "Lady Bird",
        year: "2017",
        genre: "Drama, Comedy",
        rating: 7.4,
        imageUrl: "https://image.tmdb.org/t/p/w500/iVZ3JAcAjmguGPnRNfWFOtLHOuY.jpg",
      ),
      MoviePoster(
        title: "Moonlight",
        year: "2016",
        genre: "Drama",
        rating: 7.4,
        imageUrl: "https://image.tmdb.org/t/p/w500/4911T5FbJ9eD2Faz5Z8L0c9hySx.jpg",
      ),
      MoviePoster(
        title: "Manchester by the Sea",
        year: "2016",
        genre: "Drama",
        rating: 7.8,
        imageUrl: "https://image.tmdb.org/t/p/w500/e8daDzP0vFOnGyKmve95Yv0D0io.jpg",
      ),
    ],
    'Kids': [
      MoviePoster(
        title: "Coco",
        year: "2017",
        genre: "Animation, Family",
        rating: 8.4,
        imageUrl: "https://image.tmdb.org/t/p/w500/gGEsBPAijhVUFoiNpgZXqRVWJt2.jpg",
      ),
      MoviePoster(
        title: "Moana",
        year: "2016",
        genre: "Animation, Adventure",
        rating: 7.6,
        imageUrl: "https://image.tmdb.org/t/p/w500/4JeejGugONWpJkbnvL12hVoYEDa.jpg",
      ),
      MoviePoster(
        title: "Finding Dory",
        year: "2016",
        genre: "Animation, Comedy",
        rating: 7.3,
        imageUrl: "https://image.tmdb.org/t/p/w500/3UVe4xjz3dWWE65RRUnkcb1xYPF.jpg",
      ),
    ],
  };

  List<MoviePoster> get _currentMovies => _moviesByCategory[_selectedCategory] ?? [];

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

    _categoryController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

    _categoryAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _categoryController,
      curve: Curves.easeInOut,
    ));

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
        final screenWidth = constraints.maxWidth;
        final isDesktop = screenWidth > 800;
        final isTablet = screenWidth > 600 && screenWidth <= 800;
        final isMobile = screenWidth <= 600;
        final isUltraSmallMobile = screenWidth <= 320;
        final isSmallMobile = screenWidth <= 360;

        return Column(
          children: [
            // Fixed Header
            _buildFixedHeader(isDesktop, isTablet, isMobile, isSmallMobile, isUltraSmallMobile),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeroSection(isDesktop, isTablet, isMobile, isSmallMobile, isUltraSmallMobile),
                    _buildMovieCarousel(isDesktop, isTablet, isMobile, isSmallMobile, isUltraSmallMobile),
                    _buildFAQSection(isDesktop, isTablet, isMobile, isSmallMobile, isUltraSmallMobile),
                    _buildSocialSection(isDesktop, isTablet, isMobile, isSmallMobile, isUltraSmallMobile),
                    // ✅ FIXED - Added more bottom spacing to prevent overlap with fixed bottom
                    SizedBox(height: isUltraSmallMobile ? 70 : isSmallMobile ? 80 : isMobile ? 90 : 20),
                  ],
                ),
              ),
            ),

            // ✅ UPDATED - Fixed Bottom Section
            _buildFixedBottomSection(isDesktop, isTablet, isMobile, isSmallMobile, isUltraSmallMobile),
          ],
        );
      },
    );
  }

  Widget _buildFixedHeader(bool isDesktop, bool isTablet, bool isMobile, bool isSmallMobile, bool isUltraSmallMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : isTablet ? 40 : isUltraSmallMobile ? 8 : isSmallMobile ? 12 : 20,
        vertical: isUltraSmallMobile ? 10 : isSmallMobile ? 12 : 20,
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
                          padding: EdgeInsets.all(isUltraSmallMobile ? 4 : isSmallMobile ? 6 : 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2979FF), Color(0xFF1976D2)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: isUltraSmallMobile ? 14 : isSmallMobile ? 16 : 24,
                          ),
                        ),
                        SizedBox(width: isUltraSmallMobile ? 6 : isSmallMobile ? 8 : 12),
                        Flexible(
                          child: Text(
                            'NetPrime',
                            style: TextStyle(
                              fontSize: isUltraSmallMobile ? 16 : isSmallMobile ? 18 : 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
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
                          '100,000+',
                          style: TextStyle(
                            fontSize: isUltraSmallMobile ? 10 : isSmallMobile ? 12 : isDesktop ? 20 : 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2979FF),
                          ),
                        ),
                        Text(
                          'Movies FREE!',
                          style: TextStyle(
                            fontSize: isUltraSmallMobile ? 8 : isSmallMobile ? 10 : isDesktop ? 16 : 14,
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

  Widget _buildHeroSection(bool isDesktop, bool isTablet, bool isMobile, bool isSmallMobile, bool isUltraSmallMobile) {
    return Container(
      height: isDesktop ? 300 : isTablet ? 250 : isUltraSmallMobile ? 120 : isSmallMobile ? 150 : 200,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : isTablet ? 40 : isUltraSmallMobile ? 8 : isSmallMobile ? 12 : 20,
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
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isUltraSmallMobile ? 28 : isSmallMobile ? 32 : isDesktop ? 80 : 48,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: [Color(0xFF2979FF), Color(0xFF1976D2)],
                        ).createShader(
                          const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                        ),
                    ),
                  ),
                ),
              ),
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
                        'Your private cinema',
                        textAlign: TextAlign.center,
                        textStyle: TextStyle(
                          fontSize: isUltraSmallMobile ? 12 : isSmallMobile ? 14 : isDesktop ? 28 : 20,
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

  // ✅ FIXED - Movie Carousel with Corrected Mobile Spacing
  Widget _buildMovieCarousel(bool isDesktop, bool isTablet, bool isMobile, bool isSmallMobile, bool isUltraSmallMobile) {
    return Container(
      height: isDesktop ? 600 : isTablet ? 500 : isUltraSmallMobile ? 280 : isSmallMobile ? 350 : 400,
      margin: EdgeInsets.symmetric(vertical: isUltraSmallMobile ? 15 : isSmallMobile ? 20 : 40),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 80 : isTablet ? 40 : isUltraSmallMobile ? 8 : isSmallMobile ? 12 : 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '2018 Top Movies',
                  style: TextStyle(
                    fontSize: isUltraSmallMobile ? 16 : isSmallMobile ? 18 : isDesktop ? 28 : 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: isUltraSmallMobile ? 10 : isSmallMobile ? 12 : 20),
                _buildGenreChips(isSmallMobile, isMobile, isTablet, isDesktop, isUltraSmallMobile),
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
                    child: CarouselSlider(
                      key: ValueKey(_selectedCategory),
                      carouselController: _carouselController,
                      options: CarouselOptions(
                        height: double.infinity,
                        // ✅ FIXED - Optimal viewport fractions to reduce spacing
                        viewportFraction: isDesktop ? 0.18 : isTablet ? 0.25 : isUltraSmallMobile ? 0.75 : isSmallMobile ? 0.8 : 0.7,
                        enableInfiniteScroll: true,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 3),
                        autoPlayAnimationDuration: const Duration(milliseconds: 800),
                        autoPlayCurve: Curves.fastOutSlowIn,
                        // ✅ FIXED - Disable enlargeCenterPage to reduce spacing
                        enlargeCenterPage: false,
                        enlargeFactor: 0.0,
                        // ✅ FIXED - Disable padding ends for mobile
                        padEnds: !isMobile,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentCarouselIndex = index;
                          });
                        },
                      ),
                      items: _currentMovies.map((movie) {
                        return _buildMoviePosterCard(movie, isDesktop, isTablet, isMobile, isSmallMobile, isUltraSmallMobile);
                      }).toList(),
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
                width: isUltraSmallMobile ? 5.0 : isSmallMobile ? 6.0 : 8.0,
                height: isUltraSmallMobile ? 5.0 : isSmallMobile ? 6.0 : 8.0,
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

  Widget _buildGenreChips(bool isSmallMobile, bool isMobile, bool isTablet, bool isDesktop, bool isUltraSmallMobile) {
    final genres = ['Action', 'Biography', 'Sci-Fi', 'Crime', 'Drama', 'Kids'];

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
                horizontal: isUltraSmallMobile ? 10 : isSmallMobile ? 12 : 18,
                vertical: isUltraSmallMobile ? 6 : isSmallMobile ? 8 : 12
            ),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF2979FF) : Colors.transparent,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isActive ? const Color(0xFF2979FF) : Colors.grey[600]!,
                width: 2,
              ),
              boxShadow: isActive ? [
                BoxShadow(
                  color: const Color(0xFF2979FF).withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ] : null,
            ),
            child: Text(
              genre,
              style: TextStyle(
                fontSize: isUltraSmallMobile ? 10 : isSmallMobile ? 11 : isMobile ? 13 : 15,
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

  // ✅ FIXED - Movie Poster Card with Reduced Margin for Mobile
  Widget _buildMoviePosterCard(MoviePoster movie, bool isDesktop, bool isTablet, bool isMobile, bool isSmallMobile, bool isUltraSmallMobile) {
    return AnimationConfiguration.staggeredList(
      position: 0,
      duration: const Duration(milliseconds: 1000),
      child: ScaleAnimation(
        scale: 0.8,
        child: FadeInAnimation(
          child: _buildHoverButton(
            child: Container(
              // ✅ FIXED - Reduced horizontal margin for mobile to prevent extra spacing
              margin: EdgeInsets.symmetric(horizontal: isUltraSmallMobile ? 0 : isSmallMobile ? 1 : isMobile ? 2 : 8),
              child: AspectRatio(
                aspectRatio: 2 / 3, // Standard movie poster ratio
                child: Container(
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
                              colors: [
                                Colors.grey[800]!,
                                Colors.grey[900]!,
                              ],
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
                                    colors: [
                                      Colors.grey[800]!,
                                      Colors.grey[900]!,
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: const Color(0xFF2979FF),
                                    strokeWidth: isUltraSmallMobile ? 1.5 : isSmallMobile ? 2 : 3,
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
                                    colors: [
                                      Colors.grey[800]!,
                                      Colors.grey[900]!,
                                    ],
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
                                  fontSize: isUltraSmallMobile ? 10 : isSmallMobile ? 12 : isDesktop ? 16 : 14,
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
                                '${movie.genre}, ${movie.year}',
                                style: TextStyle(
                                  fontSize: isUltraSmallMobile ? 8 : isSmallMobile ? 9 : isDesktop ? 12 : 10,
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
                                    fontSize: isUltraSmallMobile ? 8 : isSmallMobile ? 9 : 11,
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

  Widget _buildFAQSection(bool isDesktop, bool isTablet, bool isMobile, bool isSmallMobile, bool isUltraSmallMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : isTablet ? 40 : isUltraSmallMobile ? 8 : isSmallMobile ? 12 : 20,
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
            '1. How to download NetPrime app on Google Play?',
            'Due to the policy of Google, NetPrime don\'t publish in Google Play. NetPrime is safe and you can download NetPrime on Our Official Website.',
            isSmallMobile,
            isMobile,
            isTablet,
            isDesktop,
            isUltraSmallMobile,
          ),
          SizedBox(height: isUltraSmallMobile ? 8 : isSmallMobile ? 10 : 20),
          _buildFAQItem(
            '2. How to Install NetPrime on iPhone, iPad or PC?',
            'NetPrime do not publish iOS or Windows version.',
            isSmallMobile,
            isMobile,
            isTablet,
            isDesktop,
            isUltraSmallMobile,
          ),
          SizedBox(height: isUltraSmallMobile ? 8 : isSmallMobile ? 10 : 20),
          _buildFAQItem(
            '3. What is NetPrime?',
            'NetPrime is quite possibly, the most popular Indian movie streaming app for Android. It is used by millions of users in India to stream the latest Trending Movies, Hot Music, Videos and TV shows - usually to an Android device, but it also works on other platforms.',
            isSmallMobile,
            isMobile,
            isTablet,
            isDesktop,
            isUltraSmallMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer, bool isSmallMobile, bool isMobile, bool isTablet, bool isDesktop, bool isUltraSmallMobile) {
    return AnimationConfiguration.staggeredList(
      position: 0,
      duration: const Duration(milliseconds: 800),
      child: SlideAnimation(
        horizontalOffset: 100.0,
        child: FadeInAnimation(
          child: _buildHoverButton(
            child: Container(
              padding: EdgeInsets.all(isUltraSmallMobile ? 10 : isSmallMobile ? 12 : 20),
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
                      fontSize: isUltraSmallMobile ? 11 : isSmallMobile ? 12 : isDesktop ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: isUltraSmallMobile ? 4 : isSmallMobile ? 6 : 10),
                  Text(
                    answer,
                    style: TextStyle(
                      fontSize: isUltraSmallMobile ? 9 : isSmallMobile ? 10 : isDesktop ? 16 : 14,
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

  Widget _buildSocialSection(bool isDesktop, bool isTablet, bool isMobile, bool isSmallMobile, bool isUltraSmallMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : isTablet ? 40 : isUltraSmallMobile ? 8 : isSmallMobile ? 12 : 20,
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
                'WhatsApp',
                Colors.green,
                Icons.chat,
                isSmallMobile,
                isMobile,
                isTablet,
                isDesktop,
                isUltraSmallMobile,
              ),
              _buildSocialButton(
                'Telegram',
                const Color(0xFF0088CC),
                Icons.send,
                isSmallMobile,
                isMobile,
                isTablet,
                isDesktop,
                isUltraSmallMobile,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(
      String title,
      Color color,
      IconData icon,
      bool isSmallMobile,
      bool isMobile,
      bool isTablet,
      bool isDesktop,
      bool isUltraSmallMobile,
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
                horizontal: isUltraSmallMobile ? 12 : isSmallMobile ? 16 : isDesktop ? 40 : 24,
                vertical: isUltraSmallMobile ? 10 : isSmallMobile ? 12 : isDesktop ? 16 : 14,
              ),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
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
                    size: isUltraSmallMobile ? 14 : isSmallMobile ? 16 : isDesktop ? 24 : 20,
                  ),
                  SizedBox(width: isUltraSmallMobile ? 4 : isSmallMobile ? 6 : 10),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isUltraSmallMobile ? 10 : isSmallMobile ? 12 : isDesktop ? 16 : 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              print('$title button tapped!');
            },
            hoverScale: 1.1,
            hoverShadowColor: color,
          ),
        ),
      ),
    );
  }

  // ✅ FIXED - Bottom Section with Proper Text Display
  Widget _buildFixedBottomSection(bool isDesktop, bool isTablet, bool isMobile, bool isSmallMobile, bool isUltraSmallMobile) {
    return Container(
      padding: EdgeInsets.all(isUltraSmallMobile ? 6 : isSmallMobile ? 8 : isDesktop ? 15 : 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D).withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: Colors.grey[800]!,
            width: 1,
          ),
        ),
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
          // ✅ FIXED - Increased height constraints to prevent text cutoff
          constraints: BoxConstraints(
            minHeight: isDesktop ? 60 : isTablet ? 55 : isUltraSmallMobile ? 45 : isSmallMobile ? 50 : 55,
            maxHeight: isDesktop ? 80 : isTablet ? 75 : isUltraSmallMobile ? 65 : isSmallMobile ? 70 : 75,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isUltraSmallMobile ? 8 : isSmallMobile ? 12 : 20,
            vertical: isUltraSmallMobile ? 6 : isSmallMobile ? 8 : 12,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(isUltraSmallMobile ? 12 : isSmallMobile ? 15 : 20),
            border: Border.all(
              color: const Color(0xFF2979FF).withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              // Play Icon with Blue Gradient
              _buildHoverButton(
                child: Container(
                  padding: EdgeInsets.all(isUltraSmallMobile ? 6 : isSmallMobile ? 8 : 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2979FF), Color(0xFF1976D2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: isUltraSmallMobile ? 14 : isSmallMobile ? 16 : 22,
                  ),
                ),
                onTap: () {
                  print('Play button tapped!');
                },
                hoverScale: 1.1,
              ),

              SizedBox(width: isUltraSmallMobile ? 8 : isSmallMobile ? 12 : 18),

              // Expanded Text Content - Prevents overflow
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        'Get start with NetPrime',
                        style: TextStyle(
                          fontSize: isUltraSmallMobile ? 10 : isSmallMobile ? 12 : isDesktop ? 16 : 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Flexible(
                      child: Text(
                        'Movie & Stream',
                        style: TextStyle(
                          fontSize: isUltraSmallMobile ? 8 : isSmallMobile ? 9 : isDesktop ? 12 : 11,
                          color: Colors.grey[400],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: isUltraSmallMobile ? 6 : isSmallMobile ? 8 : 15),

              // ✅ FIXED - Download Button with Flexible Layout
              Flexible(
                flex: 2,
                child: _buildHoverButton(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: isUltraSmallMobile ? 12 : isSmallMobile ? 16 : isDesktop ? 32 : 24,
                        vertical: isUltraSmallMobile ? 8 : isSmallMobile ? 10 : isDesktop ? 14 : 12
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
                          size: isUltraSmallMobile ? 12 : isSmallMobile ? 14 : isDesktop ? 20 : 18,
                        ),
                        SizedBox(width: isUltraSmallMobile ? 3 : isSmallMobile ? 4 : 8),
                        Flexible(
                          child: Text(
                            'Download',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isUltraSmallMobile ? 10 : isSmallMobile ? 12 : isDesktop ? 16 : 14,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    print('Download button tapped!');
                  },
                  hoverScale: 1.05,
                  hoverShadowColor: const Color(0xFF2979FF),
                ),
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

// Hover Button Widget Class with Cursor Changes
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
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
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
                      : _isHovered ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 3,
                      offset: const Offset(0, 5),
                    ),
                  ] : null,
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

// Movie Poster Model
class MoviePoster {
  final String title;
  final String year;
  final String genre;
  final double rating;
  final String imageUrl;

  MoviePoster({
    required this.title,
    required this.year,
    required this.genre,
    required this.rating,
    required this.imageUrl,
  });
}
