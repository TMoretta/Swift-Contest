import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';
import 'package:swift_contest/utils/labels/labels.dart';
import 'package:swift_contest/utils/validators/validators.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/list_view_with_central_label.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_voting_form_edit_page_bloc/organizer_voting_form_edit_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

@RoutePage()
class OrganizerVotingFormEditPage extends StatefulWidget implements AutoRouteWrapper {
  final String votingFormId;

  const OrganizerVotingFormEditPage({
    @PathParam('votingFormId') required this.votingFormId,
    super.key,
  });

  @override
  State<OrganizerVotingFormEditPage> createState() => _OrganizerVotingFormEditPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<OrganizerVotingFormEditPageBloc>(
      create: (context) => OrganizerVotingFormEditPageBloc(
        organizerRepository: context.read(),
      ),
      child: this,
    );
  }
}

class _OrganizerVotingFormEditPageState extends State<OrganizerVotingFormEditPage> {
  late final String votingFormId;
  bool isPageInitialized = false;
  bool isEdited = false;
  final List<VotingFormFieldModel> updatedFields = [];

  @override
  void initState() {
    super.initState();
    votingFormId = widget.votingFormId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context
        .read<OrganizerVotingFormEditPageBloc>()
        .add(OrganizerVotingFormEditPageFetch(votingFormId: votingFormId));
  }

  @override
  void dispose() {
    context.hideLoader();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrganizerVotingFormEditPageBloc, OrganizerVotingFormEditPageState>(
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
            state.sourceEvent is OrganizerVotingFormEditPageUpdateVotingForm) {
          showSnackBar(context: context, text: 'Voting form updated successfully');
          context.router.pop(true);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: CustomAppBar(
            title: 'Voting Form',
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Builder(
                  builder: (context) {
                    return (isEdited)
                        ? FilledButton(
                            onPressed: () {
                              context.read<OrganizerVotingFormEditPageBloc>().add(
                                  OrganizerVotingFormEditPageUpdateVotingForm(
                                      votingFormId: votingFormId, votingFormFields: updatedFields));
                            },
                            style: FilledButton.styleFrom(
                              shape:
                                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: Text('Save'),
                          )
                        : VoidWidget();
                  },
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Builder(
                builder: (context) {
                  switch (state.status) {
                    case BlocStatus.initial:
                      return VoidWidget();
                    case BlocStatus.loading:
                      if (state.sourceEvent is OrganizerVotingFormEditPageFetch) {
                        return VoidWidget();
                      } else {
                        continue successCase;
                      }
                    case BlocStatus.failure:
                      if (state.sourceEvent is OrganizerVotingFormEditPageFetch) {
                        return RefreshIndicator.adaptive(
                          onRefresh: () async => context
                              .read<OrganizerVotingFormEditPageBloc>()
                              .add(OrganizerVotingFormEditPageFetch(votingFormId: votingFormId)),
                          child: ListViewWithCentralLabel(label: Labels.anErrorOccurred),
                        );
                      } else {
                        continue successCase;
                      }
                    successCase:
                    case BlocStatus.success:
                      if (!isPageInitialized) {
                        updatedFields.addAll(state.votingFormBundle!.votingFormFields
                            .map((e) => VotingFormFieldModel(
                                  name: e.name,
                                  minValue: e.minValue,
                                  maxValue: e.maxValue,
                                  orderIndex: e.orderIndex,
                                )));
                        isPageInitialized = true;
                      }
                      return (updatedFields.isEmpty)
                          ? ListViewWithCentralLabel(label: 'No field added yet')
                          : Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: ListView.builder(
                                itemCount: updatedFields.length,
                                itemBuilder: (context, index) {
                                  final field = updatedFields[index];
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Card(
                                        elevation: 0,
                                        child: ListTile(
                                          title: Text(field.name!),
                                          subtitle: Text('${field.minValue} - ${field.maxValue}'),
                                          trailing: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                isEdited = true;
                                                updatedFields.remove(field);
                                              });
                                            },
                                            icon: Icon(Icons.remove),
                                          ),
                                        ),
                                      ),
                                      if (index == updatedFields.length - 1) SizedBox(height: 72),
                                    ],
                                  );
                                },
                              ),
                            );
                  }
                },
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final VotingFormFieldModel? newField = await _showAddFieldDialog(
                  context: context, votingFormId: votingFormId, orderIndex: updatedFields.length);
              if (newField != null) {
                setState(() {
                  isEdited = true;
                  updatedFields.add(newField);
                });
              }
            },
            elevation: 1,
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }
}

