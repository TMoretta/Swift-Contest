import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/database/types/storage_bucket.dart';
import 'package:swift_contest/model/utils/handle_backend_call.dart';
import 'package:swift_contest/utils/failures/failures.dart';
import 'package:swift_contest/utils/functions/gen_uuid.dart';

//* Interface
abstract interface class StorageRepository {
  /// Carica più immagini e restituisce la lista dei loro **path** nel bucket.
  Future<Either<Failure, List<String>>> uploadImages({
    required StorageBucket bucket,
    required String pathPrefix,
    required List<XFile> images,
  });

  /// Carica un singolo file e restituisce il suo **path** nel bucket.
  Future<Either<Failure, String>> uploadFile({
    required StorageBucket bucket,
    required String pathPrefix,
    required File file,
  });

  /// Genera una URL firmata e temporanea per un dato path.
  Future<Either<Failure, String>> getSignedUrl({
    required StorageBucket bucket,
    required String path,
  });
}

//* Implementation
class StorageRepositoryImpl implements StorageRepository {
  final SupabaseClient _supabase;

  StorageRepositoryImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<Either<Failure, List<String>>> uploadImages({
    required StorageBucket bucket,
    required String pathPrefix,
    required List<XFile> images,
  }) async {
    return handleBackendCall(() async {
      // Esegui tutti gli upload in parallelo per efficienza.
      final uploadTasks = images.map((image) async {
        final fileName = image.name;
        // Crea un path unico per ogni file per evitare collisioni.
        final uploadPath = '$pathPrefix/${genUuid()}/$fileName';

        final bytes = await image.readAsBytes();
        await _supabase.storage.from(bucket.name).uploadBinary(
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
    required StorageBucket bucket,
    required String pathPrefix,
    required File file,
  }) async {
    return handleBackendCall(() async {
      final fileName = p.basename(file.path);
      final uploadPath = '$pathPrefix/${genUuid()}/$fileName';

      await _supabase.storage.from(bucket.name).upload(
        uploadPath,
        file,
        fileOptions: const FileOptions(upsert: true),
      );
      // Restituisci solo il path.
      return Either.right(uploadPath);
    });
  }

  @override
  Future<Either<Failure, String>> getSignedUrl({
    required StorageBucket bucket,
    required String path,
  }) async {
    return handleBackendCall(() async {
      // Dato che i tuoi bucket sono privati per sicurezza (ottima scelta!),
      // dobbiamo sempre generare una URL firmata.
      // Questa URL concede un accesso temporaneo al file.
      try {
        final url = await _supabase.storage.from(bucket.name).createSignedUrl(
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
