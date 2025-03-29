import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/participation/participation_status.dart';
import 'package:swift_contest/model/data_models/participation/participation.dart';
import 'package:swift_contest/model/data_models/profile/app_language.dart';
import 'package:swift_contest/model/data_models/profile/app_theme.dart';
import 'package:swift_contest/model/data_models/profile/contest_role.dart';
import 'package:swift_contest/model/data_models/profile/profile.dart';
import 'package:swift_contest/model/data_models/work/work.dart';
import 'package:swift_contest/model/mixed_models/extended_work.dart';
import 'package:swift_contest/utils/exceptions/custom_exception.dart';

//* Interface
abstract interface class WorkService {
  Future<Work> createWork({
    required String name,
    required String description,
    required List<String> imagesUrls,
  });

  Future<List<Work>> getAllWorks();

  Future<Work> getWorkById({required String id});

  Future<Work> updateWorkById({
    required String id,
    String? name,
    String? description,
    List<String>? imagesUrls,
  });

  Future<Unit> deleteWorkById({required String id});

  Future<Work> submitWork({
    required String contestId,
    required String participantId,
    required String name,
    required String description,
    required List<String> imagesUrls,
  });

  Future<ExtendedWork> getExtendedWorkByContestIdAndParticipantId({
    required String contestId,
    required String participantId,
  });

  Future<List<ExtendedWork>> getExtendedWorksByContestId({required String contestId});
}

//* Implementation
class WorkServiceImpl implements WorkService {
  final SupabaseClient _supabase;

  WorkServiceImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<Work> createWork({
    required String name,
    required String description,
    required List<String> imagesUrls,
  }) async {
    try {
      final Map<String,dynamic>  workMap = await _supabase.rpc('create_work', params: {
        'p_name': name,
        'p_description': description,
        'p_images_urls': imagesUrls,
      });
      return Work.fromJson(workMap);
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<List<Work>> getAllWorks() async {
    try {
      final List<Map<String,dynamic>> worksMaps = await _supabase.rpc('get_all_works');
      return worksMaps.map((workMap) => Work.fromJson(workMap)).toList(growable: false);
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<Work> getWorkById({required String id}) async {
    try {
      final Map<String,dynamic>  workMap = await _supabase.rpc('get_work_by_id', params: {'p_id': id});
      return Work.fromJson(workMap);
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<Work> updateWorkById({
    required String id,
    String? name,
    String? description,
    List<String>? imagesUrls,
  }) async {
    try {
      final  Map<String,dynamic> workMap = await _supabase.rpc('update_work_by_id', params: {
        'p_id': id,
        'p_name': name,
        'p_description': description,
        'p_images_urls': imagesUrls,
      });
      return Work.fromJson(workMap);
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<Unit> deleteWorkById({required String id}) async {
    try {
      await _supabase.rpc('delete_work_by_id', params: {'p_id': id});
      return unit;
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<Work> submitWork({
    required String contestId,
    required String participantId,
    required String name,
    required String description,
    required List<String> imagesUrls,
  }) async {
    try {
      final Map<String,dynamic>  map = await _supabase.rpc('submit_work', params: {
        'p_contest_id': contestId,
        'p_participant_id': participantId,
        'p_name': name,
        'p_description': description,
        'p_images_urls': imagesUrls,
      });
      return Work.fromJson(map);
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<ExtendedWork> getExtendedWorkByContestIdAndParticipantId({
    required String contestId,
    required String participantId,
  }) async {
    try {
      final Map<String,dynamic>?  map =
          await _supabase.rpc('get_extended_work_by_contest_id_and_participant_id', params: {
        'p_contest_id': contestId,
        'p_participant_id': participantId,
      });
      if (map == null) {
        return ExtendedWorkNotSubmitted(
            work: Work(id: '', name: '', description: '', imagesUrls: []),
            participation: Participation(
              id: '',
              contestId: '',
              participantId: '',
              token: '',
              status: ParticipationStatus.attended,
              inviteEmail: '',
              workId: '',
            ),
            participant: Profile(
              id: '',
              firstName: '',
              lastName: '',
              isAlive: false,
              prefAppLanguage: AppLanguage.english,
              prefAppTheme: AppTheme.light,
              prefContestRole: ContestRole.organizer,
            ));
      }
      return ExtendedWork.fromJson(map);
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<List<ExtendedWork>> getExtendedWorksByContestId({required String contestId}) async {
    try {
      final List<Map<String,dynamic>> maps = await _supabase.rpc('get_extended_works_by_contest_id', params: {
        'p_contest_id': contestId,
      });
      return maps.map((map)=>ExtendedWork.fromJson(map)).toList(growable: false);
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }
}
