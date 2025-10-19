import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

// App's main entry point.
Future<void> main() async {
  // Ensure Flutter bindings are initialized before running the app.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the Supabase client.
  // TODO: Replace with your project's URL and anon key from the Supabase dashboard.
  await Supabase.initialize(
    url: 'https://ezdqwuypgldtkcwtuate.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV6ZHF3dXlwZ2xkdGtjd3R1YXRlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk5NDYxNjEsImV4cCI6MjA3NTUyMjE2MX0.ATd8pP2zRvw91yWeK4SqeTmsPvCYdoSZktQzhta2x2s',
  );

  // Run the app within a ProviderScope for Riverpod state management.
  runApp(const ProviderScope(child: App()));
}
