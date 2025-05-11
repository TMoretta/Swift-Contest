import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

//* Interface
abstract interface class UtilsService {
  Future<String> genUniqueToken({required String tableName,
  required String columnName, required int length,});
}

//* Implementation
class UtilsServiceImpl implements UtilsService {
  final SupabaseClient  _supabase;

  UtilsServiceImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<String> genUniqueToken({required String tableName, required String columnName, required int length}) async {
    try {
      final result = await  _supabase.rpc('gen_unique_token', params: {
        'p_table_name' : tableName,
        'p_column_name' : columnName,
        'p_length' : length,
      });
      return result;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }


}