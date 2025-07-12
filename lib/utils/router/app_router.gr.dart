// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i30;
import 'package:flutter/foundation.dart' as _i32;
import 'package:flutter/material.dart' as _i31;
import 'package:swift_contest/view/pages/account_page.dart' as _i1;
import 'package:swift_contest/view/pages/admin_pages/admin_home_page.dart'
    as _i2;
import 'package:swift_contest/view/pages/admin_pages/admin_sign_in_page.dart'
    as _i3;
import 'package:swift_contest/view/pages/inbox_page.dart' as _i4;
import 'package:swift_contest/view/pages/juror_pages/juror_contest_details_page/juror_contest_details_page.dart'
    as _i5;
import 'package:swift_contest/view/pages/juror_pages/juror_home_page.dart'
    as _i6;
import 'package:swift_contest/view/pages/juror_pages/juror_voting_procedure_page.dart'
    as _i7;
import 'package:swift_contest/view/pages/juror_pages/simple_juror_voting_procedure_page.dart'
    as _i28;
import 'package:swift_contest/view/pages/organizer_pages/organizer_contest_creation_page.dart'
    as _i8;
import 'package:swift_contest/view/pages/organizer_pages/organizer_contest_details_page/organizer_contest_details_page.dart'
    as _i9;
import 'package:swift_contest/view/pages/organizer_pages/organizer_contest_edit_page.dart'
    as _i10;
import 'package:swift_contest/view/pages/organizer_pages/organizer_home_page.dart'
    as _i11;
import 'package:swift_contest/view/pages/organizer_pages/organizer_voting_form_edit_page.dart'
    as _i12;
import 'package:swift_contest/view/pages/organizer_pages/organizer_voting_procedure_page.dart'
    as _i13;
import 'package:swift_contest/view/pages/organizer_pages/organizer_voting_result_details_page/organizer_voting_result_details_page.dart'
    as _i14;
import 'package:swift_contest/view/pages/organizer_pages/organizer_voting_result_export_page.dart'
    as _i15;
import 'package:swift_contest/view/pages/organizer_pages/organizer_voting_settings_page.dart'
    as _i16;
import 'package:swift_contest/view/pages/organizer_pages/organizer_work_details_page.dart'
    as _i17;
import 'package:swift_contest/view/pages/participant_pages/participant_contest_details_page/participant_contest_details_page.dart'
    as _i18;
import 'package:swift_contest/view/pages/participant_pages/participant_home_page.dart'
    as _i19;
import 'package:swift_contest/view/pages/participant_pages/participant_work_submit_page.dart'
    as _i20;
import 'package:swift_contest/view/pages/place_search_page.dart' as _i21;
import 'package:swift_contest/view/pages/root_page.dart' as _i22;
import 'package:swift_contest/view/pages/settings_page.dart' as _i23;
import 'package:swift_contest/view/pages/sign_in_page.dart' as _i24;
import 'package:swift_contest/view/pages/sign_in_verify_page.dart' as _i25;
import 'package:swift_contest/view/pages/sign_up_page.dart' as _i26;
import 'package:swift_contest/view/pages/sign_up_verify_page.dart' as _i27;
import 'package:swift_contest/view/pages/splash_page.dart' as _i29;

/// generated route for
/// [_i1.AccountPage]
class AccountRoute extends _i30.PageRouteInfo<void> {
  const AccountRoute({List<_i30.PageRouteInfo>? children})
      : super(AccountRoute.name, initialChildren: children);

  static const String name = 'AccountRoute';

  static _i30.PageInfo page = _i30.PageInfo(
    name,
    builder: (data) {
      return const _i1.AccountPage();
    },
  );
}

/// generated route for
/// [_i2.AdminHomePage]
class AdminHomeRoute extends _i30.PageRouteInfo<void> {
  const AdminHomeRoute({List<_i30.PageRouteInfo>? children})
      : super(AdminHomeRoute.name, initialChildren: children);

  static const String name = 'AdminHomeRoute';

