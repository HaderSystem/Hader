import 'package:flutter/material.dart';
import '../models/MovieModel.dart';
import '../models/review.dart';
import '../services/database_helper.dart';
import 'rating_view.dart';

class MovieDetailsView extends StatefulWidget {
  final Movie movie;

  MovieDetailsView({required this.movie});

  @override
  State<MovieDetailsView> createState() => _MovieDetailsViewState();
}

class _MovieDetailsViewState extends State<MovieDetailsView> {
  final dbHelper = DatabaseHelper();

  Future<List<Review>>? _reviewsFuture;
  Future<double>? _averageFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = dbHelper.getReviewsForMovie(widget.movie.id);
    _averageFuture = dbHelper.getAverageRating(widget.movie.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.movie.title)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(widget.movie.posterUrl),
            SizedBox(height: 10),
            Text(
              widget.movie.title,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.movie.genre.join(" • "),
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 10),

            // زرار التشغيل والتنزيل والتقييم
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.play_arrow),
                    label: Text("Play"),
                    onPressed: () {},
                  ),
                  OutlinedButton.icon(
                    icon: Icon(Icons.download),
                    label: Text("Download"),
                    onPressed: () {},
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.star),
                    label: Text("Rate this movie"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RatingView(movie: widget.movie),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                widget.movie.overview ?? 'No description available.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),

            // المتوسط وعدد التقييمات
            FutureBuilder<double>(
              future: _averageFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return SizedBox();
                double avg = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    "⭐ ${avg.toStringAsFixed(1)} / 5.0",
                    style: TextStyle(fontSize: 18, color: Colors.orange),
                  ),
                );
              },
            ),

            Divider(),

            // تعليقات المستخدمين
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "User Reviews",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            FutureBuilder<List<Review>>(
              future: _reviewsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return CircularProgressIndicator();
                if (!snapshot.hasData || snapshot.data!.isEmpty)
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("No reviews yet."),
                  );

                final reviews = snapshot.data!;
                return Column(
                  children: reviews.map((r) {
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: Icon(Icons.person),
                        title: Text("⭐ ${r.rating}"),
                        subtitle: Text(r.comment),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            SizedBox(height: 20),

            // Tabs
            DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    labelColor: Colors.black,
                    tabs: [
                      Tab(text: "Trailer"),
                      Tab(text: "Similar"),
                      Tab(text: "About"),
                    ],
                  ),
                  Container(
                    height: 200,
                    child: TabBarView(
                      children: [
                        Center(child: Text("Trailer Coming Soon")),
                        Center(child: Text("Similar Movies Placeholder")),
                        Center(child: Text("About the Movie")),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
