import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:swift_contest/model/data_models/contest/place.dart';
import 'package:swift_contest/model/data_models/user/user.dart';
import 'package:swift_contest/model/google_place_models/google_place.dart';
import 'package:swift_contest/utils/themes/color_scheme_extension.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/date_picker_field.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/view/widgets/place_picker_field.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/time_picker_field.dart';
import 'package:swift_contest/viewmodel/blocs/bloc_status.dart';
import 'package:swift_contest/viewmodel/blocs/global_blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_contest_creation_page_bloc/organizer_contest_creation_page_bloc.dart';
import 'package:swift_contest/viewmodel/repositories/contest_repository.dart';
import 'package:swift_contest/viewmodel/repositories/storage_repository.dart';

class OrganizerContestCreationPage extends StatefulWidget {
  const OrganizerContestCreationPage({super.key});

  @override
  State<OrganizerContestCreationPage> createState() => _OrganizerContestCreationPageState();
}

class _OrganizerContestCreationPageState extends State<OrganizerContestCreationPage> {
  late User user;
  final detailsFormKey = GlobalKey<FormState>();
  final imagesFormKey = GlobalKey<FormState>();
  final settingsFormKey = GlobalKey<FormState>();

  List<GlobalKey<FormState>> get formKeys => [detailsFormKey, imagesFormKey, settingsFormKey];
  int currentStep = 0;
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateController = TextEditingController();
  DateTime? date;
  final timeController = TextEditingController();
  TimeOfDay? time;
  final placeController = TextEditingController();
  GooglePlace? place;
  final worksDateTimeFromController = TextEditingController();
  DateTime? worksDateTimeFrom;
  final worksDateTimeToController = TextEditingController();
  DateTime? worksDateTimeTo;
  bool worksPreviewJurors = false;
  final List<XFile> images = [];

