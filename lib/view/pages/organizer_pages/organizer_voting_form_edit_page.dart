import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/utils/validators/validators.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_voting_form_edit_page_bloc/organizer_voting_form_edit_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class OrganizerVotingFormEditPage extends StatefulWidget {
  final String votingFormId;

  const OrganizerVotingFormEditPage({required this.votingFormId, super.key});

  @override
  State<OrganizerVotingFormEditPage> createState() => _OrganizerVotingFormEditPageState();
}

class _OrganizerVotingFormEditPageState extends State<OrganizerVotingFormEditPage> {
  late String votingFormId;
  bool isFieldsListInitialized = false;
  bool isEdited = false;
  final List<VotingFormFieldNullable> updatedFields = [];

  @override
  void initState() {
    super.initState();
    votingFormId = widget.votingFormId;
    context
        .read<OrganizerVotingFormEditPageBloc>()
        .add(OrganizerVotingFormEditPageGetVotingForm(votingFormId: votingFormId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrganizerVotingFormEditPageBloc, OrganizerVotingFormEditPageState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
        if (state.status.isSuccess &&
            state.sourceEvent is OrganizerVotingFormEditPageUpdateVotingForm) {
          context.pop(true);
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Voting Form',
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: BlocBuilder<OrganizerVotingFormEditPageBloc, OrganizerVotingFormEditPageState>(
                builder: (context, state) {
                  return (isEdited)
                      ? FilledButton(
                          onPressed: (!state.status.isLoading)
                              ? () {
                                  context.read<OrganizerVotingFormEditPageBloc>().add(
                                      OrganizerVotingFormEditPageUpdateVotingForm(
                                          votingFormId: votingFormId,
                                          votingFormFields: updatedFields));
                                }
                              : null,
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: Text('Save'),
                        )
                      : SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: BlocBuilder<OrganizerVotingFormEditPageBloc, OrganizerVotingFormEditPageState>(
            builder: (context, state) {
              switch (state.status) {
                case BlocStatus.initial:
                  return SizedBox.shrink();
                case BlocStatus.loading:
                  return Loader();
                case BlocStatus.failure:
                  if (state.sourceEvent is OrganizerVotingFormEditPageGetVotingForm) {
                    return RefreshIndicator.adaptive(
                      onRefresh: () async => context.read<OrganizerVotingFormEditPageBloc>().add(
                          OrganizerVotingFormEditPageGetVotingForm(votingFormId: votingFormId)),
                      child: ListView(),
                    );
                  } else {
                    continue successCase;
                  }
                successCase:
                case BlocStatus.success:
                  if (!isFieldsListInitialized) {
                    isFieldsListInitialized = true;
                    updatedFields.addAll(
                        state.votingFormBundle!.votingFormFields.map((e) => VotingFormFieldNullable(
                              name: e.name,
                              minValue: e.minValue,
                              maxValue: e.maxValue,
                              orderIndex: e.orderIndex,
                            )));
                  }
                  return (updatedFields.isEmpty)
                      ? Center(
                          child: Text(
                            'No field added yet',
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: ListView.builder(
                            itemCount: updatedFields.length,
                            itemBuilder: (context, index) {
                              final field = updatedFields[index];
                              return Card(
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
                              );
                            },
                          ),
                        );
              }
            },
          ),
        ),
        floatingActionButton:
            BlocBuilder<OrganizerVotingFormEditPageBloc, OrganizerVotingFormEditPageState>(
          builder: (context, state) {
            return FloatingActionButton(
              onPressed: (!state.status.isLoading)
                  ? () async {
                      final VotingFormFieldNullable? newField = await showAddFieldDialog(
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
                  : null,
              elevation: 1,
              child: Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }
}

Future<VotingFormFieldNullable?> showAddFieldDialog({
  required BuildContext context,
  required String votingFormId,
  required int orderIndex,
}) async {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final minValueController = TextEditingController();
  final maxValueController = TextEditingController();

  return await showDialog<VotingFormFieldNullable?>(
    context: context,
    builder: (context) {
      return Form(
        key: formKey,
        child: AlertDialog(
          title: Text('Add field'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextFormFieldUnderlined(
                  controller: nameController,
                  validator: noEmptyValidator,
                  label: 'Name',
                ),
                CustomTextFormFieldUnderlined(
                  controller: minValueController,
                  label: 'Min value',
                  keyboardType: TextInputType.number,
                  validator: (value) => _minValueValidator(value, maxValueController.text),
                ),
                CustomTextFormFieldUnderlined(
                  controller: maxValueController,
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
                context.pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    final minValueDouble = double.parse(minValueController.text.trim());
                    final maxValueDouble = double.parse(maxValueController.text.trim());
                    final newField = VotingFormFieldNullable(
                      orderIndex: orderIndex,
                      name: nameController.text.trim(),
                      minValue: minValueDouble,
                      maxValue: maxValueDouble,
                    );
                    context.pop(newField);
                  }
                },
                child: Text('Add')),
          ],
        ),
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
