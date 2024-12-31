import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:movie_tracker/models/poster_models.dart';
import 'package:movie_tracker/models/view_all_movie_model.dart';
import '../models/movie_details_models.dart';
import '../models/movie_list_model.dart';

class TmdbService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _apiKey = 'e245e9ec8ac73a4f3fcbfbcd944f872d';


  static Future<Map<String, dynamic>> getMovies({
    int page = 1,
    String movieId = '',
    required String movieType,
    required String category,
  }) async {
    String language = 'en-US';
    String endpoint;

    if (movieType  == 'recommendations') {
      endpoint = '/movie/$movieId/';
      language = '';
    } else if (category == 'movie') {
      endpoint = '/movie/';
    } else if (category == 'tv') {
      endpoint = '/tv/';
    } else {
      throw Exception('Invalid category: $category');
    }

    final Uri url = Uri.parse(
      '$_baseUrl$endpoint$movieType?api_key=$_apiKey&language=&page=$page${language != '' ? '&language=$language': ''}',
    );
    print('Requesting URL: $url');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error Response: ${response.body}');
        throw Exception('Failed to load data. Status code: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No Internet connection. Please check your network.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again later.');
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }


  static Future<List<MovieList>> getMoviesList({
    int page = 1,
    required String movieType,
    required String category,
  }) async {
    String url;

    if (category == 'movie') {
      url = '$_baseUrl/movie/$movieType?api_key=$_apiKey&language=en-US&page=$page';
    } else if (category == 'tv') {
      url = '$_baseUrl/tv/$movieType?api_key=$_apiKey&language=en-US&page=$page';
    } else {
      throw Exception('Invalid category: $category');
    }

    print('Requesting URL: $url');

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Parse the JSON response to a list of MovieList objects
        return (data['results'] as List)
            .map((item) => MovieList.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to load movies: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching data: $error');
    }
  }


  static Future<List<MovieList>> getSuggestionMovies(String movieId) async {
    final url = '$_baseUrl/movie/$movieId/recommendations?$_apiKey&language=en-US&page=1';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List).map((item) => MovieList.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load movies: ${response.statusCode}');
    }
  }

  static Future<List<Movie>> getTamilMovies({int page = 1, String language = 'ta'}) async {
    const String endpoint = '/discover/movie';
    final Uri url = Uri.parse(
        '$_baseUrl$endpoint?api_key=$_apiKey&with_original_language=$language&sort_by=popularity.desc&page=$page');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load Tamil movies');
      }
    } catch (e) {
      throw Exception('Failed to load Tamil movies: $e');
    }
  }



  static Future<List<Poster>> getBackgroundImages({required String movieId}) async {
    String endpoint = '/movie/$movieId/images';
    final Uri url = Uri.parse('$_baseUrl$endpoint?api_key=$_apiKey');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> backdropJson = data['backdrops'];

        return backdropJson.map((json) => Poster.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load background images');
      }
    } catch (e) {
      print('Error fetching background images: $e');
      rethrow;
    }
  }

  static Future<MovieDetailsModels> getMovieDetails(int movieId) async {
    final url = 'https://api.themoviedb.org/3/movie/$movieId?api_key=$_apiKey&language=en-US';
    print('Requesting URL: $url');
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return MovieDetailsModels.fromJson(jsonData); // Use details.Movie here
    } else {
      throw Exception('Failed to load movie details');
    }
  }

  static Future<String?> fetchTrailer(String movieId) async {
    final urlTa =
        'https://api.themoviedb.org/3/movie/$movieId/videos?api_key=e245e9ec8ac73a4f3fcbfbcd944f872d&language=ta';
    try {
      final responseTa = await http.get(Uri.parse(urlTa));
      if (responseTa.statusCode == 200) {
        final data = json.decode(responseTa.body);
        final results = data['results'];
        if (results != null && results.isNotEmpty) {
          for (var video in results) {
            if (video['type'] == 'Trailer') {
              return video['key'];
            }
          }
        }
      } else {
        print('Failed to fetch Tamil trailer');
      }
    } catch (e) {
      print('Error fetching Tamil trailer: $e');
    }

    final urlEn =
        'https://api.themoviedb.org/3/movie/$movieId/videos?api_key=e245e9ec8ac73a4f3fcbfbcd944f872d&language=en';

    try {
      final responseEn = await http.get(Uri.parse(urlEn));
      if (responseEn.statusCode == 200) {
        final data = json.decode(responseEn.body);
        final results = data['results'];

        if (results != null && results.isNotEmpty) {
          for (var video in results) {
            if (video['type'] == 'Trailer') {
              return video['key'];
            }
          }
        }
      } else {
        print('Failed to fetch English trailer');
      }
    } catch (e) {
      print('Error fetching English trailer: $e');
    }
    return null;
  }



}
