import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/database/entities/voting_form_field.dart';
import 'package:swift_contest/model/database/types/voting_form_field_scope.dart';
import 'package:swift_contest/model/database/types/voting_form_field_type.dart';
import 'package:swift_contest/utils/functions/gen_uuid.dart';
import 'package:swift_contest/utils/validators/validators.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_voting_form_edit_page_bloc/organizer_voting_form_edit_page_bloc.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

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
  final List<VotingFormField> updatedHeaderFields = [];
  final List<VotingFormField> updatedParticipantFields = [];
  final List<VotingFormField> updatedFooterFields = [];
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final nameFocusNode = FocusNode();
  final descriptionFocusNode = FocusNode();

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
                                      headerFormFields: updatedHeaderFields,
                                      participantFormFields: updatedParticipantFields,
                                      footerFormFields: updatedFooterFields,
                                      name: nameController.text,
                                      description: descriptionController.text));
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
                  if (!state.isInitialized) {
                    if (state.status.isFailure) {
                      return Center(
                        child: FilledButton(
                          onPressed: () async {
                            context
                                .read<OrganizerVotingFormEditPageBloc>()
                                .add(OrganizerVotingFormEditPageFetch(votingFormId: votingFormId));
                          },
                          child: Text('Retry'),
                        ),
                      );
                    }
                    return VoidWidget();
                  }

                  if (!isPageInitialized) {
                    final fields = state.votingFormBundle!.votingFormFields;
                    updatedHeaderFields.addAll(fields.where((e) => e.scope.isHeader).toList());
                    updatedParticipantFields
                        .addAll(fields.where((e) => e.scope.isParticipant).toList());
                    updatedFooterFields.addAll(fields.where((e) => e.scope.isFooter).toList());
                    nameController.text = state.votingFormBundle!.votingForm.name;
                    descriptionController.text = state.votingFormBundle!.votingForm.description;
                    isPageInitialized = true;
                  }
                  return DefaultTabController(
                    length: 4,
                    child: Column(
                      children: [
                        TabBar(
                          isScrollable: true,
                          tabAlignment: TabAlignment.center,
                          tabs: [
                            Tab(text: 'Info'),
                            Tab(text: 'Header'),
                            Tab(text: 'Participant'),
                            Tab(text: 'Footer'),
                          ],
                        ),
                        SizedBox(height: 16),
                        Expanded(
                          child: TabBarView(
                            children: [
                              //* Info
                              ListView(
                                padding: EdgeInsets.only(top: 8),
                                children: [
                                  CustomTextFormField(
                                    borderType: InputBorderType.outlined,
                                    label: 'Name',
                                    controller: nameController,
                                    focusNode: nameFocusNode,
                                    onChanged: (_) => setState(() => isEdited = true),
                                  ),
                                  CustomTextFormField(
                                    borderType: InputBorderType.outlined,
                                    minLines: 2,
                                    maxLines: 5,
                                    label: 'Description',
                                    controller: descriptionController,
                                    focusNode: descriptionFocusNode,
                                    onChanged: (_) => setState(() => isEdited = true),
                                  ),
                                ],
                              ),
                              //* Header form
                              Scaffold(
                                body: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ReorderableListView.builder(
                                      shrinkWrap: true,
                                      onReorder: (oldIndex, newIndex) {
                                        setState(() {
                                          if (newIndex > oldIndex) {
                                            newIndex -= 1;
                                          }
                                          final VotingFormField field =
                                          updatedHeaderFields.removeAt(oldIndex);
                                          updatedHeaderFields.insert(newIndex, field);
                                          isEdited = true;
                                        });
                                      },
                                      itemCount: updatedHeaderFields.length,
                                      itemBuilder: (context, index) {
                                        final field = updatedHeaderFields[index];
                                        return Card(
                                          key: ValueKey(field.id),
                                          elevation: 0,
                                          child: ListTile(
                                            trailing: IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  updatedHeaderFields.remove(field);
                                                  isEdited = true;
                                                });
                                              },
                                              icon: Icon(Icons.remove),
                                            ),
                                            leading: Icon((field.type.isTextual)
                                                ? Icons.text_fields
                                                : Icons.horizontal_distribute),
                                            title: (field.isRequired)
                                                ? Text('${field.question} *')
                                                : Text(field.question),
                                            subtitle: (field.type.isSlider)
                                                ? Text(
                                                '${field.sliderMinValue!} - ${field.sliderMaxValue!}')
                                                : null,
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(height: 100),
                                  ],
                                ),
                                floatingActionButton: Card(
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                  child: PopupMenuButton<VotingFormFieldType>(
                                    iconColor: Theme.of(context).colorScheme.onPrimaryContainer,
                                    surfaceTintColor:
                                    Theme.of(context).colorScheme.primaryContainer,
                                    onSelected: (value) async {
                                      switch (value) {
                                        case VotingFormFieldType.textual:
                                          final VotingFormField? newField =
                                          await _showAddTextualFieldDialog(
                                              context: context,
                                              scope: VotingFormFieldScope.header);
                                          if (newField != null) {
                                            setState(() {
                                              isEdited = true;
                                              updatedHeaderFields.add(newField);
                                            });
                                          }
                                        case VotingFormFieldType.slider:
                                          final VotingFormField? newField =
                                          await _showAddSliderFieldDialog(
                                              context: context,
                                              scope: VotingFormFieldScope.header);
                                          if (newField != null) {
                                            setState(() {
                                              isEdited = true;
                                              updatedHeaderFields.add(newField);
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
                                          value: VotingFormFieldType.slider,
                                          child: ListTile(
                                            leading: Icon(Icons.horizontal_distribute),
                                            title: Text('Slider'),
                                          ),
                                        ),
                                      ];
                                    },
                                    icon: Icon(Icons.add),
                                  ),
                                ),
                              ),
                              //* Participant form
                              Scaffold(
                                body: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ReorderableListView.builder(
                                      shrinkWrap: true,
                                      onReorder: (oldIndex, newIndex) {
                                        setState(() {
                                          if (newIndex > oldIndex) {
                                            newIndex -= 1;
                                          }
                                          final VotingFormField field =
                                          updatedParticipantFields.removeAt(oldIndex);
                                          updatedParticipantFields.insert(newIndex, field);
                                          isEdited = true;
                                        });
                                      },
                                      itemCount: updatedParticipantFields.length,
                                      itemBuilder: (context, index) {
                                        final field = updatedParticipantFields[index];
                                        return Card(
                                          key: ValueKey(field.id),
                                          elevation: 0,
                                          child: ListTile(
                                            trailing: IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  updatedParticipantFields.remove(field);
                                                  isEdited = true;
                                                });
                                              },
                                              icon: Icon(Icons.remove),
                                            ),
                                            leading: Icon((field.type.isTextual)
                                                ? Icons.text_fields
                                                : Icons.horizontal_distribute),
                                            title: (field.isRequired)
                                                ? Text('${field.question} *')
                                                : Text(field.question),
                                            subtitle: (field.type.isSlider)
                                                ? Text(
                                                '${field.sliderMinValue!} - ${field.sliderMaxValue!}')
                                                : null,
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(height: 100),
                                  ],
                                ),
                                floatingActionButton: Card(
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                  child: PopupMenuButton<VotingFormFieldType>(
                                    iconColor: Theme.of(context).colorScheme.onPrimaryContainer,
                                    surfaceTintColor:
                                    Theme.of(context).colorScheme.primaryContainer,
                                    onSelected: (value) async {
                                      switch (value) {
                                        case VotingFormFieldType.textual:
                                          final VotingFormField? newField =
                                          await _showAddTextualFieldDialog(
                                              context: context,
                                              scope: VotingFormFieldScope.participant);
                                          if (newField != null) {
                                            setState(() {
                                              isEdited = true;
                                              updatedParticipantFields.add(newField);
                                            });
                                          }
                                        case VotingFormFieldType.slider:
                                          final VotingFormField? newField =
                                          await _showAddSliderFieldDialog(
                                              context: context,
                                              scope: VotingFormFieldScope.participant);
                                          if (newField != null) {
                                            setState(() {
                                              isEdited = true;
                                              updatedParticipantFields.add(newField);
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
                                          value: VotingFormFieldType.slider,
                                          child: ListTile(
                                            leading: Icon(Icons.horizontal_distribute),
                                            title: Text('Slider'),
                                          ),
                                        ),
                                      ];
                                    },
                                    icon: Icon(Icons.add),
                                  ),
                                ),
                              ),
                              //* Footer form
                              Scaffold(
                                body: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ReorderableListView.builder(
                                      shrinkWrap: true,
                                      onReorder: (oldIndex, newIndex) {
                                        setState(() {
                                          if (newIndex > oldIndex) {
                                            newIndex -= 1;
                                          }
                                          final VotingFormField field =
                                          updatedFooterFields.removeAt(oldIndex);
                                          updatedFooterFields.insert(newIndex, field);
                                          isEdited = true;
                                        });
                                      },
                                      itemCount: updatedFooterFields.length,
                                      itemBuilder: (context, index) {
                                        final field = updatedFooterFields[index];
                                        return Card(
                                          key: ValueKey(field.id),
                                          elevation: 0,
                                          child: ListTile(
                                            trailing: IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  updatedFooterFields.remove(field);
                                                  isEdited = true;
                                                });
                                              },
                                              icon: Icon(Icons.remove),
                                            ),
                                            leading: Icon((field.type.isTextual)
                                                ? Icons.text_fields
                                                : Icons.horizontal_distribute),
                                            title: (field.isRequired)
                                                ? Text('${field.question} *')
                                                : Text(field.question),
                                            subtitle: (field.type.isSlider)
                                                ? Text(
                                                '${field.sliderMinValue!} - ${field.sliderMaxValue!}')
                                                : null,
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(height: 100),
                                  ],
                                ),
                                floatingActionButton: Card(
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                  child: PopupMenuButton<VotingFormFieldType>(
                                    iconColor: Theme.of(context).colorScheme.onPrimaryContainer,
                                    surfaceTintColor:
                                    Theme.of(context).colorScheme.primaryContainer,
                                    onSelected: (value) async {
                                      switch (value) {
                                        case VotingFormFieldType.textual:
                                          final VotingFormField? newField =
                                          await _showAddTextualFieldDialog(
                                              context: context,
                                              scope: VotingFormFieldScope.footer);
                                          if (newField != null) {
                                            setState(() {
                                              isEdited = true;
                                              updatedFooterFields.add(newField);
                                            });
                                          }
                                        case VotingFormFieldType.slider:
                                          final VotingFormField? newField =
                                          await _showAddSliderFieldDialog(
                                              context: context,
                                              scope: VotingFormFieldScope.footer);
                                          if (newField != null) {
                                            setState(() {
                                              isEdited = true;
                                              updatedFooterFields.add(newField);
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
                                          value: VotingFormFieldType.slider,
                                          child: ListTile(
                                            leading: Icon(Icons.horizontal_distribute),
                                            title: Text('Slider'),
                                          ),
                                        ),
                                      ];
                                    },
                                    icon: Icon(Icons.add),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

Future<VotingFormField?> _showAddTextualFieldDialog({
  required BuildContext context,
  required VotingFormFieldScope scope,
}) async {
  final formKey = GlobalKey<FormState>();
  final questionController = TextEditingController();
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
                    controller: questionController,
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
                    question: questionController.text.trim(),
                    type: VotingFormFieldType.textual,
                    isRequired: isRequired,
                    sliderMinValue: null,
                    sliderMaxValue: null,
                    scope: scope,
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

Future<VotingFormField?> _showAddSliderFieldDialog({
  required BuildContext context,
  required VotingFormFieldScope scope,
}) async {
  final formKey = GlobalKey<FormState>();
  final questionController = TextEditingController();
  final questionFocusNode = FocusNode();
  int sliderMinValue = 0;
  int sliderMaxValue = 10;
  bool isRequired = true;

  return await showDialog<VotingFormField?>(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text('Add slider'),
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
                    controller: questionController,
                    focusNode: questionFocusNode,
                    validator: noEmptyValidator,
                    label: 'Question',
                  ),
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      label: Text('Min value'),
                    ),
                    onChanged: (value) {
                      setState(() => sliderMinValue = value!);
                    },
                    value: sliderMinValue,
                    items: [
                      for (var i = 0; i < sliderMaxValue; i++)
                        DropdownMenuItem(
                          value: i,
                          child: Text(i.toString()),
                        ),
                    ],
                  ),
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      label: Text('Max value'),
                    ),
                    onChanged: (value) {
                      setState(() => sliderMaxValue = value!);
                    },
                    value: sliderMaxValue,
                    items: [
                      for (var i = sliderMinValue + 1; i <= 10; i++)
                        DropdownMenuItem(
                          value: i,
                          child: Text(i.toString()),
                        ),
                    ],
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
                    question: questionController.text.trim(),
                    type: VotingFormFieldType.slider,
                    sliderMinValue: sliderMinValue,
                    sliderMaxValue: sliderMaxValue,
                    isRequired: isRequired,
                    scope: scope,
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

// String? _minValueValidator(String? value, String? maxValue) {
//   final val = value?.trim();
//   final maxVal = maxValue?.trim();
//
//   if (val == null || val.isEmpty) {
//     return 'Required';
//   }
//
//   // Accetta solo numeri positivi con fino a 2 decimali
//   final decimalRegex = RegExp(r'^\d+(\.\d{1,2})?$');
//   if (!decimalRegex.hasMatch(val)) {
//     return 'Invalid format, only numbers with up to 2 decimal places';
//   }
//
//   if (maxVal == null || maxVal.isEmpty) {
//     return null;
//   }
//
//   if (!decimalRegex.hasMatch(maxVal)) {
//     // se il max non è valido, saltiamo il confronto
//     return null;
//   }
//
//   final valDouble = double.parse(val);
//   final maxValDouble = double.parse(maxVal);
//
//   if (valDouble >= maxValDouble) {
//     return 'Must be less than max value';
//   }
//
//   return null;
// }
//
// String? _maxValueValidator(String? value, String? minValue) {
//   final val = value?.trim();
//   final minVal = minValue?.trim();
//
//   if (val == null || val.isEmpty) {
//     return '';
//   }
//
//   final decimalRegex = RegExp(r'^\d+(\.\d{1,2})?$');
//   if (!decimalRegex.hasMatch(val)) {
//     return 'Invalid format, only numbers with up to 2 decimal places';
//   }
//
//   if (minVal == null || minVal.isEmpty) {
//     return null;
//   }
//
//   if (!decimalRegex.hasMatch(minVal)) {
//     return null;
//   }
//
//   final valDouble = double.parse(val);
//   final minValDouble = double.parse(minVal);
//
//   if (valDouble <= minValDouble) {
//     return 'Must be greater than min value';
//   }
//
//   return null;
// }
