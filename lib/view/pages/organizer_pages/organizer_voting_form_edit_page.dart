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
  final _infoFormKey = GlobalKey<FormState>();

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
                padding: const EdgeInsets.only(right: 12),
                child: (isEdited)
                    ? FilledButton(
                        onPressed: () {
                          // We must validate info tab before saving.
                          if (!(_infoFormKey.currentState?.validate() ?? true)) {
                            showSnackBar(
                                context: context,
                                text: "Errors in tab 'Info'");
                            return;
                          }
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('Save'),
                      )
                    : const VoidWidget(),
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
                          child: const Text('Retry'),
                        ),
                      );
                    }
                    return const VoidWidget();
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
                        const TabBar(
                          isScrollable: true,
                          tabAlignment: TabAlignment.center,
                          tabs: [
                            Tab(text: 'Info'),
                            Tab(text: 'Header'),
                            Tab(text: 'Participant'),
                            Tab(text: 'Footer'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _InfoTab(
                                formKey: _infoFormKey,
                                nameController: nameController,
                                descriptionController: descriptionController,
                                nameFocusNode: nameFocusNode,
                                descriptionFocusNode: descriptionFocusNode,
                                onChanged: _setEdited,
                              ),
                              _FieldsTab(
                                fields: updatedHeaderFields,
                                scope: VotingFormFieldScope.header,
                                onAddField: (field) => _addField(field, updatedHeaderFields),
                                onRemoveField: (field) => _removeField(field, updatedHeaderFields),
                                onReorder: (oldI, newI) =>
                                    _reorderFields(oldI, newI, updatedHeaderFields),
                              ),
                              _FieldsTab(
                                fields: updatedParticipantFields,
                                scope: VotingFormFieldScope.participant,
                                onAddField: (field) => _addField(field, updatedParticipantFields),
                                onRemoveField: (field) =>
                                    _removeField(field, updatedParticipantFields),
                                onReorder: (oldI, newI) =>
                                    _reorderFields(oldI, newI, updatedParticipantFields),
                              ),
                              _FieldsTab(
                                fields: updatedFooterFields,
                                scope: VotingFormFieldScope.footer,
                                onAddField: (field) => _addField(field, updatedFooterFields),
                                onRemoveField: (field) => _removeField(field, updatedFooterFields),
                                onReorder: (oldI, newI) =>
                                    _reorderFields(oldI, newI, updatedFooterFields),
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

  void _setEdited() {
    if (!isEdited) {
      setState(() {
        isEdited = true;
      });
    }
  }

  void _addField(VotingFormField field, List<VotingFormField> list) {
    setState(() {
      list.add(field);
      isEdited = true;
    });
  }

  void _removeField(VotingFormField field, List<VotingFormField> list) {
    setState(() {
      list.remove(field);
      isEdited = true;
    });
  }

  void _reorderFields(int oldIndex, int newIndex, List<VotingFormField> list) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = list.removeAt(oldIndex);
      list.insert(newIndex, item);
      isEdited = true;
    });
  }
}

Future<VotingFormField?> _showAddTextualFieldDialog({
  required BuildContext context,
  required VotingFormFieldScope scope,
}) async {
  final formKey = GlobalKey<FormState>();
  final questionController = TextEditingController();
  final questionFocusNode = FocusNode();
  bool isRequired = true;

  return await showDialog<VotingFormField?>(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: const Text('Add textual field'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Required'),
                  const SizedBox(height: 2),
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
                  const SizedBox(height: 4),
                  CustomTextFormField(
                    borderType: InputBorderType.underlined,
                    controller: questionController,
                    focusNode: questionFocusNode,
                    validator: questionValidator,
                    minLines: 1,
                    maxLines: 3,
                    label: 'Question',
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
              child: const Text('Cancel'),
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
              child: const Text('Add'),
            ),
          ],
        );
      });
    },
  );
}

/// A widget representing the 'Info' tab, which is kept alive.
class _InfoTab extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final FocusNode nameFocusNode;
  final FocusNode descriptionFocusNode;
  final VoidCallback onChanged;

  const _InfoTab({
    required this.formKey,
    required this.nameController,
    required this.descriptionController,
    required this.nameFocusNode,
    required this.descriptionFocusNode,
    required this.onChanged,
  });

  @override
  State<_InfoTab> createState() => _InfoTabState();
}

