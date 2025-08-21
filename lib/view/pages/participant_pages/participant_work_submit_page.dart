import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swift_contest/utils/validators/validators.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/images_picker_form_field.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/participant_work_submit_page_bloc/participant_work_submit_page_bloc.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

@RoutePage()
class ParticipantWorkSubmitPage extends StatefulWidget implements AutoRouteWrapper {
  final String contestId;

  const ParticipantWorkSubmitPage({
    @PathParam('contestId') required this.contestId,
    super.key,
  });

  @override
  State<ParticipantWorkSubmitPage> createState() => _ParticipantWorkSubmitPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<ParticipantWorkSubmitPageBloc>(
      create: (context) => ParticipantWorkSubmitPageBloc(
        participantRepository: context.read(),
      ),
      child: this,
    );
  }
}

class _ParticipantWorkSubmitPageState extends State<ParticipantWorkSubmitPage> {
  late final String contestId;
  final GlobalKey<FormState> detailsFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> imagesFormKey = GlobalKey<FormState>();

  // final GlobalKey<FormState> fileFormKey = GlobalKey<FormState>();
  List<GlobalKey<FormState>> get formKeys => [detailsFormKey, imagesFormKey];

  int currentStep = 0;
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final nameFocusNode = FocusNode();
  final descriptionFocusNode = FocusNode();
  List<XFile> images = [];

  // File? file;

  @override
  void initState() {
    super.initState();
    contestId = widget.contestId;
  }

  @override
  void dispose() {
    context.hideLoader();
    nameController.dispose();
    descriptionController.dispose();
    nameFocusNode.dispose();
    descriptionFocusNode.dispose();
    for (var formKey in formKeys) {
      formKey.currentState?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ParticipantWorkSubmitPageBloc, ParticipantWorkSubmitPageState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
        if (state.status.isLoading) {
          context.showLoader();
        } else {
          context.hideLoader();
        }
        if (state.status.isSuccess && state.sourceEvent is ParticipantWorkSubmitPageSubmitWork) {
          context.router.pop(true);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: CustomAppBar(title: 'Submit work'),
          body: Stepper(
            type: StepperType.horizontal,
            elevation: 0,
            steps: getSteps(),
            currentStep: currentStep,
            onStepContinue: () {
              final isLastStep = (currentStep == getSteps().length - 1);
              if (formKeys[currentStep].currentState?.validate() ?? false) {
                // If valid, save the form to trigger `onSaved` callbacks and update state.
                formKeys[currentStep].currentState?.save();
                if (isLastStep) {
                  final name = nameController.text.trim();
                  final description = descriptionController.text.trim();
                  context
                      .read<ParticipantWorkSubmitPageBloc>()
                      .add(ParticipantWorkSubmitPageSubmitWork(
                        contestId: contestId,
                        name: name,
                        description: description,
                        images: images,
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
          ),
        );
      },
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
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                CustomTextFormField(
                  borderType: InputBorderType.outlined,
                  controller: nameController,
                  focusNode: nameFocusNode,
                  label: 'Name',
                  validator: titleValidator,
                  minLines: 1,
                  maxLines: 2,
                ),
                CustomTextFormField(
                  borderType: InputBorderType.outlined,
                  controller: descriptionController,
                  focusNode: descriptionFocusNode,
                  label: 'Description',
                  validator: descriptionValidator,
                  minLines: 2,
                  maxLines: 4,
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
            child: ImagesPickerFormField(
              maxImages: 5,
              validator: atLeastOneImageValidator,
              onSaved: (value) => images = value ?? [],
            ),
          ),
        ),
        //* File
        // Step(
        //   state: currentStep >= 3 ? StepState.complete : StepState.indexed,
        //   isActive: currentStep >= 2,
        //   title: Text(''),
        //   content: Form(
        //     key: fileFormKey,
        //     child: FormField(
        //       validator: (value) => (file == null) ? '' : null,
        //       autovalidateMode: AutovalidateMode.onUserInteraction,
        //       builder: (field) {
        //         return Column(
        //           children: [
        //             Align(
        //               alignment: Alignment.centerLeft,
        //               child: Text(
        //                 'File',
        //                 style: Theme.of(context)
        //                     .textTheme
        //                     .titleLarge
        //                     ?.copyWith(color: Theme.of(context).colorScheme.primary),
        //               ),
        //             ),
        //             SizedBox(height: 20),
        //             (file == null)
        //                 ? Center(child: Text('No file selected yet'))
        //                 : Card(
        //                     elevation: 0.1,
        //                     child: Padding(
        //                       padding: const EdgeInsets.all(12),
        //                       child: Text(path.basename(file!.path)),
        //                     ),
        //                   ),
        //             FilledButton(
        //               onPressed: () async {
        //                 if (!await requestStoragePermission()) {
        //                   if (mounted) {
        //                     showSnackBar(context: context, text: 'Permission denied');
        //                   }
        //                   return;
        //                 }
        //                 final pickedFile = await _pickFile();
        //                 if (pickedFile == null) {
        //                   return;
        //                 }
        //                 setState(() {
        //                   file = pickedFile;
        //                 });
        //                 field.didChange(file);
        //               },
        //               child: Text('Pick file'),
        //             ),
        //             if (field.hasError)
        //               Text(
        //                 'Select a file',
        //                 style: Theme.of(context).textTheme.labelMedium?.copyWith(
        //                       color: Theme.of(context).colorScheme.error,
        //                     ),
        //               ),
        //           ],
        //         );
        //       },
        //     ),
        //   ),
        // ),
      ];
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
