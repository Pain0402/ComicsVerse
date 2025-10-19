import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:comicsapp/features/home/data/repositories/story_repository_impl.dart';
import 'package:comicsapp/features/home/domain/entities/story.dart';

/// Provides the singleton instance of the Supabase client.
final supabaseClientProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);

/// Provides the [StoryRepository] implementation.
final storyRepositoryProvider = Provider<StoryRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return StoryRepository(client);
});

/// Fetches and provides a list of all stories.
final allStoriesProvider = FutureProvider<List<Story>>((ref) async {
  final repository = ref.watch(storyRepositoryProvider);
  return repository.getAllStories();
});
