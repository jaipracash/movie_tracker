import 'package:flutter/material.dart';
import 'package:movie_tracker/helpers/api_service.dart';
import 'package:movie_tracker/models/movie_list_model.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:async';

class TamilMoviesPage extends StatefulWidget {
  @override
  _TamilMoviesPageState createState() => _TamilMoviesPageState();
}

class _TamilMoviesPageState extends State<TamilMoviesPage> {
  late Future<List<Movie>> _tamilMovies;
  List<Movie> _cachedMovies = [];
  int _currentIndex = 0;
  late PageController _pageController;
  late Timer _autoMoveTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _tamilMovies = _fetchTamilMovies();
    _startAutoMove();
  }

  Future<List<Movie>> _fetchTamilMovies() async {
    try {
      List<Movie> movies = await TmdbService.getTamilMovies();
      _cachedMovies = movies.take(10).toList();
      return _cachedMovies;
    } catch (e) {
      throw Exception('Error fetching Tamil movies: $e');
    }
  }

  void _startAutoMove() {
    _autoMoveTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentIndex < _cachedMovies.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoMoveTimer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: mobileView(),
      desktop: desktopView(),
    );
  }

  Widget mobileView() {
    return buildBody(isDesktop: false);
  }

  Widget desktopView() {
    return buildBody(isDesktop: true);
  }

  Widget buildBody({required bool isDesktop}) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF9388A2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<Movie>>(
          future: _tamilMovies,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No Tamil movies available.'));
            }

            final movies = _cachedMovies;

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 80.0 : 16.0,
                vertical: 30.0,
              ),
              child: Stack(
                children: [
                  backgroundImage(movies),
                  gradientOverlay(),
                  carouselSlider(movies, isDesktop),
                  pageIndicator(
                    isDesktop
                        ? movies.length
                        : movies.length,
                    isDesktop ? 10.0 : 5.0,
                    isDesktop ? 10.0 : 5.0,
                    isDesktop ? 15.0 : 5.0,
                    isDesktop ? 4.0 : 3.0,
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget backgroundImage(List<Movie> movies) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          image: DecorationImage(
            image: NetworkImage(
              'https://image.tmdb.org/t/p/w500/${movies[_currentIndex].backdropPath}',
            ),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget gradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.black87,
              Colors.black.withOpacity(0.4),
            ],
          ),
        ),
      ),
    );
  }

  Widget carouselSlider(List<Movie> movies, bool isDesktop) {
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: PageView.builder(
          controller: _pageController,
          itemCount: movies.length,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            final movie = movies[index];
            return isDesktop
                ? desktopCarouselItem(movie)
                : mobileCarouselItem(movie);
          },
        ),
      ),
    );
  }

  Widget desktopCarouselItem(Movie movie) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.network(
              movie.posterPath != null
                  ? 'https://image.tmdb.org/t/p/w500/${movie.posterPath}'
                  : 'https://via.placeholder.com/200',
              width: 200.0,
              height: 300.0,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 25.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  movie.title,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  movie.overView,
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget mobileCarouselItem(Movie movie) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.network(
              movie.posterPath != null
                  ? 'https://image.tmdb.org/t/p/w500/${movie.posterPath}'
                  : 'https://via.placeholder.com/200',
              width: 100.0,
              height: 180.0,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10.0),
          Text(
            movie.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              movie.overView,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14.0,
                color: Colors.white,
              ),
              maxLines: 7,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget pageIndicator(int itemCount, dotWd, dotHei, spacing, expFactor) {
    return Positioned(
      bottom: 10.0,
      left: 0,
      right: 0,
      child: Center(
        child: SmoothPageIndicator(
          controller: _pageController,
          count: itemCount,
          effect: ExpandingDotsEffect(
            dotWidth: dotWd,
            dotHeight: dotHei,
            spacing: spacing,
            expansionFactor: expFactor,
            dotColor: Colors.white,
            activeDotColor: Colors.orange,
          ),
        ),
      ),
    );
  }
}
