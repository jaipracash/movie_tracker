import 'package:flutter/material.dart';
import 'package:movie_tracker/helpers/api_service.dart';
import 'package:movie_tracker/models/movie_list_model.dart';
import 'package:movie_tracker/utils/colors.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:movie_tracker/components/movie_grid_view.dart';

import 'movieDetailsPage.dart';

class MovieRow extends StatefulWidget {
  final String movieType;
  final String? movieId;

  const MovieRow({super.key, required this.movieType, this.movieId,});

  @override
  _MovieRowState createState() => _MovieRowState();
}

  class _MovieRowState extends State<MovieRow> with SingleTickerProviderStateMixin {
    late TabController _tabController;
    late Future<MovieResponse> _moviesFuture; // Shared Future for API response



    @override
    void initState() {
      super.initState();
      _tabController = TabController(length: 2, vsync: this);
      _moviesFuture = _fetchMovies('movie'); // Initialize shared Future

    }


    Future<MovieResponse> _fetchMovies(String type) async {
      if (widget.movieId == null){
        final response = await TmdbService.getMovies(
            page: 1, movieType: widget.movieType, category: type);
        return MovieResponse.fromJson(response);
      } else {
        final response = await TmdbService.getMovies(
            page: 1, movieType: widget.movieType, category: type, movieId: widget.movieId.toString());
        return MovieResponse.fromJson(response);
      }
    }

    @override
    Widget build(BuildContext context) {
      return ScreenTypeLayout.builder(
        mobile: (_) => _mobileLayout(),
        desktop: (_) => _desktopLayout(),
      );
    }

    Widget _mobileLayout() {
      return Container(
          width: double.infinity,
          height: widget.movieType != 'upcoming' ? 450.0 : 350.0,
          child: Scaffold(
            body: _body(20.0, 15.0, 15.0), // 100, 150, 80.0, 10.0
            backgroundColor: _bgColor(widget.movieType,
            ),
          )
      );
    }

    Widget _desktopLayout() {
      return Container(
        width: double.infinity,
        height: widget.movieType != 'upcoming' ? 450.0 : 350.0,
        child: Scaffold(
          body: _body(40.0, 30.0, 20.0), //150, 200, 150, 15.0
          backgroundColor: _bgColor(widget.movieType),
        ),
      );
    }


    Widget _body(double actionPadRight, double actionPadTop,
        double actionTextSize) {
      return Column(
        children: [
          const SizedBox(height: 15.0,),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 15.0, right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.movieType.replaceAll('_', ' ')[0].toUpperCase() +
                      widget.movieType.replaceAll('_', ' ')
                          .substring(1)
                          .toLowerCase(),
                  style: const TextStyle(color: Colors.white,
                      fontSize: 22.0,
                      fontWeight: FontWeight.w700),
                ),
                if (widget.movieType != 'recommendations')
                  InkWell(
                  onTap: () {
                    print('testing tap ${widget.movieType}');
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>
                          MovieGridView(movieType: widget.movieType,)),
                    );
                  },
                  child: Text(
                    'View all',
                    style: TextStyle(
                        color: Colors.grey, fontSize: actionTextSize),
                  ),
                ),
              ],
            ),
          ),
          if (widget.movieType != 'upcoming' && widget.movieType != 'recommendations') ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  indicatorColor: Colors.white,
                  dividerHeight: 0.0,
                  indicatorPadding: const EdgeInsets.symmetric(vertical: 10.0),
                  tabAlignment: TabAlignment.start,
                  tabs: const [
                    Tab(text: 'Movies'),
                    Tab(text: 'TV Shows'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            Flexible(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _movieList('movie', 150, 200, 150, 12.0),
                  _movieList('tv', 150, 200, 150, 12.0),
                ],
              ),
            ),
          ] else
            Flexible(child: _movieList('movie', 150, 200, 150, 12.0)),
        ],
      );
    }

    Widget _movieList(String category, double itemWidth, double itemHeight,
        double titleWidth, double fontSz) {
      return FutureBuilder<MovieResponse>(
        future: _fetchMovies(category),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.movies.isEmpty) {
            return const Center(child: Text('No movies available.'));
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MovieDetailsScreen(movieId: movie.id),
                            ),
                          );

                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            'https://image.tmdb.org/t/p/w500/${movie
                                .posterPath}',
                            width: itemWidth,
                            height: itemHeight,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: SizedBox(
                          width: titleWidth,
                          child: Text(
                            movie.title,
                            maxLines: 2,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              fontSize: fontSz,
                            ),
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

    Color _bgColor(String movieType) {
      if (widget.movieType == 'popular') {
        return AppColors.popularMoviesBg;
      }
      else if (widget.movieType == 'recommendations'){
        return AppColors.recommendationsColor;
      }
      else if (widget.movieType == 'upcoming'){
        return AppColors.upcomingMoviesBg;
    }else{
        return AppColors.topRatedMoviesBg;
      }
  }
}
