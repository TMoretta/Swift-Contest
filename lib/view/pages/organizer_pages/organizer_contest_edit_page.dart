import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pinput/pinput.dart';
import 'package:swift_contest/model/data_models/place.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/utils/labels/labels.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/date_picker_form_field.dart';
import 'package:swift_contest/view/widgets/list_view_with_central_label.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/place_picker_form_field.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/time_picker_form_field.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_contest_edit_page_bloc/organizer_contest_edit_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class OrganizerContestEditPage extends StatefulWidget {
  final String contestId;

  const OrganizerContestEditPage({required this.contestId, super.key});

  @override
  State<OrganizerContestEditPage> createState() => _OrganizerContestEditPageState();
}

class _OrganizerContestEditPageState extends State<OrganizerContestEditPage> {
  
  late String contestId;
  late Profile profile;
  final firstFormKey = GlobalKey<FormState>();
  final secondFormKey = GlobalKey<FormState>();
  final thirdFormKey = GlobalKey<FormState>();

  bool isPageInitialized = false;

  List<GlobalKey<FormState>> get formKeys => [firstFormKey, secondFormKey, thirdFormKey];
  int currentStep = 0;
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateController = TextEditingController();
  DateTime? date;
  final timeController = TextEditingController();
  TimeOfDay? time;
  final placeController = TextEditingController();
  Place? place;
  final worksSubmissionStartController = TextEditingController();
  DateTime? worksSubmissionStart;
  final worksSubmissionEndController = TextEditingController();
  DateTime? worksSubmissionEnd;
  final List<String> oldImagesUrls = [];
  final List<XFile> images = [];

  @override
  void initState() {
    super.initState();
    contestId = widget.contestId;
    profile = context.read<AuthBloc>().state.profile!;
    context
        .read<OrganizerContestEditPageBloc>()
        .add(OrganizerContestEditPageInit(contestId: contestId));
  }

