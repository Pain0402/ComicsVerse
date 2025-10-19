import 'dart:async';
import 'package:comicsapp/features/auth/presentation/providers/auth_providers.dart';
import 'package:comicsapp/features/home/domain/entities/story.dart';
import 'package:comicsapp/features/search/data/repositories/search_repository_impl.dart';
import 'package:comicsapp/features/search/domain/repositories/search_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the [SearchRepository] implementation.
final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return SearchRepositoryImpl(supabaseClient);
});

/// Provides the current search query string.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// An [AsyncNotifierProvider] that handles search logic with debouncing.
final searchResultsProvider = AsyncNotifierProvider.autoDispose<SearchResultsNotifier, List<Story>>(
  SearchResultsNotifier.new,
);

class SearchResultsNotifier extends AutoDisposeAsyncNotifier<List<Story>> {
  Timer? _debounceTimer;

  @override
  Future<List<Story>> build() async {
    final query = ref.watch(searchQueryProvider);

    if (query.isEmpty) {
      return [];
    }

    state = const AsyncValue.loading();
    _debounceTimer?.cancel();

    final completer = Completer<List<Story>>();

    // Debounce the search to avoid excessive API calls while typing.
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        final searchRepository = ref.read(searchRepositoryProvider);
        final results = await searchRepository.searchStories(query);
        if (!completer.isCompleted) completer.complete(results);
      } catch (e, st) {
        if (!completer.isCompleted) completer.completeError(e, st);
      }
    });

    ref.onDispose(() {
      _debounceTimer?.cancel();
      if (!completer.isCompleted) {
        completer.completeError(StateError('Provider was disposed'));
      }
    });

    return completer.future;
  }
}
