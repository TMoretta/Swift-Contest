import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class GenericRepository {}

class GenericRepositoryImpl implements GenericRepository {
  final SupabaseClient _supabase;

  GenericRepositoryImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;
}
