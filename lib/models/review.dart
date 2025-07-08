class Review {
  final int? id; 
  final int movieId;
  final double rating;
  final String comment;
  
  Review({
    this.id,
    required this.movieId,
    required this.rating,
    required this.comment,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'movieId': movieId,
      'rating': rating,
      'comment': comment,
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'],
      movieId: map['movieId'],
      rating: map['rating'],
      comment: map['comment'],
    );
  }
}