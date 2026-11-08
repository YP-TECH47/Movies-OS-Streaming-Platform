import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../models/movie.dart';
import '../models/movie_detail.dart';
import 'api_constants.dart';

class ApiService {
  final String apiKey = ApiConstants.apiKey;
  final String baseUrl = ApiConstants.baseUrl;

  Future<List<Movie>> getTrendingMovies() async {
    return _fetchMovies('/trending/movie/day');
  }

  Future<List<Movie>> getTopRatedMovies() async {
    return _fetchMovies('/movie/top_rated');
  }

  Future<List<Movie>> getUpcomingMovies() async {
    return _fetchMovies('/movie/upcoming');
  }

  Future<List<Movie>> getActionMovies() async {
    return _fetchMovies('/discover/movie', queryParams: '&with_genres=28');
  }

  Future<List<Movie>> getComedyMovies() async {
    return _fetchMovies('/discover/movie', queryParams: '&with_genres=35');
  }

  Future<List<Movie>> getRomanceMovies() async {
    return _fetchMovies('/discover/movie', queryParams: '&with_genres=10749');
  }

  Future<List<Movie>> getMoviesByGenre(int genreId) async {
    return _fetchMovies('/discover/movie', queryParams: '&with_genres=$genreId');
  }

  Future<List<Movie>> searchMovies(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search/movie?api_key=$apiKey&query=$query'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['results'] as List)
            .map((movie) => Movie.fromJson(movie))
            .where((movie) => movie.posterPath.isNotEmpty)
            .toList();
      }
    } catch (e) {
      log('Error searching movies: $e');
    }
    return [];
  }

  Future<MovieDetail?> getMovieDetails(int movieId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/movie/$movieId?api_key=$apiKey'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return MovieDetail.fromJson(data);
      }
    } catch (e) {
      log('Error getting movie details: $e');
    }
    return null;
  }

  Future<List<Movie>> getSimilarMovies(int movieId) async {
    return _fetchMovies('/movie/$movieId/similar');
  }

  Future<String?> getMovieTrailerKey(int movieId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/movie/$movieId/videos?api_key=$apiKey'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        
        
        final trailer = results.firstWhere(
          (video) => video['site'] == 'YouTube' && video['type'] == 'Trailer',
          orElse: () => null,
        );
        
        if (trailer != null) {
          return trailer['key'];
        } else if (results.isNotEmpty) {
           return results[0]['key'];
        }
      }
    } catch (e) {
      log('Error getting movie trailer: $e');
    }
    return null;
  }

  Future<List<Movie>> _fetchMovies(String endpoint, {String queryParams = ''}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint?api_key=$apiKey$queryParams'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['results'] as List)
            .map((movie) => Movie.fromJson(movie))
            .where((movie) => movie.posterPath.isNotEmpty) // the movie without posters will be excluded
      } else {
        log('Failed to load movies from $endpoint: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      log('Error fetching movies from $endpoint: $e');
      return [];
    }
  }
}
