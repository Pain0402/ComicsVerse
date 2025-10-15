import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_brightness/screen_brightness.dart';

// Sử dụng StateProvider để quản lý giá trị độ sáng hiện tại của slider
final brightnessProvider = StateProvider.autoDispose<double>((ref) => 0.5);

/// BottomSheet hiển thị cài đặt cho trình đọc.
class ReaderSettingsBottomSheet extends ConsumerWidget {
  const ReaderSettingsBottomSheet({super.key});

  // Hàm để lấy độ sáng hiện tại của hệ thống một cách bất đồng bộ
  Future<void> _getCurrentBrightness(WidgetRef ref) async {
    try {
      final double brightness = await ScreenBrightness().current;
      // Cập nhật StateProvider với giá trị độ sáng thực tế
      ref.read(brightnessProvider.notifier).state = brightness;
    } catch (e) {
      print("Không thể lấy độ sáng màn hình: $e");
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Gọi hàm để lấy độ sáng hiện tại khi widget được build lần đầu
    // Sử dụng FutureBuilder để tránh gọi lại nhiều lần không cần thiết
    return FutureBuilder(
      future: _getCurrentBrightness(ref),
      builder: (context, snapshot) {
        final theme = Theme.of(context);
        final brightnessValue = ref.watch(brightnessProvider);

        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: theme.colorScheme.background.withOpacity(0.7),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Cài đặt hiển thị', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 16),

                  // Thanh trượt điều chỉnh độ sáng
                  Row(
                    children: [
                      const Icon(Icons.brightness_low_rounded),
                      Expanded(
                        child: Slider(
                          value: brightnessValue,
                          onChanged: (value) {
                            // Cập nhật UI ngay lập tức
                            ref.read(brightnessProvider.notifier).state = value;
                            // Gọi API để thay đổi độ sáng hệ thống
                            ScreenBrightness().setScreenBrightness(value);
                          },
                        ),
                      ),
                      const Icon(Icons.brightness_high_rounded),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
