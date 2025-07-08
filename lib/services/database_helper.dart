import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/review.dart';

class DatabaseHelper {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    final path = join(await getDatabasesPath(), 'reviews.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE reviews(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            movieId INTEGER,
            rating REAL,
            comment TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertReview(Review review) async {
    final db = await database;
    await db.insert('reviews', review.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Review>> getReviewsForMovie(int movieId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('reviews', where: 'movieId = ?', whereArgs: [movieId]);

    return List.generate(maps.length, (i) => Review.fromMap(maps[i]));
  }



  Future<double> getAverageRating(int movieId) async {
  final db = await database;
  final result = await db.rawQuery(
    'SELECT AVG(rating) as avgRating FROM reviews WHERE movieId = ?',
    [movieId],
  );

  final avg = result.first['avgRating'];
  return avg == null ? 0.0 : double.parse(avg.toString());
}

}
