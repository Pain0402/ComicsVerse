import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:comicsapp/features/auth/domain/entities/profile.dart';
import 'package:comicsapp/features/home/data/repositories/story_repository_impl.dart';
import 'package:comicsapp/features/home/domain/entities/story.dart';

// Provider cung cấp instance của SupabaseClient
final supabaseClientProvider =
    Provider<SupabaseClient>((ref) => Supabase.instance.client);

// Provider cung cấp StoryRepository
final storyRepositoryProvider = Provider<StoryRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return StoryRepository(client);
});

// Provider để lấy danh sách tất cả truyện
final allStoriesProvider = FutureProvider<List<Story>>((ref) async {
  final repository = ref.watch(storyRepositoryProvider);
  return repository.getAllStories();
});

// Provider để lấy thông tin profile của người dùng hiện tại
final userProfileProvider = FutureProvider<Profile?>((ref) async {
  final repository = ref.watch(storyRepositoryProvider);
  return repository.getUserProfile();
});

