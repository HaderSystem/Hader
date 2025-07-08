import 'package:flutter/material.dart';
import '../controllers/MovieController.dart';
import '../models/genre.dart';
import '../models/MovieModel.dart';
import '../services/genre_service.dart';
import 'movie_details_view.dart';

class HomeView extends StatefulWidget {
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final MovieController controller = MovieController();

  List<Movie> allMovies = [];          // كل الأفلام من TMDB
  List<Movie> displayedMovies = [];    // اللي بنعرضهم بناءً على البحث/الفلترة
  List<Genre> genres = [];

  int? selectedGenreId;
  String searchQuery = '';

  final GenreService genreService = GenreService();

  @override
  void initState() {
    super.initState();
    fetchGenres();
    fetchAllMovies();
  }

  Future<void> fetchGenres() async {
    final g = await genreService.fetchGenres();
    setState(() {
      genres = g;
    });
  }

  Future<void> fetchAllMovies() async {
    final movies = await controller.getAllMovies(); // لازم تكون معرفها
    setState(() {
      allMovies = movies;
      displayedMovies = movies;
    });
  }

  void filterMovies() {
    List<Movie> filtered = allMovies;

    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((movie) =>
          movie.title.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }

    if (selectedGenreId != null) {
      filtered = filtered.where((movie) =>
          movie.genreIds.contains(selectedGenreId)).toList();
    }

    setState(() {
      displayedMovies = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        title: Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) {
                  searchQuery = value;
                  filterMovies();
                },
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search movies...",
                  hintStyle: TextStyle(color: Colors.white54),
                  prefixIcon: Icon(Icons.search, color: Colors.white),
                  filled: true,
                  fillColor: Colors.blueGrey[700],
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Text(
              "Movie App",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          //  Genres Bar
          Container(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: genres.length,
              itemBuilder: (context, index) {
                final genre = genres[index];
                final isSelected = selectedGenreId == genre.id;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ChoiceChip(
                    label: Text(genre.name),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        selectedGenreId =
                            isSelected ? null : genre.id;
                      });
                      filterMovies();
                    },
                  ),
                );
              },
            ),
          ),

          //  Movies List
          Expanded(
            child: displayedMovies.isEmpty
                ? Center(child: Text("No movies found."))
                : ListView.builder(
                    itemCount: displayedMovies.length,
                    itemBuilder: (context, index) {
                      final movie = displayedMovies[index];
                      return ListTile(
                        leading: Image.network(
                          movie.posterUrl,
                          width: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(movie.title),
                        subtitle: Text(movie.genre.join(", ")),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MovieDetailsView(movie: movie),
                            ),
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
}
