import 'package:comicsapp/features/home/domain/entities/story.dart';

abstract class SearchRepository {
  /// Searches for stories based on a query string.
  Future<List<Story>> searchStories(String query);
}
