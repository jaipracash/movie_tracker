import 'package:flutter/material.dart';
import 'package:movie_tracker/helpers/api_service.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:movie_tracker/utils/colors.dart';
import '../models/view_all_movie_model.dart';
import '../pages/home_page.dart';
import '../pages/movieDetailsPage.dart';
import 'package:movie_tracker/components/navBar.dart';

class MovieGridView extends StatefulWidget {
  final String movieType;

  const MovieGridView({super.key, required this.movieType});

  @override
  State<MovieGridView> createState() => _MovieGridViewState();
}

class _MovieGridViewState extends State<MovieGridView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  final List<MovieList> _movies = [];
  bool _isLoading = false;
  int _page = 1;
  String _currentCategory = 'movie'; // Default to "movie"

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 0) {
        _switchCategory('movie');
      } else {
        _switchCategory('tv');
      }
    });
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _loadMoreMovies();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: _mobileLayout(),
      desktop: _desktopLayout(),
    );
  }

  Widget _mobileLayout() {
    return _body(3, 30, 1.0);
  }

  Widget _desktopLayout() {
    return _body(8, 30, 10.0);
  }

  Widget _body(int columnSize, double padHor, double szBoxAftrDivider) {
    return Scaffold(
      backgroundColor: AppColors.topRatedMoviesBg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _isMobileView() ? mobileNavBar(context) : NavBar(),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padHor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20.0),
                  Text(
                    '${widget.movieType.replaceAll('_', ' ')[0].toUpperCase() +
                        widget.movieType.replaceAll('_', ' ').substring(1).toLowerCase()} Movies',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 25.0, color: Colors.white),
                  ),
                  // SizedBox(height: szBoxAftrDivider),
                  if (widget.movieType != 'upcoming') ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(text: 'Movies'),
                          Tab(text: 'TV Shows'),
                        ],
                        tabAlignment: TabAlignment.start,
                        isScrollable: true,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.white,
                        indicatorSize: TabBarIndicatorSize.label,
                        indicatorPadding: const EdgeInsets.symmetric(vertical: 10.0),
                        dividerColor: Colors.transparent,
                      ),
                    ),
                    const Divider(thickness: 1.0, color: Colors.white),
                ],
                ],
              ),
            ),
          ),
        if (widget.movieType != 'upcoming') ...[
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _fetchMovieDetails(columnSize, 4.0, 4.0, padHor),
                _fetchMovieDetails(columnSize, 4.0, 4.0, padHor),
              ],
            ),
          ),
          ]else
            Flexible(child: _fetchMovieDetails(columnSize, 4.0, 4.0, padHor),
            )
        ],
      ),
    );
  }

  Widget _fetchMovieDetails(int columnCount, double crossAxisSpacing, double mainAxisSpacing, double padHor) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padHor),
      child: _movies.isEmpty && !_isLoading
          ? const Center(child: Text("No data found", style: TextStyle(color: Colors.white)))
          : GridView.builder(
        controller: _scrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columnCount,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          childAspectRatio: 0.7,
        ),
        itemCount: _movies.length + (_isLoading ? 1 : 0),
        itemBuilder: (BuildContext context, int index) {
          if (index >= _movies.length) {
            return Card(
              color: Colors.white60,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
              ),
            );
          }
          final movie = _movies[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MovieDetailsScreen(movieId: movie.id),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: movie.posterPath != null
                    ? Image.network(
                  'https://image.tmdb.org/t/p/w500/${movie.posterPath}',
                  fit: BoxFit.cover,
                )
                    : const Center(child: Text('No Image')),
              ),
            ),
          );
        },

      ),
    );
  }

  Widget mobileNavBar(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        height: 70.0,
        color: AppColors.navbarColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 15.0),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'FilmFeed',
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>
                            HomePage()),
                      );
                    },
                    child: Text('Home', style: TextStyle(color: Colors.white, fontSize: 15.0),),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoading) {
      _loadMoreMovies();
    }
  }

  void _loadMoreMovies() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newMovies = await TmdbService.getMoviesList(
        movieType: widget.movieType,
        category: _currentCategory,
        page: _page,
      );
      setState(() {
        _isLoading = false;
        if (newMovies.isNotEmpty) {
          _movies.addAll(newMovies.map((movie) => MovieList(
            id: movie.id,
            title: movie.title,
            posterPath: movie.posterPath,
          )));
          _page++;
        }
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print("Error loading more movies: $error");
    }
  }

  void _switchCategory(String category) {
    setState(() {
      _currentCategory = category;
      _movies.clear();
      _page = 1;
    });
    _loadMoreMovies();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool _isMobileView() {
    return MediaQuery.of(context).size.width < 800;
  }
}
