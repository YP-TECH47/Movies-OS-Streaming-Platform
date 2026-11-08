import 'package:flutter/foundation.dart';
import '../models/movie.dart';
import '../core/api_service.dart';

class MovieProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Movie> trendingMovies = [];
  List<Movie> topRatedMovies = [];
  List<Movie> upcomingMovies = [];
  List<Movie> actionMovies = [];
  List<Movie> comedyMovies = [];
  List<Movie> romanceMovies = [];
  
  List<Movie> searchResults = [];
  bool isLoading = false;
  bool isSearching = false;

  Future<void> loadHomeScreenData() async {
    isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _apiService.getTrendingMovies(),
        _apiService.getTopRatedMovies(),
        _apiService.getUpcomingMovies(),
        _apiService.getActionMovies(),
        _apiService.getComedyMovies(),
        _apiService.getRomanceMovies(),
      ]);

      trendingMovies = results[0];
      topRatedMovies = results[1];
      upcomingMovies = results[2];
      actionMovies = results[3];
      comedyMovies = results[4];
      romanceMovies = results[5];
    } catch (e) {
      debugPrint('Error loading home screen data: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchMovies(String query) async {
    if (query.isEmpty) {
      searchResults = [];
      notifyListeners();
      return;
    }

    isSearching = true;
    notifyListeners();

    try {
      searchResults = await _apiService.searchMovies(query);
    } catch (e) {
      debugPrint('Error searching movies: $e');
    } finally {
      isSearching = false;
      notifyListeners();
    }
  }

  Future<void> searchMoviesByGenre(int genreId) async {
    isSearching = true;
    notifyListeners();

    try {
      searchResults = await _apiService.getMoviesByGenre(genreId);
    } catch (e) {
      debugPrint('Error searching movies by genre: $e');
    } finally {
      isSearching = false;
      notifyListeners();
    }
  }
}
