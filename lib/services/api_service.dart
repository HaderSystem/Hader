import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/MovieModel.dart';

class ApiService {
  final String apiKey = "b6036fa7c500a67e44717c00993f6073"; 

  Future<List<Movie>> fetchRecommendedMovies() async {
    final url = Uri.parse(
        "https://api.themoviedb.org/3/movie/popular?api_key=$apiKey&language=en-US&page=1");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List movies = data['results'];
      return movies.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception("Failed to fetch movies");
    }
  }
  Future<List<Movie>> fetchMoviesByGenre(int genreId) async {
    
  final url = Uri.parse(
      "https://api.themoviedb.org/3/discover/movie?api_key=$apiKey&language=en-US&with_genres=$genreId");

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final List movies = data['results'];
    return movies.map((json) => Movie.fromJson(json)).toList();
  } else {
    throw Exception("Failed to fetch movies by genre");
  }

}

}

/* 
Future<List<Movie>> fetchMoviesByGenre(int genreId) async {
  final url = Uri.parse(
      "https://api.themoviedb.org/3/discover/movie?api_key=$apiKey&language=en-US&with_genres=$genreId");

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final List movies = data['results'];
    return movies.map((json) => Movie.fromJson(json)).toList();
  } else {
    throw Exception("Failed to fetch movies by genre");
  }
}
 */