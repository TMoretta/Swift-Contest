import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swift_contest/model/data_models/place.dart';
import 'package:swift_contest/utils/router/app_router.gr.dart';
import 'package:swift_contest/utils/validators/validators.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/date_picker_form_field.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/place_picker_form_field.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/time_picker_form_field.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_contest_creation_page_bloc/organizer_contest_creation_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

@RoutePage()
class OrganizerContestCreationPage extends StatefulWidget implements AutoRouteWrapper {
  const OrganizerContestCreationPage({super.key});

  @override
  State<OrganizerContestCreationPage> createState() => _OrganizerContestCreationPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<OrganizerContestCreationPageBloc>(
      create: (context) => OrganizerContestCreationPageBloc(
        storageRepository: context.read(),
        organizerRepository: context.read(),
      ),
      child: this,
    );
  }
}

class _OrganizerContestCreationPageState extends State<OrganizerContestCreationPage> {
  late String profileId;
  final firstFormKey = GlobalKey<FormState>();
  final secondFormKey = GlobalKey<FormState>();
  final thirdFormKey = GlobalKey<FormState>();

  List<GlobalKey<FormState>> get formKeys => [firstFormKey, secondFormKey, thirdFormKey];
  int currentStep = 0;
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateController = TextEditingController();
  DateTime? date;
  final timeController = TextEditingController();
  TimeOfDay? time;
  final placeController = TextEditingController();
  PlaceModel? place;
  final worksSubmissionStartController = TextEditingController();
  DateTime? worksSubmissionStart;
  final worksSubmissionEndController = TextEditingController();
  DateTime? worksSubmissionEnd;
  final List<XFile> images = [];
  final nameFocusNode = FocusNode();
  final descriptionFocusNode = FocusNode();
  final dateFocusNode = FocusNode();
  final worksSubmissionStartFocusNode = FocusNode();
  final worksSubmissionEndFocusNode = FocusNode();
  final placeFocusNode = FocusNode();
  final timeFocusNode = FocusNode();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    profileId = context.read<AuthBloc>().state.profile!.id;
  }

  @override
  void dispose() {
    context.hideLoader();
    nameController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    timeController.dispose();
    placeController.dispose();
    worksSubmissionStartController.dispose();
    worksSubmissionEndController.dispose();
    nameFocusNode.dispose();
    descriptionFocusNode.dispose();
    dateFocusNode.dispose();
    worksSubmissionStartFocusNode.dispose();
    worksSubmissionEndFocusNode.dispose();
    placeFocusNode.dispose();
    timeFocusNode.dispose();
    for (var formKey in formKeys) {
      formKey.currentState?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrganizerContestCreationPageBloc, OrganizerContestCreationPageState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
        if (state.status.isLoading) {
          context.showLoader();
        } else {
          context.hideLoader();
        }
        if (state.status.isSuccess &&
            state.sourceEvent is OrganizerContestCreationPageCreateContest) {
          showSnackBar(context: context, text: 'Contest created successfully');
          context.router.pop(true);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: CustomAppBar(title: 'Contest Creation'),
          body: Builder(
            builder: (context) {
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
                      final dateTime =
                          DateTime(date!.year, date!.month, date!.day, time!.hour, time!.minute);
                      context.read<OrganizerContestCreationPageBloc>().add(
                            OrganizerContestCreationPageCreateContest(
                              name: name,
                              description: description,
                              placeAddress: place!.address!,
                              placeLat: place!.lat!,
                              placeLon: place!.lon!,
                              dateTime: dateTime,
                              worksSubmissionStart: worksSubmissionStart!,
                              worksSubmissionEnd: worksSubmissionEnd!,
                              images: images,
                            ),
                          );
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
                      mainAxisAlignment: (currentStep == 0)
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.spaceBetween,
                      spacing: 12,
                      children: [
                        if (details.currentStep != 0)
                          ElevatedButton(
                            onPressed: details.onStepCancel,
                            child: Text('Back'),
                          ),
                        ElevatedButton(
                          onPressed: details.onStepContinue,
                          child: isLastStep ? Text('Create') : Text('Next'),
                        ),
                      ],
                    ),
                  );
                },
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
            key: firstFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                CustomTextFormField(
                  borderType: InputBorderType.outlined,
                  controller: nameController,
                  focusNode: nameFocusNode,
                  label: 'Name',
                  validator: (value) => nameValidator(value?.trim()),
                  minLines: 1,
                  maxLines: 2,
                ),
                CustomTextFormField(
                  borderType: InputBorderType.outlined,
                  controller: descriptionController,
                  focusNode: descriptionFocusNode,
                  label: 'Description',
                  validator: (value) => descriptionValidator(value?.trim()),
                  minLines: 2,
                  maxLines: 4,
                ),
                DatePickerFormField(
                  controller: dateController,
                  focusNode: dateFocusNode,
                  initialDate: date,
                  label: 'Date',
                  validator: (value) => dateValidator(value),
                  onSelected: (dateValue) {
                    setState(() {
                      date = dateValue;
                    });
                  },
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                TimePickerFormField(
                  controller: timeController,
                  focusNode: timeFocusNode,
                  initialTime: time,
                  label: 'Time',
                  validator: (value) => timeValidator(value),
                  onSelected: (timeValue) {
                    setState(() {
                      time = timeValue;
                    });
                  },
                  prefixIcon: Icon(Icons.access_time_outlined),
                ),
                PlacePickerFormField(
                  controller: placeController,
                  focusNode: placeFocusNode,
                  label: 'Location',
                  validator: (value) => locationValidator(value),
                  prefixIcon: Icon(Icons.place_outlined),
                  suffixIcon: TextButton(
                    onPressed: () async {
                      final PlaceModel? placeNullable =
                          await context.router.push(PlaceSearchRoute());
                      if (placeNullable != null) {
                        placeController.text = placeNullable.address!;
                        place = placeNullable;
                      }
                    },
                    child: Text('Select'),
                  ),
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
            key: secondFormKey,
            child: FormField(
              validator: (value) => _imagesValidator(images),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              builder: (field) {
                return Column(
                  children: [
                    (images.isEmpty)
                        ? Center(child: Text('No image selected yet.'))
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
                                    // ? buildImageForWeb(images[index])
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
                                          if (wasSynchronouslyLoaded || frame != null) {
                                            return child;
                                          }
                                          return const Loader();
                                        },
                                      ),
                              );
                            },
                          ),
                    SizedBox(height: 10),
                    FilledButton(
                      onPressed: () async {
                        final choice = await showImagesDialog(context: context);
                        if (choice == true) {
                          var res = await pickMultipleImages();
                          if (res.isEmpty) {
                            return;
                          }
                          if (res.length > 6) {
                            res = res.getRange(0, 6).toList(growable: false);
                            if (mounted) {
                              showSnackBar(
                                context: context,
                                text: 'Exceeded images have been discarded',
                              );
                            }
                          }
                          images.clear();
                          setState(() {
                            images.addAll(res);
                          });
                          field.didChange(images);
                        }
                      },
                      child: Text('Pick images'),
                    ),
                    if (field.hasError)
                      Text('Select at least one image',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(color: Theme.of(context).colorScheme.error)),
                  ],
                );
              },
            ),
          ),
        ),
        //* Settings
        Step(
          state: currentStep >= 3 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 2,
          title: Text(''),
          content: Form(
            key: thirdFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text(
                  'Work upload deadline for participants',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 10),
                DatePickerFormField(
                  controller: worksSubmissionStartController,
                  focusNode: worksSubmissionStartFocusNode,
                  initialDate: worksSubmissionStart,
                  label: 'Start date',
                  validator: (value) =>
                      worksSubmissionStartValidator(value, date!, worksSubmissionEnd),
                  onSelected: (workDateStartValue) {
                    setState(() {
                      worksSubmissionStart = workDateStartValue;
                    });
                  },
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                DatePickerFormField(
                  controller: worksSubmissionEndController,
                  focusNode: worksSubmissionEndFocusNode,
                  initialDate: worksSubmissionEnd,
                  label: 'End date',
                  validator: (value) =>
                      worksSubmissionEndValidator(value, date!, worksSubmissionStart),
                  onSelected: (workDateEndValue) {
                    setState(() {
                      worksSubmissionEnd = workDateEndValue;
                    });
                  },
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
              ],
            ),
          ),
        ),
      ];
}

Future<bool?> showImagesDialog({required BuildContext context}) async {
  return await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Pick images'),
      content: Text('Select at most 6 images. Exceeded images will be discarded.\n'
          'The first image will represent the cover of the contest'),
      actions: [
        TextButton(
          onPressed: () {
            context.router.pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            context.router.pop(true);
          },
          child: const Text('Ok'),
        ),
      ],
    ),
  );
}

String? _imagesValidator(List<XFile> images) {
  if (images.isEmpty) {
    return '';
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

String? dateValidator(String? value) {
  if (value == null || value.isEmpty) {
    return '';
  }
  return null;
}

String? timeValidator(String? value) {
  if (value == null || value.isEmpty) {
    return '';
  }
  return null;
}

String? locationValidator(String? value) {
  if (value == null || value.isEmpty) {
    return '';
  }
  return null;
}

Future<List<XFile>> pickMultipleImages() async {
  final ImagePicker picker = ImagePicker();
  final List<XFile> pickedImages = await picker.pickMultiImage(imageQuality: 60);

  return pickedImages;
}