  static _i30.PageInfo page = _i30.PageInfo(
    name,
    builder: (data) {
      return const _i2.AdminHomePage();
    },
  );
}

/// generated route for
/// [_i3.AdminSignInPage]
class AdminSignInRoute extends _i30.PageRouteInfo<void> {
  const AdminSignInRoute({List<_i30.PageRouteInfo>? children})
      : super(AdminSignInRoute.name, initialChildren: children);

  static const String name = 'AdminSignInRoute';

  static _i30.PageInfo page = _i30.PageInfo(
    name,
    builder: (data) {
      return const _i3.AdminSignInPage();
    },
  );
}

/// generated route for
/// [_i4.InboxPage]
class InboxRoute extends _i30.PageRouteInfo<void> {
  const InboxRoute({List<_i30.PageRouteInfo>? children})
      : super(InboxRoute.name, initialChildren: children);

  static const String name = 'InboxRoute';

  static _i30.PageInfo page = _i30.PageInfo(
    name,
    builder: (data) {
      return const _i4.InboxPage();
    },
  );
}

/// generated route for
/// [_i5.JurorContestDetailsPage]
class JurorContestDetailsRoute
    extends _i30.PageRouteInfo<JurorContestDetailsRouteArgs> {
  JurorContestDetailsRoute({
    required String contestId,
    _i31.Key? key,
    List<_i30.PageRouteInfo>? children,
  }) : super(
          JurorContestDetailsRoute.name,
          args: JurorContestDetailsRouteArgs(contestId: contestId, key: key),
          rawPathParams: {'contestId': contestId},
          initialChildren: children,
        );

  static const String name = 'JurorContestDetailsRoute';

  static _i30.PageInfo page = _i30.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<JurorContestDetailsRouteArgs>(
        orElse: () => JurorContestDetailsRouteArgs(
          contestId: pathParams.getString('contestId'),
        ),
      );
      return _i5.JurorContestDetailsPage(
        contestId: args.contestId,
        key: args.key,
      );
    },
  );
}

class JurorContestDetailsRouteArgs {
  const JurorContestDetailsRouteArgs({required this.contestId, this.key});

  final String contestId;

  final _i31.Key? key;

  @override
  String toString() {
    return 'JurorContestDetailsRouteArgs{contestId: $contestId, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! JurorContestDetailsRouteArgs) return false;
    return contestId == other.contestId && key == other.key;
  }

  @override
  int get hashCode => contestId.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i6.JurorHomePage]
class JurorHomeRoute extends _i30.PageRouteInfo<void> {
  const JurorHomeRoute({List<_i30.PageRouteInfo>? children})
      : super(JurorHomeRoute.name, initialChildren: children);

  static const String name = 'JurorHomeRoute';

  static _i30.PageInfo page = _i30.PageInfo(
    name,
    builder: (data) {
      return const _i6.JurorHomePage();
    },
  );
}

/// generated route for
/// [_i7.JurorVotingProcedurePage]
class JurorVotingProcedureRoute
    extends _i30.PageRouteInfo<JurorVotingProcedureRouteArgs> {
  JurorVotingProcedureRoute({
    required String votingSessionId,
    _i31.Key? key,
    List<_i30.PageRouteInfo>? children,
  }) : super(
          JurorVotingProcedureRoute.name,
          args: JurorVotingProcedureRouteArgs(
            votingSessionId: votingSessionId,
            key: key,
          ),
          rawPathParams: {'votingSessionId': votingSessionId},
          initialChildren: children,
        );

  static const String name = 'JurorVotingProcedureRoute';

  static _i30.PageInfo page = _i30.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<JurorVotingProcedureRouteArgs>(
        orElse: () => JurorVotingProcedureRouteArgs(
          votingSessionId: pathParams.getString('votingSessionId'),
        ),
      );
      return _i7.JurorVotingProcedurePage(
        votingSessionId: args.votingSessionId,
        key: args.key,
      );
    },
  );
}

