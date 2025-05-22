import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/viewmodel/blocs/global_blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //* Title
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Swift Contest',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
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
                      //* Form
                      BlocConsumer<AuthBloc, AuthState>(
                        //* SignUpPageBloc listener
                        listener: (context, state) {
                          //* Show a message if there is one
                          if (state.message != null) {
                            showSnackBar(context: context, text: state.message!);
                          }
                          //* Show a message to verify email and go to sign up verify page
                          if (state.blocStatus.isSuccess) {
                            showSnackBar(
                              context: context,
                              text: 'A code has been sent to your email. '
                                  'Please check your inbox and verify your account.',
                            );
                            context.goNamed(AppRouter.signUpVerify,
                                extra: _emailController.text.trim());

                            // showDialog(
                            //   context: context,
                            //   builder: (context) => AlertDialog(
                            //     title: const Text('Verify email'),
                            //     content: Text(
                            //       'A code has been sent to your email. '
                            //       'Please check your inbox and verify your account.',
                            //     ),
                            //     actions: [
                            //       TextButton(
                            //         onPressed: () {
                            //           context.pop();
                            //           context.pushNamed(AppRouter.signInVerify,
                            //               extra: _emailController.text.trim());
                            //         },
                            //         child: const Text('OK'),
                            //       ),
                            //     ],
                            //   ),
                            // );
                          }
                        },
                        //* SignUpPageBloc builder
                        builder: (context, state) {
                          if (state.blocStatus.isLoading) {
                            return const Loader();
                          }
                          return Form(
                            key: _formKey,
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  //* Full name field
                                  CustomTextFormFieldOutlined(
                                    controller: _fullNameController,
                                    label: 'Full name',
                                    validator: (value) => _fullNameValidator(value?.trim()),
                                    prefixIcon: Icon(Icons.person_outlined),
                                  ),
                                  SizedBox(height: 12),
                                  //* Email field
                                  CustomTextFormFieldOutlined(
                                    controller: _emailController,
                                    label: 'Email',
                                    validator: (value) => _emailValidator(value?.trim()),
                                    prefixIcon: Icon(Icons.email_outlined),
                                  ),
                                  //* Password field
                                  CustomTextFormFieldOutlined(
                                    controller: _passwordController,
                                    label: 'Password',
                                    prefixIcon: Icon(Icons.lock),
                                  ),
                                  SizedBox(height: 10),
                                  //* Sign up button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (_formKey.currentState?.validate() ?? false) {
                                          context.read<AuthBloc>().add(
                                              AuthSignUpWithEmailAndPassword(
                                                  email: _emailController.text.trim(),
                                                  fullName: _fullNameController.text.trim(),
                                                  password: _passwordController.text.trim()));
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context).colorScheme.primary,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text(
                                        'Sign up',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  //* Sign in instead button
                                  Align(
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Already have an account?',
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            context.goNamed(AppRouter.signIn);
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
                                              'Sign in',
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
                                  //* Vote as a guest button
                                  TextButton(
                                    onPressed: () {},
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
                                          // color: Theme.of(context).colorScheme.surface,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  //* Full name validator
  String? _fullNameValidator(String? value) {
    String? valueTrm = value?.trim();

    if (valueTrm == null || valueTrm.isEmpty) {
      return 'Please enter your name';
    }
    if (valueTrm.length < 3) {
      return 'At least 2 characters long';
    }
    if (!RegExp(r'^[a-zA-Z]+$').hasMatch(valueTrm)) {
      return 'Can only contain letters';
    }
    return null;
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

// class SignUpPage extends StatefulWidget {
//   const SignUpPage({super.key});
//
//   @override
//   State<SignUpPage> createState() => _SignUpPageState();
// }
//
// class _SignUpPageState extends State<SignUpPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _fullNameController = TextEditingController();
//   final _emailController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
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
//                       //* Title
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Text(
//                             'Swift Contest',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               color: Theme.of(context).colorScheme.primary,
//                               fontSize: 48,
//                               fontWeight: FontWeight.w900,
//                             ),
//                           ),
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
//                       //* Form
//                       BlocConsumer<AuthBloc, AuthState>(
//                         //* SignUpPageBloc listener
//                         listener: (context, state) {
//                           //* Show a message if there is one
//                           if (state.message != null) {
//                             showSnackBar(context: context, text: state.message!);
//                           }
//                           //* Show a message to verify email and go to sign up verify page
//                           if (state.blocStatus.isSuccess) {
//                             showSnackBar(context: context, text: 'A code has been sent to your email. '
//                                 'Please check your inbox and verify your account.',);
//                             context.goNamed(AppRouter.signUpVerify,extra: _emailController.text.trim());
//
//                             // showDialog(
//                             //   context: context,
//                             //   builder: (context) => AlertDialog(
//                             //     title: const Text('Verify email'),
//                             //     content: Text(
//                             //       'A code has been sent to your email. '
//                             //       'Please check your inbox and verify your account.',
//                             //     ),
//                             //     actions: [
//                             //       TextButton(
//                             //         onPressed: () {
//                             //           context.pop();
//                             //           context.pushNamed(AppRouter.signInVerify,
//                             //               extra: _emailController.text.trim());
//                             //         },
//                             //         child: const Text('OK'),
//                             //       ),
//                             //     ],
//                             //   ),
//                             // );
//                           }
//                         },
//                         //* SignUpPageBloc builder
//                         builder: (context, state) {
//                           if (state.blocStatus.isLoading) {
//                             return const Loader();
//                           }
//                           return Form(
//                             key: _formKey,
//                             child: Padding(
//                               padding: EdgeInsets.all(16),
//                               child: Column(
//                                 children: [
//                                   //* Full name field
//                                   CustomTextFormFieldOutlined(
//                                     controller: _fullNameController,
//                                     label: 'Full name',
//                                     validator: (value) => _fullNameValidator(value?.trim()),
//                                     prefixIcon: Icon(Icons.person_outlined),
//                                   ),
//                                   SizedBox(height: 12),
//                                   //* Email field
//                                   CustomTextFormFieldOutlined(
//                                     controller: _emailController,
//                                     label: 'Email',
//                                     validator: (value) => _emailValidator(value?.trim()),
//                                     prefixIcon: Icon(Icons.email_outlined),
//                                   ),
//                                   SizedBox(height: 10),
//                                   //* Sign up button
//                                   SizedBox(
//                                     width: double.infinity,
//                                     child: ElevatedButton(
//                                       onPressed: () {
//                                         if (_formKey.currentState?.validate() ?? false) {
//                                           context.read<AuthBloc>().add(AuthSignUpWithEmail(
//                                               email: _emailController.text.trim(),
//                                               fullName: _fullNameController.text.trim()));
//                                         }
//                                       },
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor: Theme.of(context).colorScheme.primary,
//                                         foregroundColor: Colors.white,
//                                       ),
//                                       child: const Text(
//                                         'Sign up',
//                                         style: TextStyle(
//                                           fontSize: 16.0,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   //* Sign in instead button
//                                   Align(
//                                     alignment: Alignment.center,
//                                     child: Row(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         Text(
//                                           'Already have an account?',
//                                           style: TextStyle(
//                                             color: Theme.of(context).colorScheme.onSurface,
//                                           ),
//                                         ),
//                                         TextButton(
//                                           onPressed: () {
//                                             context.goNamed(AppRouter.signIn);
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
//                                               'Sign in',
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
//                                   //* Vote as a guest button
//                                   TextButton(
//                                     onPressed: () {},
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
//                                           // color: Theme.of(context).colorScheme.surface,
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
//   //* Full name validator
//   String? _fullNameValidator(String? value) {
//     String? valueTrm = value?.trim();
//
//     if (valueTrm == null || valueTrm.isEmpty) {
//       return 'Please enter your name';
//     }
//     if (valueTrm.length < 3) {
//       return 'At least 2 characters long';
//     }
//     if (!RegExp(r'^[a-zA-Z]+$').hasMatch(valueTrm)) {
//       return 'Can only contain letters';
//     }
//     return null;
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
