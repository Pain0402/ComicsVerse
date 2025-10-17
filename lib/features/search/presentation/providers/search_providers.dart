import 'dart:async';
import 'package:comicsapp/features/auth/presentation/providers/auth_providers.dart';
import 'package:comicsapp/features/home/domain/entities/story.dart';
import 'package:comicsapp/features/search/data/repositories/search_repository_impl.dart';
import 'package:comicsapp/features/search/domain/repositories/search_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Cung cấp SearchRepository
final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return SearchRepositoryImpl(supabaseClient);
});

// 2. Cung cấp từ khóa tìm kiếm hiện tại
final searchQueryProvider = StateProvider<String>((ref) => '');

// 3. Provider chính xử lý logic tìm kiếm và debouncing
final searchResultsProvider =
    AsyncNotifierProvider.autoDispose<SearchResultsNotifier, List<Story>>(
      SearchResultsNotifier.new,
    );

class SearchResultsNotifier extends AutoDisposeAsyncNotifier<List<Story>> {
  Timer? _debounceTimer;

  // Hàm build sẽ được gọi khi provider được khởi tạo
  // hoặc khi các provider mà nó theo dõi thay đổi.
  @override
  Future<List<Story>> build() async {
    // Lấy từ khóa tìm kiếm hiện tại
    final query = ref.watch(searchQueryProvider);

    // Nếu từ khóa rỗng, không làm gì cả, trả về danh sách trống.
    if (query.isEmpty) {
      return [];
    }

    // Bắt đầu trạng thái loading
    state = const AsyncValue.loading();

    // Hủy timer cũ nếu có (khi người dùng đang gõ)
    _debounceTimer?.cancel();

    // Tạo một Completer để chờ timer hoàn thành
    final completer = Completer<List<Story>>();

    // Bắt đầu timer mới. Sau 500ms không gõ, nó sẽ thực hiện tìm kiếm.
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        final searchRepository = ref.read(searchRepositoryProvider);
        final results = await searchRepository.searchStories(query);
        // Hoàn thành Completer với kết quả
        if (!completer.isCompleted) completer.complete(results);
      } catch (e) {
        // Hoàn thành Completer với lỗi
        if (!completer.isCompleted) completer.completeError(e);
      }
    });

    // Hủy timer khi provider bị hủy
    ref.onDispose(() {
      _debounceTimer?.cancel();
      if (!completer.isCompleted) {
        completer.completeError(StateError('Provider was disposed'));
      }
    });

    // Trả về Future của Completer để UI có thể lắng nghe
    return completer.future;
  }
}
