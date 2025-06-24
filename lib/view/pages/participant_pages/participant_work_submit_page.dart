import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:swift_contest/model/data_models/user.dart';
import 'package:swift_contest/utils/functions/request_storage_permissions.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/participant_work_submit_page_bloc/participant_work_submit_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class ParticipantWorkSubmitPage extends StatefulWidget {
  final String contestId;

  const ParticipantWorkSubmitPage({required this.contestId, super.key});

  @override
  State<ParticipantWorkSubmitPage> createState() => _ParticipantWorkSubmitPageState();
}

class _ParticipantWorkSubmitPageState extends State<ParticipantWorkSubmitPage> {
  late User user;
  late String contestId;
  final detailsFormKey = GlobalKey<FormState>();
  final imagesFormKey = GlobalKey<FormState>();
  final fileFormKey = GlobalKey<FormState>();

  List<GlobalKey<FormState>> get formKeys => [detailsFormKey, imagesFormKey, fileFormKey];
  int currentStep = 0;
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final List<XFile> images = [];
  File? file;

  @override
  void initState() {
    super.initState();
    contestId = widget.contestId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    user = context.read<AuthBloc>().state.user!;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ParticipantWorkSubmitPageBloc, ParticipantWorkSubmitPageState>(
      listener: (context, state) {
        if (state.status.isSuccess && state.sourceEvent is ParticipantWorkSubmitPageSubmitWork) {
          context.pop(true);
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(title: 'Submit work'),
        body: BlocBuilder<ParticipantWorkSubmitPageBloc, ParticipantWorkSubmitPageState>(
          builder: (context, state) {
            if (state.status.isLoading) {
              return Loader();
            }
            return Stepper(
              type: StepperType.horizontal,
              elevation: 0,
              steps: getSteps(),
              currentStep: currentStep,
              onStepContinue: () {
                final isLastStep = (currentStep == getSteps().length - 1);
                if (formKeys[currentStep].currentState?.validate() ?? false) {
                  if (isLastStep) {
                    final name = nameController.text;
                    final description = descriptionController.text;
                    context
                        .read<ParticipantWorkSubmitPageBloc>()
                        .add(ParticipantWorkSubmitPageSubmitWork(
                          contestId: contestId,
                          participantId: user.id,
                          name: name,
                          description: description,
                          images: images,
                          file: file!,
                        ));
                  } else {
                    setState(() => ++currentStep);
                  }
                }
              },
              onStepCancel: () {
                (currentStep == 0) ? null : setState(() => --currentStep);
              },
              controlsBuilder: (context, details) {
                final isLastStep = details.currentStep == getSteps().length - 1;
                return Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment:
                        (currentStep == 0) ? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
                    spacing: 12,
                    children: [
                      if (details.currentStep != 0)
                        ElevatedButton(
                          onPressed: details.onStepCancel,
                          child: Text('Back'),
                        ),
                      ElevatedButton(
                        onPressed: details.onStepContinue,
                        child: isLastStep ? Text('Submit') : Text('Next'),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  //* Steps
  List<Step> getSteps() => [
        //* Details
        Step(
          state: currentStep >= 1 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 0,
          title: Text(''),
          content: Form(
            key: detailsFormKey,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Details',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                SizedBox(height: 20),
                CustomTextFormFieldOutlined(
                  controller: nameController,
                  label: 'Name',
                  validator: (value) => nameValidator(value?.trim()),
                ),
                SizedBox(height: 8),
                CustomTextFormFieldOutlined(
                  controller: descriptionController,
                  label: 'Description',
                  validator: (value) => descriptionValidator(value?.trim()),
                ),
              ],
            ),
          ),
        ),
        //* Images
        Step(
          state: currentStep >= 2 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 1,
          title: Text(''),
          content: Form(
            key: imagesFormKey,
            child: FormField(
              validator: (value) => imagesValidator(images),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              builder: (field) {
                return Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Images',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                    SizedBox(height: 20),
                    (images.isEmpty)
                        ? Center(child: Text('No image selected yet'))
                        : GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 4,
                              crossAxisSpacing: 4,
                            ),
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: images.length,
                            itemBuilder: (context, index) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: (kIsWeb)
                                    ? Image.network(
                                        images[index].path,
                                        filterQuality: FilterQuality.medium,
                                      )
                                    : Image.file(
                                        File(images[index].path),
                                        fit: BoxFit.cover,
                                        width: 5,
                                        filterQuality: FilterQuality.medium,
                                        frameBuilder:
                                            (context, child, frame, wasSynchronouslyLoaded) {
                                          if (wasSynchronouslyLoaded || frame != null) return child;
                                          return const Loader();
                                        },
                                      ),
                              );
                            },
                          ),
                    FilledButton(
                      onPressed: () async {
                        final choice = await _showImagesDialog(context: context);
                        if (choice) {
                          var res = await pickMultipleImages();
                          if (res.isEmpty) return;
                          if (res.length > 6) {
                            res = res.getRange(0, 6).toList(growable: false);
                            if (mounted) {
                              showSnackBar(
                                context: context,
                                text: 'Exceeded images have been discarded',
                              );
                            }
                          }
                          setState(() {
                            images.clear();
                            images.addAll(res);
                            field.didChange(images);
                          });
                        }
                      },
                      child: Text('Pick images'),
                    ),
                    if (field.hasError)
                      Text('Select at least one image', style: TextStyle(color: Colors.red)),
                  ],
                );
              },
            ),
          ),
        ),
        //* Images
        Step(
          state: currentStep >= 3 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 2,
          title: Text(''),
          content: Form(
            key: fileFormKey,
            child: FormField(
              validator: (value) => (file == null) ? '' : null,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              builder: (field) {
                return Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'File',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                    SizedBox(height: 20),
                    (file == null)
                        ? Center(child: Text('No file selected yet'))
                        : Card(
                            elevation: 0.1,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(path.basename(file!.path)),
                            ),
                          ),
                    FilledButton(
                      onPressed: () async {
                        if (!await requestStoragePermission()) {
                          if (mounted) {
                            showSnackBar(context: context, text: 'Permission denied');
                          }
                          return;
                        }
                        final pickedFile = await _pickFile();
                        if (pickedFile == null) {
                          return;
                        }
                        setState(() {
                          file = pickedFile;
                        });
                        field.didChange(file);
                      },
                      child: Text('Pick file'),
                    ),
                    if (field.hasError)
                      Text(
                        'Select a file',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ];
}

Future<bool> _showImagesDialog({required BuildContext context}) async {
  bool choice = false;
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Pick images'),
      content: Text('Select at most 6 images. Exceeded images will be discarded.\n'
          'The first image will represent the cover of the contest'),
      actions: [
        TextButton(
          onPressed: () {
            context.pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            choice = true;
            context.pop();
          },
          child: const Text('Ok'),
        ),
      ],
    ),
  );
  return choice;
}

Future<File?> _pickFile() async {
  FilePickerResult? res = await FilePicker.platform.pickFiles(
    type: FileType.any,
    allowMultiple: false,
  );

  if (res != null) {
    PlatformFile pickedFile = res.files.first;
    return File(pickedFile.path!);
  }
  return null;
}

String? nameValidator(String? value) {
  if (value == null || value.isEmpty) {
    return '';
  }
  if (value.length < 3) {
    return 'At least 3 characters long';
  }
  return null;
}

String? descriptionValidator(String? value) {
  if (value == null || value.isEmpty) {
    return '';
  }
  if (value.length < 3) {
    return 'At least 3 characters long';
  }
  return null;
}

String? imagesValidator(List<XFile> images) {
  if (images.isEmpty) {
    return '';
  }
  return null;
}

Future<List<XFile>> pickMultipleImages() async {
  final ImagePicker picker = ImagePicker();
  final List<XFile> pickedImages = await picker.pickMultiImage(imageQuality: 90);

  return pickedImages;
}

Widget buildImageForWeb(XFile file) {
  return FutureBuilder<Uint8List>(
    future: file.readAsBytes(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return Image.memory(
          snapshot.data!,
          fit: BoxFit.cover,
        );
      } else if (snapshot.hasError) {
        return const Icon(Icons.error);
      } else {
        return const Loader();
      }
    },
  );
}

// import 'dart:io';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:swift_contest/model/models/extended_contest.dart';
// import 'package:swift_contest/model/models/user.dart';
// import 'package:swift_contest/utils/di/di.dart';
// import 'package:swift_contest/utils/themes/color_scheme_x.dart';
// import 'package:swift_contest/view/widgets/custom_app_bar.dart';
// import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
// import 'package:swift_contest/view/widgets/loader.dart';
// import 'package:swift_contest/view/widgets/show_snack_bar.dart';
// import 'package:swift_contest/viewmodel/blocs/app_auth_bloc/app_auth_bloc.dart';
// import 'package:swift_contest/viewmodel/blocs/work_submit_bloc/work_submit_bloc.dart';
//
// class WorkSubmitPage extends StatefulWidget {
//   final ExtendedContest extendedContest;
//   const WorkSubmitPage({required this.extendedContest, super.key});
//
//   @override
//   State<WorkSubmitPage> createState() => _WorkSubmitPageState();
// }
//
// class _WorkSubmitPageState extends State<WorkSubmitPage> {
//   late User user;
//   final detailsFormKey = GlobalKey<FormState>();
//   final imagesFormKey = GlobalKey<FormState>();
//
//   List<GlobalKey<FormState>> get formKeys => [detailsFormKey, imagesFormKey];
//   int currentStep = 0;
//   final nameController = TextEditingController();
//   final descriptionController = TextEditingController();
//   final List<XFile> images = [];
//
//   @override
//   void initState() {
//     super.initState();
//     context.read<AppAuthBloc>().add(AppAuthCurrentUserAndProfile());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<AppAuthBloc, AppAuthState>(
//       listener: (context, state) {
//         if (state is AppAuthFailure || state is AppAuthInitial) {
//           context.go('/signin');
//         }
//         if (state is AppAuthSuccess) {
//           user = state.user;
//         }
//       },
//       child: BlocProvider(
//         create: (context) => getIt<WorkSubmitBloc>(),
//         child: BlocBuilder<WorkSubmitBloc, WorkSubmitState>(
//           builder: (context, state) {
//             return Scaffold(
//               appBar: CustomAppBar(title: 'Submit work'),
//               body: Stepper(
//                 type: StepperType.horizontal,
//                 physics: ScrollPhysics(),
//                 elevation: 0,
//                 steps: getSteps(),
//                 currentStep: currentStep,
//                 onStepContinue: () {
//                   final isLastStep = (currentStep == getSteps().length - 1);
//                   if (formKeys[currentStep].currentState?.validate() ?? false) {
//                     if (isLastStep) {
//                       final name = nameController.text;
//                       final description = descriptionController.text;
//                       context.read<WorkSubmitBloc>().add(SubmitWork(
//                         contestId: widget.extendedContest.contest.id,
//                             participantId: user.id,
//                             name: name,
//                             description: description,
//                             images: images,
//                           ));
//                     } else {
//                       setState(() => ++currentStep);
//                     }
//                   }
//                 },
//                 onStepCancel: () {
//                   (currentStep == 0) ? null : setState(() => --currentStep);
//                 },
//                 controlsBuilder: (context, details) {
//                   final isLastStep = details.currentStep == getSteps().length - 1;
//                   return Container(
//                     margin: EdgeInsets.only(top: 20),
//                     child: Row(
//                       mainAxisAlignment: (currentStep == 0)
//                           ? MainAxisAlignment.end
//                           : MainAxisAlignment.spaceBetween,
//                       spacing: 12,
//                       children: [
//                         if (details.currentStep != 0)
//                           ElevatedButton(
//                             onPressed: details.onStepCancel,
//                             child: Text('Back'),
//                           ),
//                         ElevatedButton(
//                           onPressed: details.onStepContinue,
//                           child: isLastStep
//                               ? BlocConsumer<WorkSubmitBloc, WorkSubmitState>(
//                                   listener: (context, state) {
//                                     if (state is WorkSubmitSuccess) {
//                                       showSnackBar(
//                                           context: context, text: 'Work submitted successfully');
//                                       context.pop();
//                                     }
//                                   },
//                                   builder: (context, state) {
//                                     if (state is WorkSubmitLoading) {
//                                       return Loader();
//                                     }
//                                     return Text('Submit');
//                                   },
//                                 )
//                               : Text('Next'),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   //* Steps
//   List<Step> getSteps() => [
//         //* Details
//         Step(
//           state: currentStep >= 1 ? StepState.complete : StepState.indexed,
//           isActive: currentStep >= 0,
//           title: Text(
//             'Details',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.w600,
//               color: (currentStep == 0)
//                   ? Theme.of(context).colorScheme.primary
//                   : Theme.of(context).colorScheme.grey9,
//             ),
//           ),
//           content: Form(
//             key: detailsFormKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.max,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               spacing: 8,
//               children: [
//                 CustomTextFormFieldOutlined(
//                   controller: nameController,
//                   label: 'Name',
//                   validator: (value) => nameValidator(value?.trim()),
//                 ),
//                 CustomTextFormFieldOutlined(
//                   controller: descriptionController,
//                   label: 'Description',
//                   validator: (value) => descriptionValidator(value?.trim()),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         //* Images
//         Step(
//           state: currentStep >= 2 ? StepState.complete : StepState.indexed,
//           isActive: currentStep >= 1,
//           title: Text(
//             'Images',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.w600,
//               color: (currentStep == 1)
//                   ? Theme.of(context).colorScheme.primary
//                   : Theme.of(context).colorScheme.grey9,
//             ),
//           ),
//           content: Form(
//             key: imagesFormKey,
//             child: FormField(
//               validator: (value) => imagesValidator(images),
//               autovalidateMode: AutovalidateMode.onUserInteraction,
//               builder: (field) {
//                 return Column(
//                   children: [
//                     (images.isEmpty)
//                         ? Center(child: Text('No images selected yet.'))
//                         : GridView.builder(
//                             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 3,
//                               mainAxisSpacing: 4,
//                               crossAxisSpacing: 4,
//                             ),
//                             shrinkWrap: true,
//                             physics: NeverScrollableScrollPhysics(),
//                             itemCount: images.length,
//                             itemBuilder: (context, index) {
//                               return ClipRRect(
//                                 borderRadius: BorderRadius.circular(8),
//                                 child: (kIsWeb)
//                                     ? Image.network(
//                                         images[index].path,
//                                         filterQuality: FilterQuality.medium,
//                                       )
//                                     : Image.file(
//                                         File(images[index].path),
//                                         fit: BoxFit.cover,
//                                         width: 5,
//                                         filterQuality: FilterQuality.medium,
//                                         frameBuilder:
//                                             (context, child, frame, wasSynchronouslyLoaded) {
//                                           if (wasSynchronouslyLoaded || frame != null) return child;
//                                           return const Loader();
//                                         },
//                                       ),
//                               );
//                             },
//                           ),
//                     FilledButton(
//                       onPressed: () async {
//                         final choice = await showImagesDialog(context: context);
//                         if (choice) {
//                           var res = await pickMultipleImages();
//                           if (res.isEmpty) return;
//                           if (res.length > 6) {
//                             res = res.getRange(0, 6).toList(growable: false);
//                             if (mounted) {
//                               showSnackBar(
//                                 context: context,
//                                 text: 'Exceeded images have been discarded',
//                               );
//                             }
//                           }
//                           setState(() {
//                             images.clear();
//                             images.addAll(res);
//                             field.didChange(images);
//                           });
//                         }
//                       },
//                       child: Text('Pick images'),
//                     ),
//                     if (field.hasError)
//                       Text('Select at least one image', style: TextStyle(color: Colors.red)),
//                   ],
//                 );
//               },
//             ),
//           ),
//         ),
//       ];
//
//   Future<bool> showImagesDialog({required BuildContext context}) async {
//     bool choice = false;
//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Pick images'),
//         content: Text('Select at most 6 images. Exceeded images will be discarded.\n'
//             'The first image will represent the cover of the contest'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               context.pop();
//             },
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               choice = true;
//               context.pop();
//             },
//             child: const Text('Ok'),
//           ),
//         ],
//       ),
//     );
//     return choice;
//   }
// }
//
// String? nameValidator(String? value) {
//   if (value == null || value.isEmpty) {
//     return '';
//   }
//   if (value.length < 3) {
//     return 'At least 3 characters long';
//   }
//   return null;
// }
//
// String? descriptionValidator(String? value) {
//   if (value == null || value.isEmpty) {
//     return '';
//   }
//   if (value.length < 3) {
//     return 'At least 3 characters long';
//   }
//   return null;
// }
//
// String? imagesValidator(List<XFile> images) {
//   if (images.isEmpty) {
//     return '';
//   }
//   return null;
// }
//
// String? noEmptyValidator(String? value) {
//   if (value == null || value.isEmpty) {
//     return '';
//   }
//   return null;
// }
//
// Future<List<XFile>> pickMultipleImages() async {
//   final ImagePicker picker = ImagePicker();
//   final List<XFile> pickedImages = await picker.pickMultiImage(imageQuality: 90);
//
//   return pickedImages;
// }
//
// Widget buildImageForWeb(XFile file) {
//   return FutureBuilder<Uint8List>(
//     future: file.readAsBytes(),
//     builder: (context, snapshot) {
//       if (snapshot.hasData) {
//         return Image.memory(
//           snapshot.data!,
//           fit: BoxFit.cover,
//         );
//       } else if (snapshot.hasError) {
//         return const Icon(Icons.error);
//       } else {
//         return const Loader();
//       }
//     },
//   );
// }
