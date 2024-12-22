import 'package:flutter/material.dart';
import 'package:movie_tracker/helpers/api_service.dart';
import 'package:movie_tracker/models/movie_list_model.dart';
import 'package:movie_tracker/utils/colors.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:movie_tracker/components/movie_grid_view.dart';

class MovieRow extends StatefulWidget {
  final String movieType;

  const MovieRow({super.key, required this.movieType});

  @override
  _MovieRowState createState() => _MovieRowState();
}

class _MovieRowState extends State<MovieRow> {
  late Future<MovieResponse> _movies;

  @override
  void initState() {
    super.initState();
    _movies = _fetchMovies();
  }

  Future<MovieResponse> _fetchMovies() async {
    final response = await TmdbService.getMovies(page: 1, movieType: widget.movieType);
    return MovieResponse.fromJson(response);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: _mobileLayout(),
      desktop: _desktopLayout(),
    );
  }

  Widget _mobileLayout() {
    return Container(
      width: double.infinity,
      height: 320.0,
      child: Scaffold(
        body: _body( 20.0, 15.0, 15.0, 100, 150, 80.0, 10.0),
        backgroundColor: _bgColor(widget.movieType,
      ),
    )
    );
  }

  Widget _desktopLayout() {
    return Container(
      width: double.infinity,
      height: 350.0,
      child: Scaffold(
        body: _body(40.0, 30.0, 20.0, 150, 200, 150, 15.0),
        backgroundColor: _bgColor(widget.movieType),
      ),
    );
  }


  Widget _body(double actionPadRight, double actionPadTop, double actionTextSize, double itemWidth, double itemHeight, double titleWidth, double fontSz) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 15.0, right: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Text(
                 widget.movieType[0].toUpperCase() + widget.movieType.substring(1).toLowerCase(),
                style:  const TextStyle(color: Colors.white, fontSize: 28.0, fontWeight: FontWeight.w700),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MovieGridView(movieType: 'popular',)),
                  );
                },
                child: Text(
                  'View all',
                  style: TextStyle(color: Colors.black, fontSize: actionTextSize),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: FutureBuilder<MovieResponse>(
            future: _movies,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.movies.isEmpty) {
                return const Center(child: Text('No  movies available.'));
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
                                width: itemWidth,
                                height: itemHeight,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8.0),
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
          ),
        ),
      ],
    );
  }

  Color _bgColor(String movieType) {
    if(widget.movieType == 'popular'){
      return AppColors.popularMoviesBg;
    }else{
      return AppColors.upcomingMoviesBg;
    }
  }
}
