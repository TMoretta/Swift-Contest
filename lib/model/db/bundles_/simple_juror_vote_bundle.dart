// import 'package:equatable/equatable.dart';
// import 'package:swift_contest/model/data_models/simple_juror_vote.dart';
// import 'package:swift_contest/model/data_models/voting_form_field.dart';
//
// class SimpleJurorVoteBundle extends Equatable {
//   final SimpleJurorVote simpleJurorVote;
//   final VotingFormField votingFormField;
//
//   const SimpleJurorVoteBundle({
//     required this.simpleJurorVote,
//     required this.votingFormField,
//   });
//
//   factory SimpleJurorVoteBundle.fromJson(Map<String, dynamic> json) {
//     return SimpleJurorVoteBundle(
//       simpleJurorVote: SimpleJurorVote.fromJson(json['simple_juror_vote']),
//       votingFormField: VotingFormField.fromJson(json['voting_form_field']),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'simple_juror_vote': simpleJurorVote.toJson(),
//       'voting_form_field': votingFormField.toJson(),
//     };
//   }
//
//   SimpleJurorVoteBundle copyWith({
//     SimpleJurorVote? simpleJurorVote,
//     VotingFormField? votingFormField,
//   }) {
//     return SimpleJurorVoteBundle(
//       simpleJurorVote: simpleJurorVote ?? this.simpleJurorVote,
//       votingFormField: votingFormField ?? this.votingFormField,
//     );
//   }
//
//   @override
//   List<Object?> get props => [simpleJurorVote, votingFormField];
// }