class JurorVotingProcedureRouteArgs {
  const JurorVotingProcedureRouteArgs({
    required this.votingSessionId,
    this.key,
  });

  final String votingSessionId;

  final _i31.Key? key;

  @override
  String toString() {
    return 'JurorVotingProcedureRouteArgs{votingSessionId: $votingSessionId, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! JurorVotingProcedureRouteArgs) return false;
    return votingSessionId == other.votingSessionId && key == other.key;
  }

  @override
  int get hashCode => votingSessionId.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i8.OrganizerContestCreationPage]
class OrganizerContestCreationRoute extends _i30.PageRouteInfo<void> {
  const OrganizerContestCreationRoute({List<_i30.PageRouteInfo>? children})
      : super(OrganizerContestCreationRoute.name, initialChildren: children);

  static const String name = 'OrganizerContestCreationRoute';

  static _i30.PageInfo page = _i30.PageInfo(
    name,
    builder: (data) {
      return const _i8.OrganizerContestCreationPage();
    },
  );
}

/// generated route for
/// [_i9.OrganizerContestDetailsPage]
class OrganizerContestDetailsRoute
    extends _i30.PageRouteInfo<OrganizerContestDetailsRouteArgs> {
  OrganizerContestDetailsRoute({
    required String contestId,
    _i31.Key? key,
    List<_i30.PageRouteInfo>? children,
  }) : super(
          OrganizerContestDetailsRoute.name,
          args:
              OrganizerContestDetailsRouteArgs(contestId: contestId, key: key),
          rawPathParams: {'contestId': contestId},
          initialChildren: children,
        );

  static const String name = 'OrganizerContestDetailsRoute';

  static _i30.PageInfo page = _i30.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<OrganizerContestDetailsRouteArgs>(
        orElse: () => OrganizerContestDetailsRouteArgs(
          contestId: pathParams.getString('contestId'),
        ),
      );
      return _i9.OrganizerContestDetailsPage(
        contestId: args.contestId,
        key: args.key,
      );
    },
  );
}

class OrganizerContestDetailsRouteArgs {
  const OrganizerContestDetailsRouteArgs({required this.contestId, this.key});

  final String contestId;

  final _i31.Key? key;

  @override
  String toString() {
    return 'OrganizerContestDetailsRouteArgs{contestId: $contestId, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OrganizerContestDetailsRouteArgs) return false;
    return contestId == other.contestId && key == other.key;
  }

  @override
  int get hashCode => contestId.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i10.OrganizerContestEditPage]
class OrganizerContestEditRoute
    extends _i30.PageRouteInfo<OrganizerContestEditRouteArgs> {
  OrganizerContestEditRoute({
    required String contestId,
    _i32.Key? key,
    List<_i30.PageRouteInfo>? children,
  }) : super(
          OrganizerContestEditRoute.name,
          args: OrganizerContestEditRouteArgs(contestId: contestId, key: key),
          rawPathParams: {'contestId': contestId},
          initialChildren: children,
        );

  static const String name = 'OrganizerContestEditRoute';

  static _i30.PageInfo page = _i30.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<OrganizerContestEditRouteArgs>(
        orElse: () => OrganizerContestEditRouteArgs(
          contestId: pathParams.getString('contestId'),
        ),
      );
      return _i10.OrganizerContestEditPage(
        contestId: args.contestId,
        key: args.key,
      );
    },
  );
}

class OrganizerContestEditRouteArgs {
  const OrganizerContestEditRouteArgs({required this.contestId, this.key});

  final String contestId;

  final _i32.Key? key;

  @override
  String toString() {
    return 'OrganizerContestEditRouteArgs{contestId: $contestId, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OrganizerContestEditRouteArgs) return false;
    return contestId == other.contestId && key == other.key;
  }

  @override
  int get hashCode => contestId.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i11.OrganizerHomePage]
class OrganizerHomeRoute extends _i30.PageRouteInfo<void> {
  const OrganizerHomeRoute({List<_i30.PageRouteInfo>? children})
      : super(OrganizerHomeRoute.name, initialChildren: children);

