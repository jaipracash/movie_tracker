import 'package:flutter/material.dart';
import 'package:movie_tracker/helpers/api_service.dart';
import 'package:movie_tracker/models/movie_list_model.dart';
import 'package:movie_tracker/utils/colors.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../components/movie_grid_view.dart';

class UpcomingMoviesPage extends StatefulWidget {
  @override
  _UpcomingMoviesPageState createState() => _UpcomingMoviesPageState();
}

class _UpcomingMoviesPageState extends State<UpcomingMoviesPage> {
  late Future<MovieResponse> _upcomingMovies;

  @override
  void initState() {
    super.initState();
    _upcomingMovies = _fetchUpcomingMovies();
  }

  Future<MovieResponse> _fetchUpcomingMovies() async {
    final response = await TmdbService.getUpcomingMovies(page: 1);
    return MovieResponse.fromJson(response);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: mobileUpcoming(),
      desktop: desktopUpcoming(),
    );
  }

  Widget mobileUpcoming() {
    return Container(
      width: double.infinity,
      height: 350.0,
      child: Scaffold(
        appBar: _appBar(5.0, 20.0, 18.0, 20.0, 15.0, 15.0),
        body: _body(100, 150, 80.0, 15.0),
        backgroundColor: const Color(0xFF170B3B),
      ),
    );
  }

  Widget desktopUpcoming() {
    return Container(
      width: double.infinity,
      height: 350.0,
      child: Scaffold(
        appBar: _appBar(15.0, 30.0, 25.0, 40.0, 30.0, 20.0),
        body: _body(150, 200, 150.0, 15.0),
        backgroundColor: const Color(0xFF170B3B),
      ),
    );
  }

  AppBar _appBar(double padLeft, double padTop, double fontSize,
      double actionPadRight, double actionPadTop, double actionFontSize) {
    return AppBar(
      backgroundColor: const Color(0xFF170B3B),
      title: Padding(
        padding: EdgeInsets.only(left: padLeft, top: padTop),
        child: Text(
          'Upcoming Movies',
          style: TextStyle(color: Colors.white, fontSize: fontSize),
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: actionPadRight, top: actionPadTop),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MovieGridView(movieType: 'upcoming',)),
              );
            },
            child: Text(
              'View all',
              style: TextStyle(color: Colors.blue, fontSize: actionFontSize),
            ),
          ),
        ),
      ],
    );
  }

  Widget _body(double posterWidth, double posterHeight, double titleWidth, fontSz) {
    return FutureBuilder<MovieResponse>(
      future: _upcomingMovies,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.movies.isEmpty) {
          return const Center(child: Text('No upcoming movies available.'));
        }

        final movies = snapshot.data!.movies;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Handle movie click
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          'https://image.tmdb.org/t/p/w500/${movie.posterPath}',
                          width: posterWidth,
                          height: posterHeight,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    SizedBox(
                      width: titleWidth,
                      child: Text(
                        movie.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: fontSz
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
