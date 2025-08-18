import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pinput/pinput.dart';
import 'package:swift_contest/model/database/entities/place.dart';
import 'package:swift_contest/model/database/entities/profile.dart';
import 'package:swift_contest/utils/router/app_router.gr.dart';
import 'package:swift_contest/utils/validators/validators.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/date_time_picker_form_field.dart';
import 'package:swift_contest/view/widgets/images_picker_form_field.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/place_picker_form_field.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_contest_edit_page_bloc/organizer_contest_edit_page_bloc.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

@RoutePage()
class OrganizerContestEditPage extends StatefulWidget implements AutoRouteWrapper {
  final String contestId;

  const OrganizerContestEditPage({
    @PathParam('contestId') required this.contestId,
    super.key,
  });

  @override
  State<OrganizerContestEditPage> createState() => _OrganizerContestEditPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<OrganizerContestEditPageBloc>(
      create: (context) => OrganizerContestEditPageBloc(
        organizerRepository: context.read(),
        storageRepository: context.read(),
      ),
      child: this,
    );
  }
}

class _OrganizerContestEditPageState extends State<OrganizerContestEditPage> {
  late final String contestId;
  late Profile profile;
  final firstFormKey = GlobalKey<FormState>();
  final secondFormKey = GlobalKey<FormState>();
  final thirdFormKey = GlobalKey<FormState>();

  bool isPageInitialized = false;

  List<GlobalKey<FormState>> get formKeys => [firstFormKey, secondFormKey, thirdFormKey];
  int currentStep = 0;
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateTimeController = TextEditingController();
  DateTime? dateTime;
  final placeController = TextEditingController();
  Place? place;
  final worksSubmissionStartController = TextEditingController();
  DateTime? worksSubmissionStart;
  final worksSubmissionEndController = TextEditingController();
  DateTime? worksSubmissionEnd;
  late List<XFile> images;
  final nameFocusNode = FocusNode();
  final descriptionFocusNode = FocusNode();
  final dateTimeFocusNode = FocusNode();
  final worksSubmissionStartFocusNode = FocusNode();
  final worksSubmissionEndFocusNode = FocusNode();
  final placeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    contestId = widget.contestId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    profile = context.read<AuthBloc>().state.profile!;
    context
        .read<OrganizerContestEditPageBloc>()
        .add(OrganizerContestEditPageFetch(contestId: contestId));
  }

  @override
  void dispose() {
    context.hideLoader();
    nameController.dispose();
    descriptionController.dispose();
    dateTimeController.dispose();
    placeController.dispose();
    worksSubmissionStartController.dispose();
    worksSubmissionEndController.dispose();
    nameFocusNode.dispose();
    descriptionFocusNode.dispose();
    dateTimeFocusNode.dispose();
    worksSubmissionStartFocusNode.dispose();
    worksSubmissionEndFocusNode.dispose();
    placeFocusNode.dispose();
    for (var formKey in formKeys) {
      formKey.currentState?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrganizerContestEditPageBloc, OrganizerContestEditPageState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
        if (state.status.isLoading) {
          context.showLoader();
        } else {
          context.hideLoader();
        }
        if (state.status.isSuccess && state.sourceEvent is OrganizerContestEditPageEditContest) {
          showSnackBar(context: context, text: 'Contest updated successfully');
          context.router.pop(true);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: CustomAppBar(title: 'Edit contest'),
          body: Builder(
            builder: (context) {
              if (!state.isInitialized) {
                if (state.status.isFailure) {
                  return Center(
                    child: FilledButton(
                      onPressed: () async => context
                          .read<OrganizerContestEditPageBloc>()
                          .add(OrganizerContestEditPageFetch(contestId: contestId)),
                      child: Text('Retry'),
                    ),
                  );
                }
                return SizedBox();
              }
              if (!isPageInitialized) {
                final contestDetailsBundle = state.contestDetailsBundle!;
                nameController.setText(contestDetailsBundle.contestBundle.contest.name);
                descriptionController
                    .setText(contestDetailsBundle.contestBundle.contest.description);
                dateTime = contestDetailsBundle.contestBundle.contest.dateTime;
                dateTimeController.setText(DateFormat('dd/MM/yyyy HH:mm').format(dateTime!));
                place = contestDetailsBundle.contestBundle.place;
                placeController.setText(place!.address);
                worksSubmissionStart =
                    contestDetailsBundle.contestBundle.contest.worksSubmissionStart;
                worksSubmissionEnd = contestDetailsBundle.contestBundle.contest.worksSubmissionEnd;
                worksSubmissionStartController
                    .setText(DateFormat('dd/MM/yyyy HH:mm').format(worksSubmissionStart!));
                worksSubmissionEndController
                    .setText(DateFormat('dd/MM/yyyy HH:mm').format(worksSubmissionEnd!));
                images = state.images!;
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
                      context.read<OrganizerContestEditPageBloc>().add(
                            OrganizerContestEditPageEditContest(
                              contest: state.contestDetailsBundle!.contestBundle.contest.copyWith(
                                name: nameController.text.trim(),
                                description: descriptionController.text.trim(),
                                dateTime: dateTime,
                                worksSubmissionStart: worksSubmissionStart,
                                worksSubmissionEnd: worksSubmissionEnd,
                              ),
                              place: place!,
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
                DateTimePickerFormField(
                  controller: dateTimeController,
                  focusNode: dateTimeFocusNode,
                  initialDate: dateTime,
                  label: 'Date',
                  validator: noEmptyValidator,
                  onSelected: (value) {
                    setState(() {
                      dateTime = value;
                    });
                  },
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                PlacePickerFormField(
                  controller: placeController,
                  focusNode: placeFocusNode,
                  label: 'Location',
                  validator: noEmptyValidator,
                  prefixIcon: Icon(Icons.place_outlined),
                  suffixIcon: TextButton(
                    onPressed: () async {
                      placeFocusNode.requestFocus();
                      final Place? placeRes = await context.router.push(PlaceSearchRoute());
                      if (placeRes != null) {
                        placeController.text = placeRes.address;
                        place = place?.copyWith(
                            address: placeRes.address, lat: placeRes.lat, lon: placeRes.lon);
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
            child: ImagesPickerFormField(
              initialValue: images,
              maxImages: 5,
              validator: atLeastOneImageValidator,
              onSaved: (value) => images = value ?? [],
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
                DateTimePickerFormField(
                  controller: worksSubmissionStartController,
                  focusNode: worksSubmissionStartFocusNode,
                  initialDate: worksSubmissionStart,
                  label: 'Start date',
                  validator: (value) =>
                      worksSubmissionStartValidator(value, dateTime!, worksSubmissionEnd),
                  onSelected: (workDateStartValue) {
                    worksSubmissionStart = workDateStartValue;
                  },
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                DateTimePickerFormField(
                  controller: worksSubmissionEndController,
                  focusNode: worksSubmissionEndFocusNode,
                  initialDate: worksSubmissionEnd,
                  label: 'End date',
                  validator: (value) =>
                      worksSubmissionEndValidator(value, dateTime!, worksSubmissionStart),
                  onSelected: (workDateEndValue) {
                    worksSubmissionEnd = workDateEndValue;
                  },
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
              ],
            ),
          ),
        ),
      ];
}
