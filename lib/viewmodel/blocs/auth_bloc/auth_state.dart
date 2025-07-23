part of 'auth_bloc.dart';

@immutable
final class AuthState extends Equatable {
  final BlocStatus blocStatus;
  final AuthStatus authStatus;
  final bool isInitialized;
  final AuthEvent? sourceEvent;
  final String? message;
  final User? user;
  final Profile? profile;
  final List<Message>? messages;

  const AuthState({
    required this.blocStatus,
    required this.authStatus,
    this.isInitialized = false,
    this.sourceEvent,
    this.message,
    this.user,
    this.profile,
    this.messages,
  });

  AuthState copyWith({
    required BlocStatus blocStatus,
    AuthStatus? authStatus,
    bool? isInitialized,
    AuthEvent? sourceEvent,
    String? message,
    User? user,
    Profile? profile,
    List<Message>? messages,
  }) {
    return AuthState(
      blocStatus: blocStatus,
      authStatus: authStatus ?? this.authStatus,
      isInitialized: isInitialized ?? this.isInitialized,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      message: message,
      user: user ?? this.user,
      profile: profile ?? this.profile,
      messages: messages ?? this.messages,
    );
  }

  factory AuthState.fromJson(Map<String, dynamic> json) {
    return AuthState(
      blocStatus: BlocStatus.values.byName(json['bloc_status']),
      authStatus: AuthStatus.values.byName(json['auth_status']),
      isInitialized: json['is_initialized'] as bool,
      user: (json['user'] !=null) ? User.fromJson(json['user']) : null,
      profile: (json['profile'] !=null) ? Profile.fromJson(json['profile']) : null,
      messages:(json['messages'] !=null) ? (json['messages'] as List<dynamic>).map((e) => Message.fromJson(e)).toList(growable: false) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bloc_status': blocStatus.name,
      'auth_status': authStatus.name,
      'is_initialized': isInitialized,
      'user': user?.toJson(),
      'profile': profile?.toJson(),
      'messages': messages?.map((e) => e.toJson()).toList(growable: false),
    };
  }

  @override
  List<Object?> get props => [
        authStatus,
        blocStatus,
        isInitialized,
        sourceEvent,
        message,
        user,
        profile,
        messages,
      ];
}