class _InfoTabState extends State<_InfoTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Form(
      key: widget.formKey,
      child: ListView(
        padding: const EdgeInsets.only(top: 8),
        children: [
          CustomTextFormField(
            borderType: InputBorderType.outlined,
            label: 'Name',
            controller: widget.nameController,
            focusNode: widget.nameFocusNode,
            validator: titleValidator,
            onChanged: (_) => widget.onChanged(),
          ),
          const SizedBox(height: 16),
          CustomTextFormField(
            borderType: InputBorderType.outlined,
            minLines: 1,
            maxLines: 5,
            label: 'Description',
            controller: widget.descriptionController,
            focusNode: widget.descriptionFocusNode,
            validator: descriptionValidator,
            onChanged: (_) => widget.onChanged(),
          ),
        ],
      ),
    );
  }
}

/// A generic widget for the 'Header', 'Participant', and 'Footer' tabs, kept alive.
class _FieldsTab extends StatefulWidget {
  final List<VotingFormField> fields;
  final VotingFormFieldScope scope;
  final ValueChanged<VotingFormField> onAddField;
  final ValueChanged<VotingFormField> onRemoveField;
  final void Function(int oldIndex, int newIndex) onReorder;

  const _FieldsTab({
    required this.fields,
    required this.scope,
    required this.onAddField,
    required this.onRemoveField,
    required this.onReorder,
  });

  @override
  State<_FieldsTab> createState() => _FieldsTabState();
}

class _FieldsTabState extends State<_FieldsTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      body: widget.fields.isEmpty
          ? const Center(child: Text('No field added'))
          : ReorderableListView.builder(
              padding: const EdgeInsets.only(bottom: 100), // To avoid FAB overlap
              itemCount: widget.fields.length,
              onReorder: widget.onReorder,
              itemBuilder: (context, index) {
                final field = widget.fields[index];
                return Card(
                  key: ValueKey(field.id),
                  elevation: 0,
                  child: ListTile(
                    trailing: IconButton(
                      onPressed: () => widget.onRemoveField(field),
                      icon: const Icon(Icons.remove),
                    ),
                    leading: Icon(
                        field.type.isTextual ? Icons.text_fields : Icons.horizontal_distribute),
                    title: Text(field.isRequired ? '${field.question} *' : field.question),
                    subtitle: field.type.isSlider
                        ? Text('${field.sliderMinValue!} - ${field.sliderMaxValue!}')
                        : null,
                  ),
                );
              },
            ),
      floatingActionButton: Card(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: PopupMenuButton<VotingFormFieldType>(
          iconColor: Theme.of(context).colorScheme.onPrimaryContainer,
          surfaceTintColor: Theme.of(context).colorScheme.primaryContainer,
          onSelected: (value) async {
            VotingFormField? newField;
            if (value == VotingFormFieldType.textual) {
              newField = await _showAddTextualFieldDialog(context: context, scope: widget.scope);
            } else if (value == VotingFormFieldType.slider) {
              newField = await _showAddSliderFieldDialog(context: context, scope: widget.scope);
            }
            if (newField != null && mounted) {
              widget.onAddField(newField);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: VotingFormFieldType.textual,
              child: ListTile(leading: Icon(Icons.text_fields), title: Text('Textual')),
            ),
            const PopupMenuItem(
              value: VotingFormFieldType.slider,
              child:
                  ListTile(leading: Icon(Icons.horizontal_distribute), title: Text('Slider')),
            ),
          ],
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }
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
          title: const Text('Add slider'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Required'),
                  const SizedBox(height: 2),
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
                    validator: questionValidator,
                    label: 'Question',
                  ),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      label: Text('Min value'),
                    ),
                    onChanged: (value) {
                      setState(() => sliderMinValue = value!);
                    },
                    initialValue: sliderMinValue,
                    items: [
                      for (var i = 0; i < sliderMaxValue; i++)
                        DropdownMenuItem(
                          value: i,
                          child: Text(i.toString()),
                        ),
                    ],
                  ),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      label: Text('Max value'),
                    ),
                    onChanged: (value) {
                      setState(() => sliderMaxValue = value!);
                    },
                    initialValue: sliderMaxValue,
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
              child: const Text('Cancel'),
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
              child: const Text('Add'),
            ),
          ],
        );
      });
    },
  );
}