  static const String name = 'OrganizerHomeRoute';

  static _i30.PageInfo page = _i30.PageInfo(
    name,
    builder: (data) {
      return const _i11.OrganizerHomePage();
    },
  );
}

/// generated route for
/// [_i12.OrganizerVotingFormEditPage]
class OrganizerVotingFormEditRoute
    extends _i30.PageRouteInfo<OrganizerVotingFormEditRouteArgs> {
  OrganizerVotingFormEditRoute({
    required String votingFormId,
    _i31.Key? key,
    List<_i30.PageRouteInfo>? children,
  }) : super(
          OrganizerVotingFormEditRoute.name,
          args: OrganizerVotingFormEditRouteArgs(
            votingFormId: votingFormId,
            key: key,
          ),
          rawPathParams: {'votingFormId': votingFormId},
          initialChildren: children,
        );

  static const String name = 'OrganizerVotingFormEditRoute';

  static _i30.PageInfo page = _i30.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<OrganizerVotingFormEditRouteArgs>(
        orElse: () => OrganizerVotingFormEditRouteArgs(
          votingFormId: pathParams.getString('votingFormId'),
        ),
      );
      return _i12.OrganizerVotingFormEditPage(
        votingFormId: args.votingFormId,
        key: args.key,
      );
    },
  );
}

class OrganizerVotingFormEditRouteArgs {
  const OrganizerVotingFormEditRouteArgs({
    required this.votingFormId,
    this.key,
  });

  final String votingFormId;

  final _i31.Key? key;

  @override
  String toString() {
    return 'OrganizerVotingFormEditRouteArgs{votingFormId: $votingFormId, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OrganizerVotingFormEditRouteArgs) return false;
    return votingFormId == other.votingFormId && key == other.key;
  }

  @override
  int get hashCode => votingFormId.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i13.OrganizerVotingProcedurePage]
class OrganizerVotingProcedureRoute
    extends _i30.PageRouteInfo<OrganizerVotingProcedureRouteArgs> {
  OrganizerVotingProcedureRoute({
    required String votingSessionId,
    _i31.Key? key,
    List<_i30.PageRouteInfo>? children,
  }) : super(
          OrganizerVotingProcedureRoute.name,
          args: OrganizerVotingProcedureRouteArgs(
            votingSessionId: votingSessionId,
            key: key,
          ),
          rawPathParams: {'votingSessionId': votingSessionId},
          initialChildren: children,
        );

  static const String name = 'OrganizerVotingProcedureRoute';

  static _i30.PageInfo page = _i30.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<OrganizerVotingProcedureRouteArgs>(
        orElse: () => OrganizerVotingProcedureRouteArgs(
          votingSessionId: pathParams.getString('votingSessionId'),
        ),
      );
      return _i13.OrganizerVotingProcedurePage(
        votingSessionId: args.votingSessionId,
        key: args.key,
      );
    },
  );
}

class OrganizerVotingProcedureRouteArgs {
  const OrganizerVotingProcedureRouteArgs({
    required this.votingSessionId,
    this.key,
  });

  final String votingSessionId;

  final _i31.Key? key;

  @override
  String toString() {
    return 'OrganizerVotingProcedureRouteArgs{votingSessionId: $votingSessionId, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OrganizerVotingProcedureRouteArgs) return false;
    return votingSessionId == other.votingSessionId && key == other.key;
  }

  @override
  int get hashCode => votingSessionId.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i14.OrganizerVotingResultDetailsPage]
