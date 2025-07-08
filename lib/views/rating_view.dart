import 'package:flutter/material.dart';
import '../models/review.dart';
import '../services/database_helper.dart';
import '../models/MovieModel.dart';

class RatingView extends StatefulWidget {
  final Movie movie;
  RatingView({required this.movie});

  @override
  State<RatingView> createState() => _RatingViewState();
}

class _RatingViewState extends State<RatingView> {
  double _rating = 3.0;
  final TextEditingController _commentController = TextEditingController();
  final dbHelper = DatabaseHelper();

  void _saveReview() async {
    final review = Review(
      movieId: widget.movie.id,
      rating: _rating,
      comment: _commentController.text,
    );

    await dbHelper.insertReview(review);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Review saved!")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Rate ${widget.movie.title}")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Your Rating", style: TextStyle(fontSize: 18)),
            Slider(
              min: 1,
              max: 5,
              divisions: 4,
              label: _rating.toString(),
              value: _rating,
              onChanged: (val) {
                setState(() {
                  _rating = val;
                });
              },
            ),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(labelText: "Your Comment"),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveReview,
              child: Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
