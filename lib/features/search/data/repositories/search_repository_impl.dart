import 'package:comicsapp/features/home/domain/entities/story.dart';
import 'package:comicsapp/features/search/domain/repositories/search_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SupabaseClient supabaseClient;

  SearchRepositoryImpl(this.supabaseClient);

  @override
  Future<List<Story>> searchStories(String query) async {
    try {
      // Use .ilike() for case-insensitive search.
      // '%$query%' finds any story whose title contains the query string.
      final response = await supabaseClient
          .from('Story')
          .select('*, profiles:author_id(*)') // Adjust based on your DB schema
          .ilike('title', '%$query%');

      final stories = (response as List).map((item) => Story.fromMap(item)).toList();
      return stories;
    } catch (e) {
      throw Exception('Error searching stories: $e');
    }
  }
}
