class Movie {
  final int id;
  final String title;
  final String posterUrl;
  final List<String> genre;
  final String? overview;
  final List<int> genreIds;

  Movie({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.genre,
    this.overview,
     required this.genreIds,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      posterUrl: 'https://image.tmdb.org/t/p/w500${json['poster_path']}',
   //   genre: List<String>.from(json['genre_ids'].map((e) => e.toString())),
     genre: [],
      overview: json['overview'],
      genreIds: List<int>.from(json['genre_ids'] ?? []),
    );
  }
}
