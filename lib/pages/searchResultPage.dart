import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:responsive_builder/responsive_builder.dart';
import 'dart:convert';
import '../models/movie_list_model.dart';
import 'package:movie_tracker/pages/movieDetailsPage.dart';
import 'package:movie_tracker/components/navBar.dart';
import 'package:movie_tracker/utils/colors.dart';

class SearchResultsPage extends StatefulWidget {
  final String query;

  const SearchResultsPage({Key? key, required this.query}) : super(key: key);

  @override
  _SearchResultsPageState createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  bool isLoading = true;
  List<Movie> searchResults = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.query; // Set initial query
    searchMovies(widget.query);
  }

  Future<void> searchMovies(String query) async {
    final url =
        'https://api.themoviedb.org/3/search/movie?query=${Uri.encodeComponent(query)}&api_key=e245e9ec8ac73a4f3fcbfbcd944f872d&include_adult=false&region=IN&page=1';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          searchResults = (data['results'] as List)
              .map((movie) => Movie.fromJson(movie))
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception(
            'Failed to fetch search results. Status: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  String extractYear(String date) {
    int dashIndex = date.indexOf('-');
    if (dashIndex != -1) {
      return date.substring(0, dashIndex);
    }
    return date;
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: mobileSearchScreen(),
      desktop: desktopSearchScreen(),
    );
  }

  Widget mobileSearchScreen() {
    return Scaffold(
      backgroundColor: AppColors.searchScreenColor,
      body: _body(20.0),
    );
  }

  Widget desktopSearchScreen() {
    return Scaffold(
      backgroundColor: AppColors.searchScreenColor,
      body: _body(120.0),
    );
  }


  Widget _body(double padHor){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NavBar(),
        SizedBox(height: 15.0,),
        Padding(
          padding:  EdgeInsets.symmetric(horizontal: padHor),
          child: Text("Showing results for \"${widget.query}\"",
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,),
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : searchResults.isNotEmpty
              ? ListView.builder(
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              final movie = searchResults[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MovieDetailsScreen(movieId: movie.id),
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: padHor,),
                  child: Column(
                  children: [
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.white,
                    ),
                    Container(
                      color: Color(0xFF243642),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            movie.posterPath != null
                                ? Image.network(
                              'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                              width: 80.0,
                              height: 130.0,
                              fit: BoxFit.cover,
                            )
                                : Container(
                              width: 80.0,
                              height: 130.0,
                              color: Colors.grey,
                              child: Center(
                                child: Text(
                                  movie.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    movie.title,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow:
                                    TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 10.0),
                                  Text(
                                    movie.year != null
                                        ? extractYear(
                                        movie.year.toString())
                                        : 'Unknown Year',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 10.0),
                                  Text(
                                    movie.overView.toString(),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                ),
              );
            },
          )
              : const Center(
            child: Text(
              'No results found',
              style:
              TextStyle(color: Colors.white, fontSize: 18.0),
            ),
          ),
        ),
      ],
    );
  }
}