class OrganizerVotingResultDetailsRoute
    extends _i30.PageRouteInfo<OrganizerVotingResultDetailsRouteArgs> {
  OrganizerVotingResultDetailsRoute({
    required String votingSessionId,
    _i31.Key? key,
    List<_i30.PageRouteInfo>? children,
  }) : super(
          OrganizerVotingResultDetailsRoute.name,
          args: OrganizerVotingResultDetailsRouteArgs(
            votingSessionId: votingSessionId,
            key: key,
          ),
          rawPathParams: {'votingSessionId': votingSessionId},
          initialChildren: children,
        );

  static const String name = 'OrganizerVotingResultDetailsRoute';

  static _i30.PageInfo page = _i30.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<OrganizerVotingResultDetailsRouteArgs>(
        orElse: () => OrganizerVotingResultDetailsRouteArgs(
          votingSessionId: pathParams.getString('votingSessionId'),
        ),
      );
      return _i14.OrganizerVotingResultDetailsPage(
        votingSessionId: args.votingSessionId,
        key: args.key,
      );
    },
  );
}

class OrganizerVotingResultDetailsRouteArgs {
  const OrganizerVotingResultDetailsRouteArgs({
    required this.votingSessionId,
    this.key,
  });

  final String votingSessionId;

  final _i31.Key? key;

  @override
  String toString() {
    return 'OrganizerVotingResultDetailsRouteArgs{votingSessionId: $votingSessionId, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OrganizerVotingResultDetailsRouteArgs) return false;
    return votingSessionId == other.votingSessionId && key == other.key;
  }

  @override
  int get hashCode => votingSessionId.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i15.OrganizerVotingResultExportPage]
class OrganizerVotingResultExportRoute
    extends _i30.PageRouteInfo<OrganizerVotingResultExportRouteArgs> {
  OrganizerVotingResultExportRoute({
    required String votingSessionId,
    _i31.Key? key,
    List<_i30.PageRouteInfo>? children,
  }) : super(
          OrganizerVotingResultExportRoute.name,
          args: OrganizerVotingResultExportRouteArgs(
            votingSessionId: votingSessionId,
            key: key,
          ),
          rawPathParams: {'votingSessionId': votingSessionId},
          initialChildren: children,
        );

  static const String name = 'OrganizerVotingResultExportRoute';

  static _i30.PageInfo page = _i30.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<OrganizerVotingResultExportRouteArgs>(
        orElse: () => OrganizerVotingResultExportRouteArgs(
          votingSessionId: pathParams.getString('votingSessionId'),
        ),
      );
      return _i15.OrganizerVotingResultExportPage(
        votingSessionId: args.votingSessionId,
        key: args.key,
      );
    },
  );
}

class OrganizerVotingResultExportRouteArgs {
  const OrganizerVotingResultExportRouteArgs({
    required this.votingSessionId,
    this.key,
  });

  final String votingSessionId;

  final _i31.Key? key;

  @override
  String toString() {
    return 'OrganizerVotingResultExportRouteArgs{votingSessionId: $votingSessionId, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OrganizerVotingResultExportRouteArgs) return false;
    return votingSessionId == other.votingSessionId && key == other.key;
  }

  @override
  int get hashCode => votingSessionId.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i16.OrganizerVotingSettingsPage]
class OrganizerVotingSettingsRoute
    extends _i30.PageRouteInfo<OrganizerVotingSettingsRouteArgs> {
  OrganizerVotingSettingsRoute({
    required String contestId,
    _i31.Key? key,
    List<_i30.PageRouteInfo>? children,
  }) : super(
          OrganizerVotingSettingsRoute.name,
          args:
              OrganizerVotingSettingsRouteArgs(contestId: contestId, key: key),
          rawPathParams: {'contestId': contestId},
          initialChildren: children,
        );

  static const String name = 'OrganizerVotingSettingsRoute';

  static _i30.PageInfo page = _i30.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<OrganizerVotingSettingsRouteArgs>(
        orElse: () => OrganizerVotingSettingsRouteArgs(
          contestId: pathParams.getString('contestId'),
        ),
      );
      return _i16.OrganizerVotingSettingsPage(
        contestId: args.contestId,
        key: args.key,
      );
    },
  );
}

class OrganizerVotingSettingsRouteArgs {
  const OrganizerVotingSettingsRouteArgs({required this.contestId, this.key});

  final String contestId;

  final _i31.Key? key;

