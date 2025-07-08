import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/genre.dart';

class GenreService {
  final String apiKey = "b6036fa7c500a67e44717c00993f6073";

  Future<List<Genre>> fetchGenres() async {
    final url = Uri.parse(
        'https://api.themoviedb.org/3/genre/movie/list?api_key=$apiKey&language=en-US');

    final response = await http.get(url);

print("Status Code: ${response.statusCode}");
print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List genresJson = data['genres'];
      return genresJson.map((e) => Genre.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load genres");
    }
  }
}
