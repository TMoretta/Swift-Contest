import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/utils/handle_database_call.dart';
import 'package:swift_contest/model/utils/storage_bucket.dart';
import 'package:swift_contest/utils/failures/failures.dart';
import 'package:swift_contest/utils/functions/gen_uuid.dart';

//* Interface
abstract interface class StorageRepository {
  /// Carica più immagini e restituisce la lista dei loro **path** nel bucket.
  Future<Either<Failure, List<String>>> uploadImages({
    required String bucket,
    required String pathPrefix,
    required List<XFile> images,
  });

  /// Carica un singolo file e restituisce il suo **path** nel bucket.
  Future<Either<Failure, String>> uploadFile({
    required String bucket,
    required String pathPrefix,
    required File file,
  });

  /// Genera una URL firmata e temporanea per un dato path.
  Future<Either<Failure, String>> getDownloadUrl({
    required String bucket,
    required String path,
  });
}

//* Implementation
class StorageRepositoryImpl implements StorageRepository {
  final SupabaseClient _supabase;

  StorageRepositoryImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<Either<Failure, List<String>>> uploadImages({
    required String bucket,
    required String pathPrefix,
    required List<XFile> images,
  }) async {
    return handleDatabaseCall(() async {
      // Esegui tutti gli upload in parallelo per efficienza.
      final uploadTasks = images.map((image) async {
        final fileName = image.name;
        // Crea un path unico per ogni file per evitare collisioni.
        final uploadPath = '$pathPrefix/${genUuid()}/$fileName';

        final bytes = await image.readAsBytes();
        await _supabase.storage.from(bucket).uploadBinary(
          uploadPath,
          bytes,
          fileOptions: FileOptions(
            // Usa il mime-type corretto per il file.
            contentType: image.mimeType,
            // upsert: true è utile per permettere di sovrascrivere se necessario.
            upsert: true,
          ),
        );
        // Restituisci solo il path, non la URL.
        return uploadPath;
      }).toList();

      // Attendi il completamento di tutti gli upload.
      final List<String> uploadedPaths = await Future.wait(uploadTasks);
      return Either.right(uploadedPaths);
    });
  }

  @override
  Future<Either<Failure, String>> uploadFile({
    required String bucket,
    required String pathPrefix,
    required File file,
  }) async {
    return handleDatabaseCall(() async {
      final fileName = p.basename(file.path);
      final uploadPath = '$pathPrefix/${genUuid()}/$fileName';

      await _supabase.storage.from(bucket).upload(
        uploadPath,
        file,
        fileOptions: const FileOptions(upsert: true),
      );
      // Restituisci solo il path.
      return Either.right(uploadPath);
    });
  }

  @override
  Future<Either<Failure, String>> getDownloadUrl({
    required String bucket,
    required String path,
  }) async {
    return handleDatabaseCall(() async {
      // Dato che i tuoi bucket sono privati per sicurezza (ottima scelta!),
      // dobbiamo sempre generare una URL firmata.
      // Questa URL concede un accesso temporaneo al file.
      try {
        final url = await _supabase.storage.from(bucket).createSignedUrl(
          path,
          3600, // L'URL sarà valida per 1 ora (3600 secondi).
        );
        return Either.right(url);
      } on StorageException catch (e) {
        // Se il file non esiste (es. path errato), createSignedUrl lancia un'eccezione.
        // La catturiamo e la gestiamo con il nostro sistema di Failure.
        if (e.statusCode == '404') {
          return Either.left(const NotFoundFailure('The specified file path does not exist.'));
        }
        // Rilancia l'eccezione per farla gestire da handleDatabaseCall
        rethrow;
      }
    });
  }
}


// class StorageBucket {
//   StorageBucket._();
//
//   static const String contestsImages = 'contests-images';
//   static const String worksImages = 'works-images';
//   static const String worksFiles = 'works-files';
// }
//
// //* Interface
// abstract interface class StorageRepository {
//   /// Carica più immagini e restituisce la lista dei loro path nel bucket.
//   Future<Either<Failure, List<String>>> uploadImages({
//     required String bucket,
//     required String pathPrefix,
//     required List<XFile> images,
//   });
//
//   /// Carica un singolo file e restituisce il suo path nel bucket.
//   Future<Either<Failure, String>> uploadFile({
//     required String bucket,
//     required String pathPrefix,
//     required File file,
//   });
//
//   /// Genera un URL pubblico o firmato per un dato path.
//   Future<Either<Failure, String>> getDownloadUrl({
//     required String bucket,
//     required String path,
//   });
// }
//
// //* Implementation
// class StorageRepositoryImpl implements StorageRepository {
//   final SupabaseClient _supabase;
//
//   StorageRepositoryImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;
//
//   @override
//   Future<Either<Failure, List<String>>> uploadImages({
//     required String bucket,
//     required String pathPrefix,
//     required List<XFile> images,
//   }) async {
//     return handleDatabaseCall(() async{
//       final List<String> imagesUrls = [];
//       final uploadTasks = images.map((image) async {
//         final fileName = image.name;
//         final uploadPath = '$pathPrefix/${genUuid()}/$fileName';
//
//         final bytes = await image.readAsBytes();
//         await _supabase.storage.from(bucket).uploadBinary(
//           uploadPath,
//           bytes,
//           fileOptions: FileOptions(contentType: image.mimeType),
//         );
//         return uploadPath;
//       }).toList();
//
//       final List<String> uploadedPaths = await Future.wait(uploadTasks);
//       for(var path in uploadedPaths) {
//         final url = _supabase.storage.from(bucket).getPublicUrl(path);
//         imagesUrls.add(url);
//       }
//       return Either.right(imagesUrls);
//     },);
//   }
//
//   @override
//   Future<Either<Failure, String>> uploadFile({
//     required String bucket,
//     required String pathPrefix,
//     required File file,
//   }) async {
//     return handleDatabaseCall(() async{
//       final fileName = p.basename(file.path);
//       final uploadPath = '$pathPrefix/${genUuid()}/$fileName';
//
//       await _supabase.storage.from(bucket).upload(
//         uploadPath,
//         file,
//         fileOptions: const FileOptions(upsert: true),
//       );
//       final url = _supabase.storage.from(bucket).getPublicUrl(uploadPath);
//       return Either.right(url);
//     },);
//   }
//
//   @override
//   Future<Either<Failure, String>> getDownloadUrl({
//     required String bucket,
//     required String path,
//   }) async {
//     return handleDatabaseCall(()async {
//       // Controlla se il bucket è pubblico dalle policy (un modo euristico)
//       // o mantieni una lista statica. Per semplicità, usiamo una lista.
//       const publicBuckets = [StorageBucket.contestsImages];
//
//       if (publicBuckets.contains(bucket)) {
//         final url = _supabase.storage.from(bucket).getPublicUrl(path);
//         return Either.right(url);
//       } else {
//         // Per i bucket privati, genera un URL firmato valido per 1 ora.
//         final url = await _supabase.storage.from(bucket).createSignedUrl(path, 3600);
//         return Either.right(url);
//       }
//     },);
//   }
// }
