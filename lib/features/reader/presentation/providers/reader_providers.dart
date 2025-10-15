import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:comicsapp/features/home/presentation/providers/home_providers.dart';

/// Provider cung cấp danh sách URL hình ảnh của một chương cụ thể.
/// Sử dụng .family để truyền chapterId vào.
final chapterContentProvider =
    FutureProvider.autoDispose.family<List<String>, String>((ref, chapterId) async {
  final supabase = ref.watch(supabaseClientProvider);

  try {
    // Truy vấn bảng Chapter để lấy cột image_urls
    final data = await supabase
        .from('Chapter')
        .select('image_urls')
        .eq('chapter_id', chapterId)
        .single();

    final imageUrlsData = data['image_urls'];

    if (imageUrlsData == null) {
      return [];
    }

    List<dynamic> imageUrlsDynamic;

    // --- SỬA LỖI: Xử lý an toàn kiểu dữ liệu ---
    // Kiểm tra xem dữ liệu có phải là List hay không.
    if (imageUrlsData is List) {
      imageUrlsDynamic = imageUrlsData;
    } 
    // Nếu là String, có thể nó là một chuỗi JSON. Thử giải mã nó.
    else if (imageUrlsData is String) {
      try {
        // Thử decode chuỗi JSON thành một List
        imageUrlsDynamic = jsonDecode(imageUrlsData) as List;
      } catch (e) {
        // Nếu không phải chuỗi JSON hợp lệ, hoặc không phải là List sau khi decode,
        // coi như đây là một URL duy nhất và bọc nó trong một List.
        print('Warning: image_urls is a string but not a valid JSON array. Treating as a single image URL. Details: $e');
        imageUrlsDynamic = [imageUrlsData];
      }
    } 
    // Nếu không phải cả hai, ném ra lỗi để báo hiệu dữ liệu không hợp lệ.
    else {
      throw Exception('Định dạng dữ liệu image_urls không hợp lệ: ${imageUrlsData.runtimeType}');
    }
    // --- KẾT THÚC SỬA LỖI ---


    // Dữ liệu trả về từ Supabase là một List<dynamic>, cần chuyển đổi sang List<String>
    final imageUrls = imageUrlsDynamic.map((e) => e.toString()).toList();

    // Tạo public URL cho từng ảnh từ đường dẫn lưu trong CSDL
    // Ví dụ: 'chapter1/image1.jpg' -> 'https://<project-id>.supabase.co/storage/v1/object/public/stories/chapter1/image1.jpg'
    final publicUrls = imageUrlsDynamic.map((e) => e.toString()).toList();

    return publicUrls;
  } on PostgrestException catch (e) {
    // Xử lý lỗi từ Supabase, ví dụ như không có quyền truy cập (RLS chặn)
    if (e.code == 'PGRST116') {
      // PGRST116: Lỗi schema cache, thường xảy ra khi RLS không trả về hàng nào
      throw Exception(
          'Không thể truy cập chương này. Có thể đây là chương VIP hoặc bạn chưa đăng nhập.');
    }
    rethrow;
  } catch (e) {
    // Bắt các lỗi khác
    print('Lỗi khi tải nội dung chương: $e');
    rethrow;
  }
});

