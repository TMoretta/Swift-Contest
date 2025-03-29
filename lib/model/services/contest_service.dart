import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/contest/contest.dart';
import 'package:swift_contest/model/data_models/contest/contest_status.dart';
import 'package:swift_contest/model/data_models/contest/place.dart';
import 'package:swift_contest/model/mixed_models/extended_contest.dart';
import 'package:swift_contest/utils/exceptions/custom_exception.dart';

//* Interface
abstract interface class ContestService {
  Future<Contest> createContest({required Contest contest});

  Future<List<Contest>> getAllContests();

  Future<Contest> getContestById({required String id});

  Future<List<Contest>> getContestsByOrganizerId({required String organizerId});

  Future<Contest> updateContestById({
    required String id,
    String? name,
    String? description,
    String? organizerId,
    Place? place,
    bool? worksPreviewJurors,
    DateTime? dateTime,
    DateTime? worksDateTimeFrom,
    DateTime? worksDateTimeTo,
    ContestStatus? status,
    List<String>? imagesUrls,
    bool? isAlive,
  });

  Future<Unit> deleteContestById({required String id});

  Future<List<ExtendedContest>> getExtendedContestsByOrganizerId({required String organizerId});

  Future<List<ExtendedContest>> getExtendedContestsByParticipantId({required String participantId});

  Future<List<ExtendedContest>> getExtendedContestsByJurorId({required String jurorId});

  Future<ExtendedContest> getExtendedContestByContestId({required String contestId});
}

//* Implementation
class ContestServiceImpl implements ContestService {
  final SupabaseClient _supabase;

  ContestServiceImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<Contest> createContest({required Contest contest}) async {
    try {
      final Map<String,dynamic> map = contest.toJson();
      final Map<String,dynamic> contestMap = await _supabase.rpc('create_contest', params: {
        'p_name': map['name'],
        'p_description': map['description'],
        'p_organizer_id': map['organizer_id'],
        'p_place': map['place'],
        'p_works_preview_jurors': map['works_preview_jurors'],
        'p_date_time': map['date_time'],
        'p_works_date_time_from': map['works_date_time_from'],
        'p_works_date_time_to': map['works_date_time_to'],
        'p_status': map['status'],
        'p_images_urls': map['images_urls'],
      });
      return Contest.fromJson(contestMap);
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<List<Contest>> getAllContests() async {
    try {
      final List<Map<String,dynamic>> contestsMaps = await _supabase.rpc('get_all_contests');
      return contestsMaps.map((contestMap) => Contest.fromJson(contestMap)).toList(growable: false);
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<Contest> getContestById({required String id}) async {
    try {
      final Map<String,dynamic> contestMap = await _supabase.rpc('get_contest_by_id', params: {'p_id': id});
      return Contest.fromJson(contestMap);
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<List<Contest>> getContestsByOrganizerId({required String organizerId}) async {
    try {
      final List<Map<String,dynamic>> contestsMaps = await _supabase
          .rpc('get_contests_by_organizer_id', params: {'p_organizer_id': organizerId});
      return contestsMaps.map((contestMap) => Contest.fromJson(contestMap)).toList(growable: false);
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<Contest> updateContestById({
    required String id,
    String? name,
    String? description,
    String? organizerId,
    Place? place,
    bool? worksPreviewJurors,
    DateTime? dateTime,
    DateTime? worksDateTimeFrom,
    DateTime? worksDateTimeTo,
    ContestStatus? status,
    List<String>? imagesUrls,
    bool? isAlive,
  }) async {
    try {
      final Map<String,dynamic> contestMap = await _supabase.rpc('update_contest_by_id', params: {
        'p_id': id,
        'p_name': name,
        'p_description': description,
        'p_organizer_id': organizerId,
        'p_place': place,
        'p_works_preview_jurors': worksPreviewJurors,
        'p_date_time': dateTime,
        'p_works_date_time_from': worksDateTimeFrom,
        'p_works_date_time_to': worksDateTimeTo,
        'p_status': status,
        'p_images_urls': imagesUrls,
        'p_is_alive': isAlive,
      });
      return Contest.fromJson(contestMap);
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<Unit> deleteContestById({required String id}) async {
    try {
      await _supabase.rpc('delete_contest_by_id');
      return unit;
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<List<ExtendedContest>> getExtendedContestsByOrganizerId({
    required String organizerId,
  }) async {
    try {
      final List<Map<String, dynamic>> maps = await _supabase
          .rpc('get_extended_contests_by_organizer_id', params: {'p_organizer_id': organizerId});
      final List<ExtendedContest> extendedContests =
          maps.map((map) => ExtendedContest.fromJson(map)).toList(growable: false);
      return extendedContests;
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<List<ExtendedContest>> getExtendedContestsByParticipantId({
    required String participantId,
  }) async {
    try {
      final List<Map<String, dynamic>> maps = await _supabase.rpc(
        'get_extended_contests_by_participant_id',
        params: {'p_participant_id': participantId},
      );
      return maps.map((map) => ExtendedContest.fromJson(map)).toList(growable: false);
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<List<ExtendedContest>> getExtendedContestsByJurorId({
    required String jurorId,
  }) async {
    try {
      final List<Map<String, dynamic>> maps = await _supabase.rpc(
        'get_extended_contests_by_juror_id',
        params: {'p_juror_id': jurorId},
      );
      return maps.map((map) => ExtendedContest.fromJson(map)).toList(growable: false);
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<ExtendedContest> getExtendedContestByContestId({required String contestId}) async {
    try {
      final  Map<String,dynamic> map = await _supabase.rpc(
        'get_extended_contest_by_contest_id',
        params: {'p_contest_id': contestId},
      );
      return ExtendedContest.fromJson(map);
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }
}
