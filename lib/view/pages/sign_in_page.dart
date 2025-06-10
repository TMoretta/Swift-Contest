import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/sign_in_page_bloc/sign_in_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Center(
            child: ListView(
              shrinkWrap: true,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //* Title
                    Text(
                      'Swift Contest',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    //* Subtitle
                    Text(
                      'Welcome to your contest manager',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 12,
                ),
                BlocConsumer<SignInPageBloc, SignInPageState>(
                  listener: (context, state) {
                    //* Show a message if there is one
                    if (state.message != null) {
                      showSnackBar(context: context, text: state.message!);
                    }
                    //* Go to splash page
                    if (state.status.isSuccess && state.sourceEvent is SignInWithEmailAndPassword) {
                      context.goNamed(AppRouter.splash, extra: 0);
                    }
                  },
                  builder: (context, state) {
                    switch (state.status) {
                      case BlocStatus.loading:
                        return const Loader();
                      case BlocStatus.initial:
                      case BlocStatus.failure:
                      case BlocStatus.success:
                        return Form(
                          key: _formKey,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                //* Email text field
                                CustomTextFormFieldOutlined(
                                  controller: _emailController,
                                  label: 'Email',
                                  validator: (value) => _emailValidator(value?.trim()),
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                                //* Password text field
                                CustomTextFormFieldOutlined(
                                  controller: _passwordController,
                                  label: 'Password',
                                  prefixIcon: Icon(Icons.lock),
                                  obscureText: true,
                                ),
                                SizedBox(height: 10),
                                //* Sign in button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState?.validate() ?? false) {
                                        context.read<SignInPageBloc>().add(
                                            SignInWithEmailAndPassword(
                                                email: _emailController.text.trim(),
                                                password: _passwordController.text.trim()));
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).colorScheme.primary,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text(
                                      'Sign in',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                //* Sign up instead button
                                Align(
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Don\'t have an account?',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          context.replaceNamed(AppRouter.signUp);
                                        },
                                        style: ButtonStyle(),
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            'Sign up',
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.primary,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 24),
                                //* Vote as a simple juror
                                TextButton(
                                  onPressed: () {
                                    // showSimpleJurorVotingAccessAlert(context: context);
                                  },
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                            color: Theme.of(context).colorScheme.secondary),
                                      ),
                                    ),
                                    child: Text(
                                      'Vote in a contest as a guest',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.secondary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
  }

  //* Email validator
  String? _emailValidator(String? value) {
    String? valueTrm = value?.trim();
    if (valueTrm == null || valueTrm.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(valueTrm)) {
      return 'Please enter a valid email';
    }
    return null;
  }
}

// void showSimpleJurorVotingAccessAlert({required BuildContext context}) {
//   showDialog(
//     context: context,
//     builder: (context) {
//       final voteAsSimpleJurorFormKey = GlobalKey<FormState>();
//       final fullNameController = TextEditingController();
//       final votingSessionTokenController = TextEditingController();
//       return AlertDialog(
//         title: Text('Vote as a simple juror'),
//         content: Form(
//           key: voteAsSimpleJurorFormKey,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               CustomTextFormFieldUnderlined(
//                 controller: fullNameController,
//                 label: 'Your full name',
//                 validator: (value) => noEmptyValidator(value),
//               ),
//               CustomTextFormFieldUnderlined(
//                 controller: votingSessionTokenController,
//                 label: 'Voting token',
//                 validator: (value) => noEmptyValidator(value),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           BlocProvider(
//             create: (context) => JurorHomePageBloc(
//               jurationRepository: context.read(),
//               contestRepository: context.read(),
//               invitationRepository: context.read(),
//               simpleJurorVotingRepository: context.read(),
//               votingSessionParticipantRepository: context.read(),
//               votingSessionProcedureRepository: context.read(),
//               votingSessionRepository: context.read(),
//               votingSessionSimpleJurorRepository: context.read(),
//               simpleJurorRepository: context.read(),
//               placeRepository: context.read(),
//             ),
//             child: BlocConsumer<JurorHomePageBloc, JurorHomePageState>(
//               listener: (context, state) {
//                 if (state.status.isFailure) {
//                   showSnackBar(context: context, text: state.message!);
//                 }
//                 if (state.status.isSuccess) {
//                   final Map<String, dynamic> jsonData = {
//                     'voting_session': state.votingSession!,
//                     'voting_session_simple_juror': state.votingSessionSimpleJuror!,
//                   };
//                   context.pushNamed(AppRouter.simpleJurorVotingProcedure, extra: jsonData);
//                 }
//               },
//               builder: (context, state) {
//                 if (state.status.isLoading) {
//                   return Loader();
//                 }
//                 return Row(
//                   mainAxisSize: MainAxisSize.max,
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     TextButton(
//                       onPressed: () {
//                         context.pop();
//                       },
//                       child: Text('Cancel'),
//                     ),
//                     TextButton(
//                       onPressed: () async {
//                         if (votingOnlyFormKey.currentState?.validate() ?? false) {
//                           if (context.mounted) {
//                             context.read<JurorHomePageBloc>().add(
//                                 JurorHomePageJoinVotingAsSimpleJuror(
//                                     fullName: fullNameController.text.trim(),
//                                     votingSessionToken: votingTokenController.text.trim()));
//                           }
//                         }
//                       },
//                       child: Text('Ok'),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           )
//         ],
//       );
//     },
//   );
// }

// class SignInPage extends StatefulWidget {
//   const SignInPage({super.key});
//
//   @override
//   State<SignInPage> createState() => _SignInPageState();
// }
//
// class _SignInPageState extends State<SignInPage> {
//   @override
//   Widget build(BuildContext context) {
//     final formKey = GlobalKey<FormState>();
//     final emailController = TextEditingController();
//
//     return Scaffold(
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             return SizedBox(
//               width: constraints.maxWidth,
//               height: constraints.maxHeight,
//               child: Center(
//                 child: SingleChildScrollView(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           //* Title
//                           Text(
//                             'Swift Contest',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               color: Theme.of(context).colorScheme.primary,
//                               fontSize: 48,
//                               fontWeight: FontWeight.w900,
//                             ),
//                           ),
//                           //* Subtitle
//                           Text(
//                             'Welcome to your contest manager',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               color: Theme.of(context).colorScheme.onSurface,
//                               fontSize: 20,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(
//                         height: 12,
//                       ),
//                       BlocConsumer<AuthBloc, AuthState>(
//                         listener: (context, state) {
//                           //* Show a message if there is one
//                           if (state.message != null) {
//                             showSnackBar(context: context, text: state.message!);
//                           }
//                           //* Go to verify page in case of success
//                           if (state.blocStatus.isSuccess) {
//                             context.goNamed(AppRouter.signInVerify, extra: emailController.text.trim());
//                           }
//                         },
//                         builder: (context, state) {
//                           if (state.blocStatus.isLoading) {
//                             return const Loader();
//                           }
//
//                           // if(state.blocStatus.isFailure && state.authStatus!.isUnauthenticated) {
//                           //    the same form
//                           // }
//
//                           if (state.blocStatus.isFailure && state.authStatus.isAuthenticated) {
//                             return Column(
//                               children: [
//                                 Text('An error occurred while fetching data'),
//                                 FilledButton(
//                                     onPressed: () {
//                                       context.read<AuthBloc>().add(AuthInit());
//                                     },
//                                     child: Text('Retry')),
//                               ],
//                             );
//                           }
//
//                           // if(state.blocStatus.isSuccess && state.authStatus!.isAuthenticated) {
//                           //    go to home
//                           // }
//
//                           return Form(
//                             key: formKey,
//                             child: Padding(
//                               padding: EdgeInsets.all(16),
//                               child: Column(
//                                 children: [
//                                   //* Email text field
//                                   CustomTextFormFieldOutlined(
//                                     controller: emailController,
//                                     label: 'Email',
//                                     validator: (value) => _emailValidator(value?.trim()),
//                                     prefixIcon: Icon(Icons.email_outlined),
//                                   ),
//                                   SizedBox(height: 10),
//                                   //* Sign in button
//                                   SizedBox(
//                                     width: double.infinity,
//                                     child: ElevatedButton(
//                                       onPressed: () {
//                                         if (formKey.currentState?.validate() ?? false) {
//                                           context.read<AuthBloc>().add(
//                                               AuthSignInWithEmail(
//                                                   email: emailController.text.trim(),));
//                                         }
//                                       },
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor: Theme.of(context).colorScheme.primary,
//                                         foregroundColor: Colors.white,
//                                       ),
//                                       child: const Text(
//                                         'Sign in',
//                                         style: TextStyle(
//                                           fontSize: 16.0,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   //* Sign up instead button
//                                   Align(
//                                     alignment: Alignment.center,
//                                     child: Row(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         Text(
//                                           'Don\'t have an account?',
//                                           style: TextStyle(
//                                             color: Theme.of(context).colorScheme.onSurface,
//                                           ),
//                                         ),
//                                         TextButton(
//                                           onPressed: () {
//                                             context.goNamed(AppRouter.signUp);
//                                           },
//                                           style: ButtonStyle(),
//                                           child: DecoratedBox(
//                                             decoration: BoxDecoration(
//                                               border: Border(
//                                                 bottom: BorderSide(
//                                                   color: Theme.of(context).colorScheme.primary,
//                                                 ),
//                                               ),
//                                             ),
//                                             child: Text(
//                                               'Sign up',
//                                               style: TextStyle(
//                                                 color: Theme.of(context).colorScheme.primary,
//                                                 fontSize: 16,
//                                                 fontWeight: FontWeight.w600,
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   SizedBox(height: 24),
//                                   //* Vote as a simple juror
//                                   TextButton(
//                                     onPressed: () {
//                                       // showSimpleJurorVotingAccessAlert(context: context);
//                                     },
//                                     child: DecoratedBox(
//                                       decoration: BoxDecoration(
//                                         border: Border(
//                                           bottom: BorderSide(
//                                               color: Theme.of(context).colorScheme.secondary),
//                                         ),
//                                       ),
//                                       child: Text(
//                                         'Vote in a contest as a guest',
//                                         style: TextStyle(
//                                           color: Theme.of(context).colorScheme.secondary,
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   //* Email validator
//   String? _emailValidator(String? value) {
//     String? valueTrm = value?.trim();
//     if (valueTrm == null || valueTrm.isEmpty) {
//       return 'Please enter your email';
//     }
//     final emailRegex = RegExp(
//       r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
//     );
//     if (!emailRegex.hasMatch(valueTrm)) {
//       return 'Please enter a valid email';
//     }
//     return null;
//   }
// }
//
// // void showSimpleJurorVotingAccessAlert({required BuildContext context}) {
// //   showDialog(
// //     context: context,
// //     builder: (context) {
// //       final voteAsSimpleJurorFormKey = GlobalKey<FormState>();
// //       final fullNameController = TextEditingController();
// //       final votingSessionTokenController = TextEditingController();
// //       return AlertDialog(
// //         title: Text('Vote as a simple juror'),
// //         content: Form(
// //           key: voteAsSimpleJurorFormKey,
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             mainAxisAlignment: MainAxisAlignment.start,
// //             crossAxisAlignment: CrossAxisAlignment.center,
// //             children: [
// //               CustomTextFormFieldUnderlined(
// //                 controller: fullNameController,
// //                 label: 'Your full name',
// //                 validator: (value) => noEmptyValidator(value),
// //               ),
// //               CustomTextFormFieldUnderlined(
// //                 controller: votingSessionTokenController,
// //                 label: 'Voting token',
// //                 validator: (value) => noEmptyValidator(value),
// //               ),
// //             ],
// //           ),
// //         ),
// //         actions: [
// //           BlocProvider(
// //             create: (context) => JurorHomePageBloc(
// //               jurationRepository: context.read(),
// //               contestRepository: context.read(),
// //               invitationRepository: context.read(),
// //               simpleJurorVotingRepository: context.read(),
// //               votingSessionParticipantRepository: context.read(),
// //               votingSessionProcedureRepository: context.read(),
// //               votingSessionRepository: context.read(),
// //               votingSessionSimpleJurorRepository: context.read(),
// //               simpleJurorRepository: context.read(),
// //               placeRepository: context.read(),
// //             ),
// //             child: BlocConsumer<JurorHomePageBloc, JurorHomePageState>(
// //               listener: (context, state) {
// //                 if (state.status.isFailure) {
// //                   showSnackBar(context: context, text: state.message!);
// //                 }
// //                 if (state.status.isSuccess) {
// //                   final Map<String, dynamic> jsonData = {
// //                     'voting_session': state.votingSession!,
// //                     'voting_session_simple_juror': state.votingSessionSimpleJuror!,
// //                   };
// //                   context.pushNamed(AppRouter.simpleJurorVotingProcedure, extra: jsonData);
// //                 }
// //               },
// //               builder: (context, state) {
// //                 if (state.status.isLoading) {
// //                   return Loader();
// //                 }
// //                 return Row(
// //                   mainAxisSize: MainAxisSize.max,
// //                   mainAxisAlignment: MainAxisAlignment.end,
// //                   children: [
// //                     TextButton(
// //                       onPressed: () {
// //                         context.pop();
// //                       },
// //                       child: Text('Cancel'),
// //                     ),
// //                     TextButton(
// //                       onPressed: () async {
// //                         if (votingOnlyFormKey.currentState?.validate() ?? false) {
// //                           if (context.mounted) {
// //                             context.read<JurorHomePageBloc>().add(
// //                                 JurorHomePageJoinVotingAsSimpleJuror(
// //                                     fullName: fullNameController.text.trim(),
// //                                     votingSessionToken: votingTokenController.text.trim()));
// //                           }
// //                         }
// //                       },
// //                       child: Text('Ok'),
// //                     ),
// //                   ],
// //                 );
// //               },
// //             ),
// //           )
// //         ],
// //       );
// //     },
// //   );
// // }
//
// String? noEmptyValidator(String? value) {
//   final val = value?.trim();
//
//   if (val == null || val == '') {
//     return '';
//   }
//   return null;
// }