  @override
  void initState() {
    super.initState();
    final appAuthState = context.read<AuthBloc>().state;
    user = (appAuthState as AuthAuthenticated).user;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrganizerContestCreationPageBloc(
        contestRepository: context.read<ContestRepository>(),
        storageRepository: context.read<StorageRepository>(),
      ),
      child: BlocBuilder<OrganizerContestCreationPageBloc, OrganizerContestCreationPageState>(
        builder: (context, state) {
          return Scaffold(
            appBar: CustomAppBar(title: 'Contest Creation'),
            body: Stepper(
              type: StepperType.horizontal,
              physics: ScrollPhysics(),
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
                            organizerId: user.id,
                            place: Place(address: place!.address, lat: place!.lat, lon: place!.lon),
                            worksPreviewJurors: worksPreviewJurors,
                            dateTime: dateTime,
                            worksDateTimeFrom: worksDateTimeFrom!,
                            worksDateTimeTo: worksDateTimeTo!,
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
                        child: isLastStep
                            ? BlocConsumer<OrganizerContestCreationPageBloc,
                                OrganizerContestCreationPageState>(
                                listener: (context, state) {
                                  if (state.status.isSuccess) {
                                    showSnackBar(
                                        context: context, text: 'Contest created successfully');
                                    context.pop(true);
                                  }
                                },
                                builder: (context, state) {
                                  if (state.status.isLoading) {
                                    return Loader();
                                  }
                                  return Text('Create');
                                },
                              )
                            : Text('Next'),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  //* Steps
  List<Step> getSteps() => [
        //* Details
        Step(
          state: currentStep >= 1 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 0,
          title: Text(
            'Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: (currentStep == 0)
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.grey9,
            ),
          ),
          content: Form(
            key: detailsFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                CustomTextFormFieldOutlined(
                  controller: nameController,
                  label: 'Name',
                  validator: (value) => nameValidator(value?.trim()),
                ),
                CustomTextFormFieldOutlined(
                  controller: descriptionController,
                  label: 'Description',
                  validator: (value) => descriptionValidator(value?.trim()),
                ),
                DatePickerField(
                  controller: dateController,
                  label: 'Date',
                  validator: (value) => dateValidator(value),
                  onSelected: (dateValue) => date = dateValue,
                ),
                TimePickerField(
                  controller: timeController,
                  label: 'Time',
                  validator: (value) => timeValidator(value),
                  onSelected: (timeValue) => time = timeValue,
                ),
                PlacePickerField(
                  controller: placeController,
                  label: 'Location',
                  validator: (value) => locationValidator(value),
                  onSelected: (placeValue) => place = placeValue,
                ),
              ],
            ),
          ),
        ),
        //* Images
        Step(
          state: currentStep >= 2 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 1,
          title: Text(
            'Images',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: (currentStep == 1)
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.grey9,
            ),
          ),
          content: Form(
            key: imagesFormKey,
            child: FormField(
              validator: (value) => imagesValidator(images),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              builder: (field) {
                return Column(
                  children: [
                    (images.isEmpty)
                        ? Center(child: Text('No images selected yet.'))
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
                                          if (wasSynchronouslyLoaded || frame != null) return child;
                                          return const Loader();
                                        },
                                      ),
                              );
                            },
                          ),
                    FilledButton(
                      onPressed: () async {
                        final choice = await showImagesDialog(context: context);
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
        //* Settings
        Step(
          state: currentStep >= 3 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 2,
          title: Text(
            'Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: (currentStep == 2)
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.grey9,
            ),
          ),
          content: Form(
            key: settingsFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text('Work upload deadline for participants',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                SizedBox(height: 10),
                DatePickerField(
                  controller: worksDateTimeFromController,
                  label: 'Date from',
                  validator: (value) => workDateFromValidator(value),
                  onSelected: (workDateFromValue) => worksDateTimeFrom = workDateFromValue,
                ),
                DatePickerField(
                  controller: worksDateTimeToController,
                  label: 'Date to',
                  validator: (value) => workDateToValidator(value),
                  onSelected: (workDateToValue) => worksDateTimeTo = workDateToValue,
                ),
                SizedBox(height: 10),
                Text('Works preview for invited jurors',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                RadioListTile<bool>(
                  title: Text('Never'),
                  value: false,
                  groupValue: worksPreviewJurors,
                  contentPadding: EdgeInsets.all(1),
                  shape: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onChanged: (value) {
                    setState(
                      () => worksPreviewJurors = value!,
                    );
                  },
                ),
                RadioListTile<bool>(
                  title: Text('At participation\'s closure'),
                  value: true,
                  groupValue: worksPreviewJurors,
                  contentPadding: EdgeInsets.all(1),
                  shape: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onChanged: (value) {
                    setState(
                      () => worksPreviewJurors = value!,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ];

  Future<bool> showImagesDialog({required BuildContext context}) async {
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

  String? workDateFromValidator(String? value) {
    if (value == null || value.isEmpty) {
      return '';
    }
    if (worksDateTimeTo == null) {
      return null;
    }
    try {
      final DateTime workDateFrom = DateFormat('dd/MM/yyyy').parse(value);
      if (workDateFrom.isAfter(worksDateTimeTo!)) {
        return 'Date from can\'t be after date to';
      }
    } catch (e) {
      return 'Invalid date format';
    }
    return null;
  }

  String? workDateToValidator(String? value) {
    if (value == null || value.isEmpty) {
      return '';
    }
    if (worksDateTimeFrom == null) {
      return null;
    }
    try {
      final DateTime workDateTo = DateFormat('dd/MM/yyyy').parse(value);
      if (workDateTo.isBefore(worksDateTimeFrom!)) {
        return 'Date to can\'t be before date from';
      }
    } catch (e) {
      return 'Invalid date format';
    }
    return null;
  }
}

String? imagesValidator(List<XFile> images) {
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

String? noEmptyValidator(String? value) {
  if (value == null || value.isEmpty) {
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
