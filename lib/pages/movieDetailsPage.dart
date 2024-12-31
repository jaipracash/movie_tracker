import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:movie_tracker/models/movie_details_models.dart' as details;
import 'package:movie_tracker/helpers/api_service.dart';
import '../models/castCrewModels.dart';
import '../models/omdbModels.dart';
import '../models/watchProviderModels.dart';
import 'package:movie_tracker/pages/youTubePlayer.dart';
import 'package:movie_tracker/pages/movieRow.dart';
import 'package:movie_tracker/components/navBar.dart';

import '../utils/colors.dart';
import 'home_page.dart';

class MovieDetailsScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailsScreen({Key? key, required this.movieId}) : super(key: key);

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<Map<String, dynamic>> _movieDetailsWithOmdb;
  late Future<Map<String, List>> _castAndCrewFuture;
  List<String> backdrops = [];
  List<String> posters = [];


  @override
  void initState() {
    super.initState();
    _movieDetailsWithOmdb = _fetchMovieDetailsWithOmdb();
    _castAndCrewFuture = fetchCastAndCrew(widget.movieId);
    _tabController = TabController(length: 2, vsync: this);
    fetchImages();
  }

  Future<void> fetchImages() async {
    final url =
        'https://api.themoviedb.org/3/movie/${widget
        .movieId}/images?api_key=e245e9ec8ac73a4f3fcbfbcd944f872d';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('API Response: ${response.body}');

        setState(() {
          posters = List<String>.from(
            data['posters']?.map((item) {
              if (item['file_path'] != null) {
                return 'https://image.tmdb.org/t/p/w500${item['file_path']}';
              }
              return null;
            }).where((url) => url != null) ?? [], // Filter nulls
          );
          backdrops = List<String>.from(
            data['backdrops']?.map((item) {
              if (item['file_path'] != null) {
                return 'https://image.tmdb.org/t/p/w500${item['file_path']}';
              }
              return null;
            }).where((url) => url != null) ?? [],
          );

          print('Mapped Posters URLs: $posters');
        });
      } else {
        print('Failed to fetch images: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching images: $e');
    }
  }

  Future<String?> fetchTrailer(String movieId) async {
    final apiKey = 'e245e9ec8ac73a4f3fcbfbcd944f872d';
    final url = 'https://api.themoviedb.org/3/movie/$movieId/videos?api_key=$apiKey&language=ta';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Extract the "results" list
        final results = data['results'] as List<dynamic>;

        // Try finding Tamil ("ta") trailer first
        final tamilTrailer = results.firstWhere(
              (video) =>
          video['type'] == 'Trailer' && video['iso_639_1'] == 'ta',
          orElse: () => null,
        );

        // If Tamil trailer is not found, fall back to English ("en")
        final englishTrailer = results.firstWhere(
              (video) =>
          video['type'] == 'Trailer' && video['iso_639_1'] == 'en',
          orElse: () => null,
        );

        // Determine the trailer to use
        final selectedTrailer = tamilTrailer ?? englishTrailer;

        // Return the YouTube key if a trailer is found
        return selectedTrailer?['key'];
      } else {
        print('Failed to fetch videos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching videos: $e');
    }

    return null; // Return null if no trailer is found
  }

  Future<Map<String, dynamic>> _fetchMovieDetailsWithOmdb() async {
    final movieDetails = await TmdbService.getMovieDetails(widget.movieId);
    final omdbDetails = await fetchMovieDetails(movieDetails.imdbId);

    return {
      "tmdb": movieDetails,
      "omdb": omdbDetails,
    };
  }

  Future<List<WatchProvider>?> fetchWatchProviders(int movieId) async {
    final apiKey = 'e245e9ec8ac73a4f3fcbfbcd944f872d';
    final url = 'https://api.themoviedb.org/3/movie/$movieId/watch/providers?api_key=$apiKey';
    print('requested url: $url');

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Loop through the 'results' map and check for valid flatrate or rent data
        final results = data['results'] as Map<String, dynamic>;
        print(results);
        for (var country in results.keys) {
          var countryData = results[country];

          // Check for flatrate providers first
          if (countryData != null && countryData['flatrate'] != null &&
              countryData['flatrate'].isNotEmpty) {
            final providers = countryData['flatrate'] as List;
            print('Flatrate providers found: $providers');
            return providers.map((json) => WatchProvider.fromJson(json))
                .toList();
          }

          // If no flatrate providers, check for rent providers
          if (countryData != null && countryData['rent'] != null &&
              countryData['rent'].isNotEmpty) {
            final rentProviders = countryData['rent'] as List;
            print('Rent providers found: $rentProviders');
            return rentProviders.map((json) => WatchProvider.fromJson(json))
                .toList();
          }
        }
      }
      return null; // Return null if no providers found
    } catch (e) {
      print('Error fetching watch providers: $e');
      return null; // Return null on error
    }
  }

  Future<OmdbMovieDetails> fetchMovieDetails(String imdbId) async {
    try {
      final omdbApiUrl = 'https://omdbapi.com/?i=$imdbId&apikey=8a1fb07b';
      final omdbResponse = await http.get(Uri.parse(omdbApiUrl));

      if (omdbResponse.statusCode == 200) {
        final omdbData = json.decode(omdbResponse.body);

        if (omdbData['Response'] == 'True') {
          return OmdbMovieDetails.fromJson(imdbId, omdbData);
        } else {
          throw Exception('Error from OMDB: ${omdbData['Error']}');
        }
      } else {
        throw Exception(
            'Failed to load movie details, Status Code: ${omdbResponse
                .statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to fetch movie details: $error');
    }
  }

  Future<Map<String, List>> fetchCastAndCrew(int movieId) async {
    final url = Uri.parse(
        'https://api.themoviedb.org/3/movie/$movieId/credits?api_key=e245e9ec8ac73a4f3fcbfbcd944f872d');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      List<CastMember> cast = (data['cast'] as List)
          .map((json) => CastMember.fromJson(json))
          .toList();
      List<CrewMember> crew = (data['crew'] as List)
          .map((json) => CrewMember.fromJson(json))
          .toList();

      return {'cast': cast, 'crew': crew};
    } else {
      throw Exception('Failed to fetch data');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _movieDetailsWithOmdb,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data found.'));
          } else {
            final movie = snapshot.data!["tmdb"] as details.MovieDetailsModels;
            final omdb = snapshot.data!["omdb"] as OmdbMovieDetails;
            return LayoutBuilder(
              builder: (context, constraints) {
                // For Desktop Layout (Wide Screens)
                if (constraints.maxWidth > 600) {
                  return _buildDesktopLayout(movie, omdb);
                } else {
                  // Mobile Layout (Narrow Screens)
                  return _buildMobileLayout(movie, omdb);
                }
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildMobileLayout(details.MovieDetailsModels movie,
      OmdbMovieDetails omdb) {
    return Column(
      children : [
        mobileNavBar(context),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _topContainerMobile(
                    movie.backdropPath, movie.title, movie.posterPath),
                SizedBox(height: 20.0,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: _movieDetailsMobile(
                      movie.posterPath,
                      movie.title,
                      omdb.director,
                      movie.releaseDate,
                      movie.runtime.toString(),
                      omdb.genre,
                      omdb.imdbRating,
                      omdb.rottenTomatoesRating,
                      movie.overview),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: YouTubePlayerWidget(movieId: movie.id.toString(),),
                ),
                const SizedBox(height: 30.0,),
                _watchProviderList(movie.id, movie.title),
                const SizedBox(height: 40.0,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Production Companies',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: SizedBox(
                          height: 50.0,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: movie.productionCompanies.length,
                            itemBuilder: (context, index) {
                              final company = movie.productionCompanies[index];
                              return Container(
                                margin: const EdgeInsets.only(right: 8.0),
                                // Add margin between items
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 10.0),
                                  child: Text(
                                    company.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      )

                    ],
                  ),
                ),
                const SizedBox(height: 40.0,),
                Container(
                  color: Colors.white10,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text(
                          'About the Movie',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        _aboutMovieList('Original name', movie.originalTitle),
                        _divider(),
                        _aboutMovieList('Directed by', omdb.director),
                        _divider(),
                        _aboutMovieList(
                            'Original Language', movie.originalLanguage),
                        _divider(),
                        _aboutMovieList('Status', movie.status),
                        _divider(),
                        _aboutMovieList('Release Date', movie.releaseDate),
                        _divider(),
                        _aboutMovieList('Tagline',
                            movie.tagline.isEmpty ? '-' : movie.tagline),
                      ],
                    ),),
                ),
                _cast(movie.title, 15, 20.0),
                _posterImages(),
                MovieRow(
                    movieType: 'recommendations', movieId: movie.id.toString())
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return const Divider(
      thickness: 1.0,
      color: Colors.white54,
      indent: 3.0,
      endIndent: 3.0,);
  }

  Widget _aboutMovieList(String title, String info) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 20.0,),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white,
          ),
        ),
        Text(
          info,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 10.0,),

      ],
    );
  }


  Widget _topContainerMobile(String bgImg, String title, String poster) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          // Allows the poster to extend outside the stack
          children: [
            SizedBox(
              height: 200,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8.0),
                  bottomLeft: Radius.circular(8.0),
                ),
                child: Image.network(
                  'https://image.tmdb.org/t/p/w500$bgImg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.5),
                      Colors.black,
                    ],
                    stops: [0.1, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 150.0, // Adjust position to bring the poster in front
              left: 20.0,
              child: Container(
                width: 140,
                height: 200,
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  child: Image.network(
                    'https://image.tmdb.org/t/p/w500$poster',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }


  Widget _movieDetailsMobile(String posterPath, String title, String director,
      String releaseDate, String runTime, String genre, String imdbRating,
      String rotnTmtoesRating, String overview) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 160, top: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/imdb_logo.png',
                    height: 25,
                    width: 45,
                    fit: BoxFit.contain,
                  ),
                  Text(
                    imdbRating,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                  height: 10.0),
              // Space between IMDb and Rotten Tomatoes ratings
              Row(
                children: [
                  Image.asset(
                    'assets/rt_logo.png',
                    height: 20,
                    width: 40,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 2.0),
                  Text(
                    rotnTmtoesRating,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),),
        Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.left,
              ),
              Text(
                'Directed by $director',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              releaseDate.split('-')[0],
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 15),
            Text(
              calculateRuntime(runTime.toString()),
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          genre,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const SizedBox(height: 16),
        // Gap before overview
        const Text(
          'Overview',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          overview,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 20),
        // Gap after overview
      ],
    );
  }


  Widget _buildDesktopLayout(details.MovieDetailsModels movie,
      OmdbMovieDetails omdb) {
    return Column(
      children: [
        NavBar(),
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topContainer(movie.backdropPath, movie.title, 300, 70),
                  const SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: Image.network(
                            'https://image.tmdb.org/t/p/w500${movie
                                .posterPath}',
                            fit: BoxFit.cover,
                            height: 350,
                            width: 250,
                          ),
                        ),
                        const SizedBox(width: 40.0),
                        _movieBasicDetails(
                            movie.title,
                            omdb.director,
                            movie.releaseDate,
                            movie.runtime.toString(),
                            omdb.genre,
                            omdb.imdbRating,
                            omdb.rottenTomatoesRating,
                            movie.overview)
                      ],
                    ),
                  ),
                  const SizedBox(height: 50.0,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: _watchProviderList(movie.id, movie.title),
                  ),
                  const SizedBox(height: 50.0,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: YouTubePlayerWidget(movieId: movie.id.toString()),
                  ),
                  const SizedBox(height: 50.0,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Production Companies',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: movie.productionCompanies.map((company) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 10.0),
                                  child: Text(
                                    company.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50.0,),
                  _cast(movie.title, 40.0, 20.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: _posterImages(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: MovieRow(
                      movieType: 'recommendations', movieId: movie.title,),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _cast(String movieName, double symmetricHor, double symmetricVer) {
    return Container(
      color: Colors.blue.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: symmetricHor, vertical: symmetricVer),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cast of $movieName',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 250,
              child: FutureBuilder<Map<String, List>>(
                future: _castAndCrewFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    final cast = snapshot.data!['cast'] as List<CastMember>;

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: cast.length,
                      itemBuilder: (context, index) {
                        final member = cast[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          width: 100,
                          child: Column(
                            children: [
                              Container(
                                height: 150,
                                width: 150,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      width: 1.0, color: Colors.white12),
                                  image: member.profilePath != null
                                      ? DecorationImage(
                                    image: NetworkImage(
                                        'https://image.tmdb.org/t/p/w92${member
                                            .profilePath}'),
                                    fit: BoxFit.cover,
                                  )
                                      : null,
                                  color: Colors.grey.shade300,
                                ),
                                child: member.profilePath == null
                                    ? const Icon(Icons.person, size: 50)
                                    : null,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                member.originalName,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '(${member.character})',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text('No cast data available'));
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Crew',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 100,
              child: FutureBuilder<Map<String, List>>(
                future: _castAndCrewFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    final crew = snapshot.data!['crew'] as List<CrewMember>;

                    if (crew.isEmpty) {
                      return const Center(
                          child: Text('No crew data available'));
                    }
                    return ListView.builder(
                      scrollDirection: Axis.horizontal, // Horizontal scrolling
                      itemCount: crew.length,
                      itemBuilder: (context, index) {
                        final member = crew[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white12),
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: Colors.white10,
                                ),
                                width: 200,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0, vertical: 4.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(height: 10),
                                      Text(
                                        member.originalName,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        member.job,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text('No crew data available'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _watchProviderList(int movieId, String movieName) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'Where to Watch $movieName',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 5.0,),
          SizedBox(
            height: 100,
            child: FutureBuilder(
              future: fetchWatchProviders(movieId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text(
                    'We are having trouble finding the watch provider.',
                    style: TextStyle(color: Colors.white, fontSize: 12.0),));
                }
                final providers = snapshot.data!;
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: providers.length,
                  itemBuilder: (context, index) {
                    final provider = providers[index];
                    final logoUrl = 'https://image.tmdb.org/t/p/w200${provider
                        .logoPath}';
                    final providerName = provider.providerName;
                    return Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 15.0, right: 30.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 70,
                                  height: 80,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      image: DecorationImage(
                                          image: NetworkImage(logoUrl),
                                          fit: BoxFit.cover)
                                  ),
                                ),
                                const SizedBox(width: 15.0),
                                SizedBox(
                                  child: Text(
                                    providerName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // if (index != providers.length - 1)
                        const SizedBox(width: 10),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _topContainer(String bgImg, String title, double height,
      double fntSize) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Stack(
        children: [
          // Background Backdrop Image
          SizedBox(
            height: height,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8.0),
                bottomLeft: Radius.circular(8.0),
              ),
              child: Image.network(
                'https://image.tmdb.org/t/p/w500$bgImg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Gradient Overlay
          Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black,
                  Colors.blue.withOpacity(0.5),
                ],
              ),
            ),
          ),
          Positioned(
            child: Text(
              title,
              style: TextStyle(
                fontSize: fntSize,
                fontWeight: FontWeight.bold,
                color: Colors.white54,
              ),
              maxLines: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _movieBasicDetails(String title, String director, String releaseDate,
      String runTime, String genre, String imdbRating, String rotnTmtoesRating,
      String overview) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'Directed by $director',
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                releaseDate.split('-')[0],
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(width: 15),
              Text(
                calculateRuntime(runTime.toString()),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(width: 15),
              Text(
                genre,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/imdb_logo.png',
                    height: 20,
                    width: 40,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    imdbRating,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20.0),
              // Space between IMDb and Rotten Tomatoes ratings
              Row(
                children: [
                  Image.asset(
                    'assets/rt_logo.png',
                    height: 20,
                    width: 40,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    rotnTmtoesRating,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16), // Gap before overview
          const Text(
            'Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            overview,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 20), // Gap after overview
        ],
      ),
    );
  }

  Widget _posterImages() {
    bool isDesktop = MediaQueryData
        .fromWindow(WidgetsBinding.instance.window)
        .size
        .width > 800;
    int posterCount = posters.length;
    int backdropCount = backdrops.length;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: SizedBox(
        height: isDesktop ? 400 : 250,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 15.0),
                  child: Text('Media', style: TextStyle(fontSize: 20.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),),
                ),
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  indicatorColor: Colors.white,
                  indicatorPadding: const EdgeInsets.symmetric(vertical: 10.0),
                  dividerHeight: 0.0,
                  tabs: [
                    Tab(
                      child: Row(
                        children: [
                          Text(
                            'Backdrops',
                            style: TextStyle(
                              fontSize: isDesktop ? 18 : 12,
                              // Dynamic font size
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 5.0,),
                          Text(
                            backdropCount.toString(),
                            style: TextStyle(
                                fontSize: isDesktop ? 14 : 9,
                                // Dynamic font size
                                fontWeight: FontWeight.bold,
                                color: Colors.white54
                            ),
                          ),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        children: [
                          Text(
                            'Posters',
                            style: TextStyle(
                              fontSize: isDesktop ? 18 : 12,
                              // Dynamic font size
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 5.0,),
                          Text(
                            posterCount.toString(),
                            style: TextStyle(
                                fontSize: isDesktop ? 14 : 9,
                                // Dynamic font size
                                fontWeight: FontWeight.bold,
                                color: Colors.white54

                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _imgPosterRow(backdrops, isPoster: false),
                  _imgPosterRow(posters, isPoster: true)
                ],
              ),
            ),
          ],
        ),
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
                    child: Text('Home',
                      style: TextStyle(color: Colors.white, fontSize: 15.0),),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _imgPosterRow(List<String> img, {bool isPoster = false}) {
    if (img.isEmpty) {
      return const Center(
        child: Text(
          'No images available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800; // Desktop if width > 800
        final imageHeight = isPoster
            ? (isDesktop
            ? 300.0
            : 200.0) // Larger height for posters on desktop
            : (isDesktop
            ? 400.0
            : 250.0); // Larger height for backdrops on desktop
        final imageWidth = isPoster
            ? (isDesktop ? 200.0 : 120.0) // Narrower width for posters
            : (isDesktop ? 600.0 : 300.0); // Wider width for backdrops

        return SizedBox(
          height: imageHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: img.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // Handle image tap
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.network(
                      img[index],
                      fit: BoxFit.cover,
                      width: imageWidth,
                      height: imageHeight,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

  String calculateRuntime(String runtimeString) {
    int runtime = int.parse(runtimeString.split(' ')[0]);
    int findHours = runtime ~/ 60;
    int findMinutes = runtime - findHours * 60;
    String runTime = '$findHours hrs $findMinutes min';
    return runTime;
  }

