import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TMDBService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://api.themoviedb.org/3';

  Future<String> _getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('tmdb_api_key') ?? '';
  }

  Future<Map<String, dynamic>?> searchMovie(String title, int? year) async {
    try {
      final _apiKey = await _getApiKey();
      if (_apiKey.isEmpty) {
        print('TMDB API key not set.');
        return null;
      }
      final response = await _dio.get(
        '$_baseUrl/search/movie',
        queryParameters: {'api_key': _apiKey, 'query': title, 'year': year},
      );
      final results = response.data['results'] as List;
      if (results.isNotEmpty) {
        return results.first as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error searching movie: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> searchShow(String title, int? year) async {
    try {
      final apiKey = await _getApiKey();
      if (apiKey.isEmpty) {
        print('TMDB API key not set.');
        return null;
      }
      final response = await _dio.get(
        '$_baseUrl/search/tv',
        queryParameters: {
          'api_key': apiKey,
          'query': title,
          'first_air_date_year': year,
        },
      );
      final results = response.data['results'] as List;
      if (results.isNotEmpty) {
        return results.first as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error searching show: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getMovieDetails(int tmdbId) async {
    try {
      final apiKey = await _getApiKey();
      if (apiKey.isEmpty) {
        print('TMDB API key not set.');
        return null;
      }
      final response = await _dio.get(
        '$_baseUrl/movie/$tmdbId',
        queryParameters: {
          'api_key': apiKey,
          'append_to_response': 'credits,release_dates',
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('Error getting movie details: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getShowDetails(int tmdbId) async {
    try {
      final apiKey = await _getApiKey();
      if (apiKey.isEmpty) {
        print('TMDB API key not set.');
        return null;
      }
      final response = await _dio.get(
        '$_baseUrl/tv/$tmdbId',
        queryParameters: {
          'api_key': apiKey,
          'append_to_response': 'credits,content_ratings',
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('Error getting show details: $e');
      return null;
    }
  }
}
