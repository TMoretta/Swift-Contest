import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';
import 'package:swift_contest/model/db/entities/voting_form_field.dart';
import 'package:swift_contest/model/db/types/voting_form_field_type.dart';
import 'package:swift_contest/utils/functions/gen_uuid.dart';
import 'package:swift_contest/utils/functions/pretty_double.dart';
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
  final List<VotingFormField> updatedFields = [];
  final headerController = TextEditingController();
  final footerController = TextEditingController();
  final headerFocusNode = FocusNode();
  final footerFocusNode = FocusNode();

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
                                      votingFormId: votingFormId,
                                      votingFormFields: updatedFields,
                                      header: headerController.text,
                                      footer: footerController.text));
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
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
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
                        updatedFields.addAll(state.votingFormBundle!.votingFormFields);
                        headerController.text = state.votingFormBundle!.votingForm.header ?? '';
                        footerController.text = state.votingFormBundle!.votingForm.footer ?? '';
                        isPageInitialized = true;
                      }
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomTextFormField(
                            borderType: InputBorderType.outlined,
                            minLines: 2,
                            maxLines: 6,
                            label: 'Header',
                            controller: headerController,
                            focusNode: headerFocusNode,
                            onChanged: (_) => setState(() => isEdited = true),
                          ),
                          CustomTextFormField(
                            borderType: InputBorderType.outlined,
                            minLines: 2,
                            maxLines: 6,
                            label: 'Footer',
                            controller: footerController,
                            focusNode: footerFocusNode,
                            onChanged: (_) => setState(() => isEdited = true),
                          ),
                          (updatedFields.isEmpty)
                              ? Center(child: Text('No field added yet'))
                              : Expanded(
                                  child: ReorderableListView.builder(
                                    itemCount: updatedFields.length,
                                    onReorder: (oldIndex, newIndex) {
                                      setState(() {
                                        if (oldIndex < newIndex) {
                                          newIndex -= 1;
                                        }
                                        final VotingFormField field =
                                            updatedFields.removeAt(oldIndex);
                                        updatedFields.insert(newIndex, field);
                                        isEdited = true;
                                      });
                                    },
                                    itemBuilder: (context, index) {
                                      final field = updatedFields[index];
                                      return Card(
                                        key: ValueKey(field.id),
                                        elevation: 0,
                                        child: ListTile(
                                          trailing: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                updatedFields.remove(field);
                                                isEdited = true;
                                              });
                                            },
                                            icon: Icon(Icons.remove),
                                          ),
                                          leading: Icon((field.type.isTextual)
                                              ? Icons.text_fields
                                              : Icons.numbers),
                                          title: (field.isRequired)
                                              ? Text('${field.name} *')
                                              : Text(field.name),
                                          subtitle: (field.type.isNumeric)
                                              ? Text(
                                                  '${prettyDouble(field.minValue!)} - ${prettyDouble(field.maxValue!)}')
                                              : null,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                          SizedBox(height: 72),
                        ],
                      );
                    // child: ListView.builder(
                    //   itemCount: updatedFields.length,
                    //   itemBuilder: (context, index) {
                    //     final field = updatedFields[index];
                    //     return Column(
                    //       mainAxisSize: MainAxisSize.min,
                    //       children: [
                    //         Card(
                    //           elevation: 0,
                    //           child: ListTile(
                    //             leading: Icon((field.type.isTextual) ?Icons.text_fields : Icons.numbers),
                    //             title: (field.isRequired) ? Text('${field.name} *') : Text(field.name),
                    //             subtitle: (field.type.isNumeric)
                    //                 ? Text('${prettyDouble(field.minValue!)} - ${prettyDouble(field.maxValue!)}')
                    //                 : null,
                    //             trailing: IconButton(
                    //               onPressed: () {
                    //                 setState(() {
                    //                   isEdited = true;
                    //                   updatedFields.remove(field);
                    //                 });
                    //               },
                    //               icon: Icon(Icons.remove),
                    //             ),
                    //           ),
                    //         ),
                    //         if (index == updatedFields.length - 1) SizedBox(height: 72),
                    //       ],
                    //     );
                    //   },
                    // ),
                  }
                },
              ),
            ),
          ),
          floatingActionButton: Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: PopupMenuButton<VotingFormFieldType>(
              iconColor: Theme.of(context).colorScheme.onPrimaryContainer,
              surfaceTintColor: Theme.of(context).colorScheme.primaryContainer,
              onSelected: (value) async {
                switch (value) {
                  case VotingFormFieldType.textual:
                    final VotingFormField? newField = await _showAddTextualFieldDialog(
                        context: context, votingFormId: votingFormId);
                    if (newField != null) {
                      setState(() {
                        isEdited = true;
                        updatedFields.add(newField);
                      });
                    }
                  case VotingFormFieldType.numeric:
                    final VotingFormField? newField = await _showAddNumericFieldDialog(
                        context: context,
                        votingFormId: votingFormId,
                        orderIndex: updatedFields.length);
                    if (newField != null) {
                      setState(() {
                        isEdited = true;
                        updatedFields.add(newField);
                      });
                    }
                }
              },
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    value: VotingFormFieldType.textual,
                    child: ListTile(
                      leading: Icon(Icons.text_fields),
                      title: Text('Textual'),
                    ),
                  ),
                  PopupMenuItem(
                    value: VotingFormFieldType.numeric,
                    child: ListTile(
                      leading: Icon(Icons.numbers),
                      title: Text('Numeric'),
                    ),
                  ),
                ];
              },
              icon: Icon(Icons.add),
            ),
          ),
          // floatingActionButton: FloatingActionButton(
          //   onPressed: () async {
          //     final VotingFormField? newField = await _showAddFieldDialog(
          //         context: context, votingFormId: votingFormId, orderIndex: updatedFields.length);
          //     if (newField != null) {
          //       setState(() {
          //         isEdited = true;
          //         updatedFields.add(newField);
          //       });
          //     }
          //   },
          //   elevation: 1,
          //   child: Icon(Icons.add),
          // ),
        );
      },
    );
  }
}

