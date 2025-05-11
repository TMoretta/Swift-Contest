part of 'template_bloc.dart';

@immutable
final class TemplateState extends Equatable {
  final BlocStatus status;
  final String? message;

  const TemplateState({
    required this.status,
    this.message,
  });

  TemplateState copyWith({
    required BlocStatus status,
    String? message,
  }) {
    return TemplateState(
      status: status,
      message: message,
    );
  }

  @override
  List<Object?> get props => [
        status,
        message,
      ];
}
