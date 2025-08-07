part of 'deep_link_bloc.dart';

sealed class DeepLinkEvent extends Equatable {
  const DeepLinkEvent();
}

final class DeepLinkSetPending extends DeepLinkEvent {
  final Uri uri;

  const DeepLinkSetPending(this.uri);

  @override
  List<Object> get props => [uri];
}

final class DeepLinkHandlePending extends DeepLinkEvent {
  @override
  List<Object?> get props => [];
}

final class DeepLinkHandleParticipantInvite extends DeepLinkEvent {
  final String token;

  const DeepLinkHandleParticipantInvite({required this.token});

  @override
  List<Object?> get props => [token];
}