Future<VotingFormFieldModel?> _showAddFieldDialog({
  required BuildContext context,
  required String votingFormId,
  required int orderIndex,
}) async {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final nameFocusNode = FocusNode();
  final minValueController = TextEditingController();
  final minValueFocusNode = FocusNode();
  final maxValueController = TextEditingController();
  final maxValueFocusNode = FocusNode();

  return await showDialog<VotingFormFieldModel?>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Add field'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextFormField(
                borderType: InputBorderType.underlined,
                controller: nameController,
                focusNode: nameFocusNode,
                validator: noEmptyValidator,
                label: 'Name',
              ),
              CustomTextFormField(
                borderType: InputBorderType.underlined,
                controller: minValueController,
                focusNode: minValueFocusNode,
                label: 'Min value',
                keyboardType: TextInputType.number,
                validator: (value) => _minValueValidator(value, maxValueController.text),
              ),
              CustomTextFormField(
                borderType: InputBorderType.underlined,
                controller: maxValueController,
                focusNode: maxValueFocusNode,
                label: 'Max value',
                keyboardType: TextInputType.number,
                validator: (value) => _maxValueValidator(value, minValueController.text),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.router.pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                final minValueDouble = double.parse(minValueController.text.trim());
                final maxValueDouble = double.parse(maxValueController.text.trim());
                final newField = VotingFormFieldModel(
                  orderIndex: orderIndex,
                  name: nameController.text.trim(),
                  minValue: minValueDouble,
                  maxValue: maxValueDouble,
                );
                context.router.pop(newField);
              }
            },
            child: Text('Add'),
          ),
        ],
      );
    },
  );
}

String? _minValueValidator(String? value, String? maxValue) {
  final val = value?.trim();
  final maxVal = maxValue?.trim();

  if (val == null || val.isEmpty) {
    return '';
  }

  // Accetta solo numeri positivi con fino a 2 decimali
  final decimalRegex = RegExp(r'^\d+(\.\d{1,2})?$');
  if (!decimalRegex.hasMatch(val)) {
    return 'Invalid format, only numbers with up to 2 decimal places';
  }

  if (maxVal == null || maxVal.isEmpty) {
    return null;
  }

  if (!decimalRegex.hasMatch(maxVal)) {
    // se il max non è valido, saltiamo il confronto
    return null;
  }

  final valDouble = double.parse(val);
  final maxValDouble = double.parse(maxVal);

  if (valDouble >= maxValDouble) {
    return 'Must be less than max value';
  }

  return null;
}

String? _maxValueValidator(String? value, String? minValue) {
  final val = value?.trim();
  final minVal = minValue?.trim();

  if (val == null || val.isEmpty) {
    return '';
  }

  final decimalRegex = RegExp(r'^\d+(\.\d{1,2})?$');
  if (!decimalRegex.hasMatch(val)) {
    return 'Invalid format, only numbers with up to 2 decimal places';
  }

  if (minVal == null || minVal.isEmpty) {
    return null;
  }

  if (!decimalRegex.hasMatch(minVal)) {
    return null;
  }

  final valDouble = double.parse(val);
  final minValDouble = double.parse(minVal);

  if (valDouble <= minValDouble) {
    return 'Must be greater than min value';
  }

  return null;
}
