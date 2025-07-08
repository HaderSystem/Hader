import '../models/MovieModel.dart';
import '../services/api_service.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/MovieModel.dart';

class MovieController {
  final String apiKey = 'b6036fa7c500a67e44717c00993f6073'; // بدليه بمفتاحك الحقيقي

  Future<List<Movie>> fetchMoviesByPage(int page) async {
    final url = Uri.parse(
        "https://api.themoviedb.org/3/discover/movie?api_key=$apiKey&language=en-US&page=$page");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['results'];
      return results.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception("Failed to fetch movies from page $page");
    }
  }

  Future<List<Movie>> getAllMovies() async {
    List<Movie> all = [];
    for (int page = 1; page <= 3; page++) {
      final result = await fetchMoviesByPage(page);
      all.addAll(result);
    }
    return all;
  }
}
/* 

class MovieController {
  final ApiService apiService = ApiService();

  Future<List<Movie>> getRecommendedMovies() async {
    return await apiService.fetchRecommendedMovies();
  }
Future<List<Movie>> getMoviesByGenre(int genreId) async {
  return await apiService.fetchMoviesByGenre(genreId);
}



Future<List<Movie>> getAllMovies() async {
  List<Movie> all = [];

  // مثلًا نحمل أول 3 صفحات (60 فيلم)
  for (int page = 1; page <= 3; page++) {
    final result = await fetchMoviesByPage(page); // دالة من tmdb API
    all.addAll(result);
  }

  return all;
}

}
 */