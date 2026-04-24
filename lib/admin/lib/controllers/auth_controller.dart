import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class AuthController {
  final SupabaseClient _client;
  late final SupabaseService _supabaseService;

  StreamSubscription<AuthState>? _authSubscription;

  AuthController(this._client) {
    _supabaseService = SupabaseService(_client);
  }

  void listenAuthChanges(void Function(AuthState) onAuthStateChanged) {
    _authSubscription = _client.auth.onAuthStateChange.listen((event) {
      onAuthStateChanged(event);
    });
  }

  void dispose() {
    _authSubscription?.cancel();
  }
}