  @override
  void dispose() {
    context.hideLoader();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrganizerContestEditPageBloc, OrganizerContestEditPageState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
        if(state.status.isLoading) {
          context.showLoader();
        } else {
          context.hideLoader();
        }
        if (state.status.isSuccess && state.sourceEvent is OrganizerContestEditPageEditContest) {
          showSnackBar(context: context, text: 'Contest updated successfully');
          context.pop(true);
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(title: 'Edit contest'),
        body: BlocBuilder<OrganizerContestEditPageBloc, OrganizerContestEditPageState>(
          builder: (context, state) {
            switch (state.status) {
              case BlocStatus.initial:
                return VoidWidget();
              case BlocStatus.loading:
                if (state.sourceEvent is OrganizerContestEditPageInit) {
                  return VoidWidget();
                } else {
                  continue successCase;
                }
              case BlocStatus.failure:
                if (state.sourceEvent is OrganizerContestEditPageInit) {
                  return RefreshIndicator.adaptive(
                    onRefresh: () async => context
                        .read<OrganizerContestEditPageBloc>()
                        .add(OrganizerContestEditPageInit(contestId: contestId)),
                    child: ListViewWithCentralLabel(label: Labels.anErrorOccurred),
                  );
                } else {
                  continue successCase;
                }
              successCase:
              case BlocStatus.success:
                if (!isPageInitialized) {
                  final contestDetailsBundle = state.contestDetailsBundle!;
                  nameController.setText(contestDetailsBundle.contest.name);
                  descriptionController.setText(contestDetailsBundle.contest.description);
                  date = contestDetailsBundle.contest.dateTime;
                  dateController.setText(DateFormat('dd/MM/yyyy').format(date!));
                  time = TimeOfDay.fromDateTime(contestDetailsBundle.contest.dateTime);
                  timeController.setText(
                      '${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}');
                  place = contestDetailsBundle.place;
                  placeController.setText(place!.address);
                  worksSubmissionStart = contestDetailsBundle.contest.worksSubmissionStart;
                  worksSubmissionEnd = contestDetailsBundle.contest.worksSubmissionEnd;
                  worksSubmissionStartController
                      .setText(DateFormat('dd/MM/yyyy').format(worksSubmissionStart!));
                  worksSubmissionEndController
                      .setText(DateFormat('dd/MM/yyyy').format(worksSubmissionEnd!));
                  oldImagesUrls.addAll(contestDetailsBundle.contest.imagesUrls);
                  isPageInitialized = true;
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
                        final dateTime = DateTime(
                            date!.year, date!.month, date!.day, time!.hour, time!.minute);
                        context.read<OrganizerContestEditPageBloc>().add(
                              OrganizerContestEditPageEditContest(
                                contestId: contestId,
                                name: name,
                                description: description,
                                place: place!,
                                dateTime: dateTime,
                                worksSubmissionStart: worksSubmissionStart!,
                                worksSubmissionEnd: worksSubmissionEnd!,
                                images: (images.isNotEmpty) ? images : null,
                                oldImagesUrls: oldImagesUrls,
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
                              onPressed: () {
                                details.onStepCancel!();
                              },
                              child: Text('Back'),
                            ),
                          ElevatedButton(
                            onPressed: () {
                              details.onStepContinue!();
                            },
                            child: isLastStep ? Text('Edit') : Text('Next'),
                          ),
                        ],
                      ),
                    );
                  },
                );
            }
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
            key: firstFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                CustomTextFormField(
                  borderType: InputBorderType.outlined,
                  controller: nameController,
                  label: 'Name',
                  validator: (value) => nameValidator(value?.trim()),
                  minLines: 1,
                  maxLines: 2,
                ),
                CustomTextFormField(
                  borderType: InputBorderType.outlined,
                  controller: descriptionController,
                  label: 'Description',
                  validator: (value) => descriptionValidator(value?.trim()),
                  minLines: 2,
                  maxLines: 4,
                ),
                DatePickerFormField(
                  controller: dateController,
                  label: 'Date',
                  validator: (value) => dateValidator(value),
                  onSelected: (dateValue) => date = dateValue,
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                TimePickerFormField(
                  controller: timeController,
                  label: 'Time',
                  validator: (value) => timeValidator(value),
                  onSelected: (timeValue) => time = timeValue,
                  prefixIcon: Icon(Icons.access_time_outlined),
                ),
                PlacePickerFormField(
                  controller: placeController,
                  label: 'Location',
                  validator: (value) => locationValidator(value),
                  prefixIcon: Icon(Icons.place_outlined),
                  suffixIcon: TextButton(
                    onPressed: () async {
                      final PlaceNullable? placeNullable = await context.pushNamed(AppRouter.placeSearch);
                      if(placeNullable!=null) {
                        placeController.text = placeNullable.address!;
                        place = place?.copyWith(address: placeNullable.address,lat: placeNullable.lat,lon: placeNullable.lon);
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
              validator: (value) => _imagesValidator(images, oldImagesUrls),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              builder: (field) {
                return Column(
                  children: [
                    if (images.isEmpty && oldImagesUrls.isEmpty)
                      Center(child: Text('No image selected yet.'))
                    else if (images.isEmpty && oldImagesUrls.isNotEmpty)
                      GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                        ),
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: oldImagesUrls.length,
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              oldImagesUrls[index],
                              fit: BoxFit.cover,
                              width: 5,
                              filterQuality: FilterQuality.medium,
                              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                if (wasSynchronouslyLoaded || frame != null) {
                                  return child;
                                }
                                return const Loader();
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/image_not_found.jpg',
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          );
                        },
                      )
                    else
                      GridView.builder(
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
                                    frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
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
                  label: 'Start date',
                  validator: (value) =>
                      _worksSubmissionStartValidator(value, date!, worksSubmissionEnd),
                  onSelected: (workDateStartValue) => worksSubmissionStart = workDateStartValue,
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                DatePickerFormField(
                  controller: worksSubmissionEndController,
                  label: 'End date',
                  validator: (value) =>
                      _worksSubmissionEndValidator(value, date!, worksSubmissionStart),
                  onSelected: (workDateEndValue) => worksSubmissionEnd = workDateEndValue,
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
            context.pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            context.pop(true);
          },
          child: const Text('Proceed'),
        ),
      ],
    ),
  );
}

String? _worksSubmissionStartValidator(
    String? value, DateTime contestDate, DateTime? worksSubmissionEnd) {
  if (value == null || value.isEmpty) {
    return '';
  }

  try {
    final DateTime worksSubmissionStart = DateFormat('dd/MM/yyyy').parse(value);
    if (worksSubmissionStart.isAfter(contestDate)) {
      return 'Can\'t be after contest date';
    }
    if (worksSubmissionEnd == null) {
      return null;
    }
    if (worksSubmissionStart.isAfter(worksSubmissionEnd)) {
      return 'Can\'t be after the date of the end';
    }
  } catch (e) {
    return 'Invalid date format';
  }
  return null;
}

String? _worksSubmissionEndValidator(
    String? value, DateTime contestDate, DateTime? worksSubmissionStart) {
  if (value == null || value.isEmpty) {
    return '';
  }

  try {
    final DateTime worksSubmissionEnd = DateFormat('dd/MM/yyyy').parse(value);
    if (worksSubmissionEnd.isAfter(contestDate)) {
      return 'Can\'t be after contest date';
    }
    if (worksSubmissionStart == null) {
      return null;
    }
    if (worksSubmissionEnd.isBefore(worksSubmissionStart)) {
      return 'Can\'t be before the date of begin';
    }
  } catch (e) {
    return 'Invalid date format';
  }
  return null;
}

String? _imagesValidator(List<XFile> images, List<String> oldImagesUrls) {
  if (images.isEmpty && oldImagesUrls.isEmpty) {
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
  final List<XFile> pickedImages = await picker.pickMultiImage(imageQuality: 80);

  return pickedImages;
}