  @override
  String toString() {
    return 'OrganizerVotingSettingsRouteArgs{contestId: $contestId, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OrganizerVotingSettingsRouteArgs) return false;
    return contestId == other.contestId && key == other.key;
  }

  @override
  int get hashCode => contestId.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i17.OrganizerWorkDetailsPage]
class OrganizerWorkDetailsRoute
    extends _i30.PageRouteInfo<OrganizerWorkDetailsRouteArgs> {
  OrganizerWorkDetailsRoute({
    required String participationId,
    _i31.Key? key,
    List<_i30.PageRouteInfo>? children,
  }) : super(
          OrganizerWorkDetailsRoute.name,
          args: OrganizerWorkDetailsRouteArgs(
            participationId: participationId,
            key: key,
          ),
          rawPathParams: {'participationId': participationId},
          initialChildren: children,
        );

  static const String name = 'OrganizerWorkDetailsRoute';

  static _i30.PageInfo page = _i30.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<OrganizerWorkDetailsRouteArgs>(
        orElse: () => OrganizerWorkDetailsRouteArgs(
          participationId: pathParams.getString('participationId'),
        ),
      );
      return _i17.OrganizerWorkDetailsPage(
        participationId: args.participationId,
        key: args.key,
      );
    },
  );
}

class OrganizerWorkDetailsRouteArgs {
  const OrganizerWorkDetailsRouteArgs({
    required this.participationId,
    this.key,
  });

  final String participationId;

  final _i31.Key? key;

  @override
  String toString() {
    return 'OrganizerWorkDetailsRouteArgs{participationId: $participationId, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OrganizerWorkDetailsRouteArgs) return false;
    return participationId == other.participationId && key == other.key;
  }

  @override
  int get hashCode => participationId.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i18.ParticipantContestDetailsPage]
class ParticipantContestDetailsRoute
    extends _i30.PageRouteInfo<ParticipantContestDetailsRouteArgs> {
  ParticipantContestDetailsRoute({
    required String contestId,
    _i31.Key? key,
    List<_i30.PageRouteInfo>? children,
  }) : super(
          ParticipantContestDetailsRoute.name,
          args: ParticipantContestDetailsRouteArgs(
            contestId: contestId,
            key: key,
          ),
          rawPathParams: {'contestId': contestId},
          initialChildren: children,
        );

  static const String name = 'ParticipantContestDetailsRoute';

  static _i30.PageInfo page = _i30.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ParticipantContestDetailsRouteArgs>(
        orElse: () => ParticipantContestDetailsRouteArgs(
          contestId: pathParams.getString('contestId'),
        ),
      );
      return _i18.ParticipantContestDetailsPage(
        contestId: args.contestId,
        key: args.key,
      );
    },
  );
}

class ParticipantContestDetailsRouteArgs {
  const ParticipantContestDetailsRouteArgs({required this.contestId, this.key});

  final String contestId;

  final _i31.Key? key;

  @override
  String toString() {
    return 'ParticipantContestDetailsRouteArgs{contestId: $contestId, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ParticipantContestDetailsRouteArgs) return false;
    return contestId == other.contestId && key == other.key;
  }

  @override
  int get hashCode => contestId.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i19.ParticipantHomePage]
class ParticipantHomeRoute extends _i30.PageRouteInfo<void> {
  const ParticipantHomeRoute({List<_i30.PageRouteInfo>? children})
      : super(ParticipantHomeRoute.name, initialChildren: children);

  static const String name = 'ParticipantHomeRoute';

  static _i30.PageInfo page = _i30.PageInfo(
    name,
    builder: (data) {
      return const _i19.ParticipantHomePage();
    },
  );
}

