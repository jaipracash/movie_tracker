import 'package:flutter/material.dart';
import 'package:movie_tracker/models/movie_list_model.dart';
import 'package:movie_tracker/helpers/api_service.dart';
import 'package:movie_tracker/components/navBar.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../models/view_all_movie_model.dart';

class MovieGridView extends StatefulWidget {
  final String movieType;

  const MovieGridView({super.key, required this.movieType});

  @override
  State<MovieGridView> createState() => _MovieGridViewState();
}

class _MovieGridViewState extends State<MovieGridView> {
  late ScrollController _scrollController;
  final List<MovieList> _movies = [];
  bool _isLoading = false;
  int _page = 1;

  @override
  void initState() {
    super.initState();
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
    return _body(3, 30, 1.0, 4.0, 4.0); // 4 columns for mobile layout
  }

  Widget _desktopLayout() {
    return _body(7, 70, 10.0, 8.0, 8.0); // 7 columns for desktop layout
  }

  Widget _body(int columnCount, double padHor, double SzBoxAftrDivider, double crossAxisSpacing, double mainAxisSpacing) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B1C32),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const NavBar(),
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: padHor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20.0),
                Text(
                  widget.movieType == 'popular' ? 'Popular Movies' : 'Upcoming Movies',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0, color: Colors.white),
                ),
                const SizedBox(height: 10.0),
                const Divider(thickness: 1.0, color: Colors.white),
                SizedBox(height: SzBoxAftrDivider),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding:  EdgeInsets.symmetric(horizontal: padHor),
              child: _movies.isEmpty && !_isLoading
                  ? const Center(child: Text("No data found"))
                  : GridView.builder(
                controller: _scrollController,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columnCount,
                  crossAxisSpacing: crossAxisSpacing,
                  mainAxisSpacing:mainAxisSpacing,
                  childAspectRatio: 0.7,
                ),
                itemCount: _movies.length + (_isLoading ? 1 : 0), // Add an extra item for loading
                itemBuilder: (BuildContext context, int index) {
                  if (index == _movies.length && _isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final movie = _movies[index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        'https://image.tmdb.org/t/p/w500/${movie.posterPath}',
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
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
      final newMovies = await TmdbService.getMoviesList(movieType: widget.movieType, page: _page);
      setState(() {
        _isLoading = false;
        if (newMovies.isNotEmpty) {
          _movies.addAll(newMovies as Iterable<MovieList>);
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