Future<VotingFormField?> _showAddTextualFieldDialog({
  required BuildContext context,
  required String votingFormId,
}) async {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final nameFocusNode = FocusNode();
  bool isRequired = true;

  return await showDialog<VotingFormField?>(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text('Add textual field'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Required'),
                  SizedBox(height: 2),
                  RadioMenuButton<bool>(
                    value: true,
                    groupValue: isRequired,
                    onChanged: (value) {
                      setState(() => isRequired = value!);
                    },
                    child: Text(
                      'True',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  RadioMenuButton<bool>(
                    value: false,
                    groupValue: isRequired,
                    onChanged: (value) {
                      setState(() => isRequired = value!);
                    },
                    child: Text(
                      'False',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  CustomTextFormField(
                    borderType: InputBorderType.underlined,
                    controller: nameController,
                    focusNode: nameFocusNode,
                    validator: noEmptyValidator,
                    label: 'Name',
                  ),
                ],
              ),
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
                  final newField = VotingFormField(
                    id: genUuid(),
                    createdAt: null,
                    votingFormId: null,
                    orderIndex: 0,
                    name: nameController.text.trim(),
                    type: VotingFormFieldType.textual,
                    minValue: null,
                    maxValue: null,
                    isRequired: isRequired,
                  );
                  context.router.pop(newField);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      });
    },
  );
}

Future<VotingFormField?> _showAddNumericFieldDialog({
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
  bool isRequired = true;

  return await showDialog<VotingFormField?>(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text('Add field'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Required'),
                  SizedBox(height: 2),
                  RadioMenuButton<bool>(
                    value: true,
                    groupValue: isRequired,
                    onChanged: (value) {
                      setState(() => isRequired = value!);
                    },
                    child: Text(
                      'True',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  RadioMenuButton<bool>(
                    value: false,
                    groupValue: isRequired,
                    onChanged: (value) {
                      setState(() => isRequired = value!);
                    },
                    child: Text(
                      'False',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
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
                  final newField = VotingFormField(
                    id: null,
                    createdAt: null,
                    votingFormId: null,
                    orderIndex: orderIndex,
                    name: nameController.text.trim(),
                    type: VotingFormFieldType.numeric,
                    minValue: minValueDouble,
                    maxValue: maxValueDouble,
                    isRequired: isRequired,
                  );
                  context.router.pop(newField);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      });
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