/// generated route for
/// [_i20.ParticipantWorkSubmitPage]
class ParticipantWorkSubmitRoute
    extends _i30.PageRouteInfo<ParticipantWorkSubmitRouteArgs> {
  ParticipantWorkSubmitRoute({
    required String contestId,
    _i32.Key? key,
    List<_i30.PageRouteInfo>? children,
  }) : super(
          ParticipantWorkSubmitRoute.name,
          args: ParticipantWorkSubmitRouteArgs(contestId: contestId, key: key),
          rawPathParams: {'contestId': contestId},
          initialChildren: children,
        );

  static const String name = 'ParticipantWorkSubmitRoute';

  static _i30.PageInfo page = _i30.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ParticipantWorkSubmitRouteArgs>(
        orElse: () => ParticipantWorkSubmitRouteArgs(
          contestId: pathParams.getString('contestId'),
        ),
      );
      return _i20.ParticipantWorkSubmitPage(
        contestId: args.contestId,
        key: args.key,
      );
    },
  );
}

class ParticipantWorkSubmitRouteArgs {
  const ParticipantWorkSubmitRouteArgs({required this.contestId, this.key});

  final String contestId;

  final _i32.Key? key;

  @override
  String toString() {
    return 'ParticipantWorkSubmitRouteArgs{contestId: $contestId, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ParticipantWorkSubmitRouteArgs) return false;
    return contestId == other.contestId && key == other.key;
  }

  @override
  int get hashCode => contestId.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i21.PlaceSearchPage]
class PlaceSearchRoute extends _i30.PageRouteInfo<void> {
  const PlaceSearchRoute({List<_i30.PageRouteInfo>? children})
      : super(PlaceSearchRoute.name, initialChildren: children);

  static const String name = 'PlaceSearchRoute';

  static _i30.PageInfo page = _i30.PageInfo(
    name,
    builder: (data) {
      return const _i21.PlaceSearchPage();
    },
  );
}

/// generated route for
/// [_i22.RootPage]
class RootRoute extends _i30.PageRouteInfo<void> {
  const RootRoute({List<_i30.PageRouteInfo>? children})
      : super(RootRoute.name, initialChildren: children);

  static const String name = 'RootRoute';

  static _i30.PageInfo page = _i30.PageInfo(
    name,
    builder: (data) {
      return const _i22.RootPage();
    },
  );
}

/// generated route for
/// [_i23.SettingsPage]
class SettingsRoute extends _i30.PageRouteInfo<void> {
  const SettingsRoute({List<_i30.PageRouteInfo>? children})
      : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i30.PageInfo page = _i30.PageInfo(
    name,
    builder: (data) {
      return const _i23.SettingsPage();
    },
  );
}

/// generated route for
/// [_i24.SignInPage]
class SignInRoute extends _i30.PageRouteInfo<void> {
  const SignInRoute({List<_i30.PageRouteInfo>? children})
      : super(SignInRoute.name, initialChildren: children);

  static const String name = 'SignInRoute';

  static _i30.PageInfo page = _i30.PageInfo(
    name,
    builder: (data) {
      return const _i24.SignInPage();
    },
  );
}

/// generated route for
/// [_i25.SignInVerifyPage]
class SignInVerifyRoute extends _i30.PageRouteInfo<SignInVerifyRouteArgs> {
  SignInVerifyRoute({
    required String email,
    _i31.Key? key,
    List<_i30.PageRouteInfo>? children,
  }) : super(
          SignInVerifyRoute.name,
          args: SignInVerifyRouteArgs(email: email, key: key),
          rawPathParams: {'email': email},
          initialChildren: children,
        );

  static const String name = 'SignInVerifyRoute';

  static _i30.PageInfo page = _i30.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<SignInVerifyRouteArgs>(
        orElse: () =>
            SignInVerifyRouteArgs(email: pathParams.getString('email')),
      );
      return _i25.SignInVerifyPage(email: args.email, key: args.key);
    },
  );
}

class SignInVerifyRouteArgs {
  const SignInVerifyRouteArgs({required this.email, this.key});

  final String email;

  final _i31.Key? key;

  @override
  String toString() {
    return 'SignInVerifyRouteArgs{email: $email, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SignInVerifyRouteArgs) return false;
    return email == other.email && key == other.key;
  }

  @override
  int get hashCode => email.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i26.SignUpPage]
class SignUpRoute extends _i30.PageRouteInfo<void> {
  const SignUpRoute({List<_i30.PageRouteInfo>? children})
      : super(SignUpRoute.name, initialChildren: children);

  static const String name = 'SignUpRoute';

  static _i30.PageInfo page = _i30.PageInfo(
    name,
    builder: (data) {
      return const _i26.SignUpPage();
    },
  );
}

/// generated route for
/// [_i27.SignUpVerifyPage]
class SignUpVerifyRoute extends _i30.PageRouteInfo<SignUpVerifyRouteArgs> {
  SignUpVerifyRoute({
    required String email,
    _i32.Key? key,
    List<_i30.PageRouteInfo>? children,
  }) : super(
          SignUpVerifyRoute.name,
          args: SignUpVerifyRouteArgs(email: email, key: key),
          rawPathParams: {'email': email},
          initialChildren: children,
        );

  static const String name = 'SignUpVerifyRoute';

  static _i30.PageInfo page = _i30.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<SignUpVerifyRouteArgs>(
        orElse: () =>
            SignUpVerifyRouteArgs(email: pathParams.getString('email')),
      );
      return _i27.SignUpVerifyPage(email: args.email, key: args.key);
    },
  );
}

class SignUpVerifyRouteArgs {
  const SignUpVerifyRouteArgs({required this.email, this.key});

  final String email;

  final _i32.Key? key;

  @override
  String toString() {
    return 'SignUpVerifyRouteArgs{email: $email, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SignUpVerifyRouteArgs) return false;
    return email == other.email && key == other.key;
  }

  @override
  int get hashCode => email.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i28.SimpleJurorVotingProcedurePage]
class SimpleJurorVotingProcedureRoute
    extends _i30.PageRouteInfo<SimpleJurorVotingProcedureRouteArgs> {
  SimpleJurorVotingProcedureRoute({
    required String simpleJurorId,
    required String votingSessionId,
    _i31.Key? key,
    List<_i30.PageRouteInfo>? children,
  }) : super(
          SimpleJurorVotingProcedureRoute.name,
          args: SimpleJurorVotingProcedureRouteArgs(
            simpleJurorId: simpleJurorId,
            votingSessionId: votingSessionId,
            key: key,
          ),
          rawPathParams: {
            'simpleJurorId': simpleJurorId,
            'votingSessionId': votingSessionId,
          },
          initialChildren: children,
        );

  static const String name = 'SimpleJurorVotingProcedureRoute';

  static _i30.PageInfo page = _i30.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<SimpleJurorVotingProcedureRouteArgs>(
        orElse: () => SimpleJurorVotingProcedureRouteArgs(
          simpleJurorId: pathParams.getString('simpleJurorId'),
          votingSessionId: pathParams.getString('votingSessionId'),
        ),
      );
      return _i28.SimpleJurorVotingProcedurePage(
        simpleJurorId: args.simpleJurorId,
        votingSessionId: args.votingSessionId,
        key: args.key,
      );
    },
  );
}

class SimpleJurorVotingProcedureRouteArgs {
  const SimpleJurorVotingProcedureRouteArgs({
    required this.simpleJurorId,
    required this.votingSessionId,
    this.key,
  });

  final String simpleJurorId;

  final String votingSessionId;

  final _i31.Key? key;

  @override
  String toString() {
    return 'SimpleJurorVotingProcedureRouteArgs{simpleJurorId: $simpleJurorId, votingSessionId: $votingSessionId, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SimpleJurorVotingProcedureRouteArgs) return false;
    return simpleJurorId == other.simpleJurorId &&
        votingSessionId == other.votingSessionId &&
        key == other.key;
  }

  @override
  int get hashCode =>
      simpleJurorId.hashCode ^ votingSessionId.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i29.SplashPage]
class SplashRoute extends _i30.PageRouteInfo<void> {
  const SplashRoute({List<_i30.PageRouteInfo>? children})
      : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static _i30.PageInfo page = _i30.PageInfo(
    name,
    builder: (data) {
      return const _i29.SplashPage();
    },
  );
}
