import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/bundles/voting_form_bundle.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';
import 'package:swift_contest/utils/functions/gen_uuid.dart';
import 'package:swift_contest/utils/functions/now.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/utils/validators/validators.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_voting_form_edit_page_bloc/organizer_voting_form_edit_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class OrganizerVotingFormEditPage extends StatefulWidget {
  final VotingFormBundle votingFormBundle;

  const OrganizerVotingFormEditPage({required this.votingFormBundle, super.key});

  @override
  State<OrganizerVotingFormEditPage> createState() => _OrganizerVotingFormEditPageState();
}

class _OrganizerVotingFormEditPageState extends State<OrganizerVotingFormEditPage> {
  bool isEdited = false;
  final List<VotingFormField> updatedFields = [];
  late VotingFormBundle votingFormBundle;

  @override
  void initState() {
    super.initState();
    votingFormBundle = widget.votingFormBundle;
    updatedFields.addAll(votingFormBundle.votingFormFields);
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
                                          votingFormId: votingFormBundle.votingForm.id,
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
                case BlocStatus.loading:
                  return Loader();
                case BlocStatus.initial:
                case BlocStatus.failure:
                case BlocStatus.success:
                  return (updatedFields.isEmpty)
                      ? Center(
                          child: Text(
                            'No field added yet',
                            style: Theme.of(context).textTheme.bodyLarge,
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
                                  title: Text(field.name),
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
                      final VotingFormField? newField = await showAddFieldDialog(
                          context: context,
                          votingFormId: votingFormBundle.votingForm.id,
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

Future<VotingFormField?> showAddFieldDialog({
  required BuildContext context,
  required String votingFormId,
  required int orderIndex,
}) async {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final minValueController = TextEditingController();
  final maxValueController = TextEditingController();

  return await showDialog<VotingFormField?>(
    context: context,
    useRootNavigator: false,
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
                        final minValueInt = int.parse(minValueController.text.trim());
                        final maxValueInt = int.parse(maxValueController.text.trim());
                        // if(minValueInt==null || maxValueInt == null) {
                        //   showSnackBar(context: context, text: 'Invalid format on values range');
                        //   return;
                        // }
                        // if(maxValueInt<minValueInt) {
                        //   showSnackBar(context: context, text: 'Min value must be less than max value');
                        //   return;
                        // }
                        final newField = VotingFormField(
                          id: genUuid(),
                          createdAt: now(),
                          votingFormId: votingFormId,
                          orderIndex: orderIndex,
                          name: nameController.text.trim(),
                          minValue: minValueInt,
                          maxValue: maxValueInt,
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

  if(val == null || val.isEmpty) {
    return '';
  }

  if(!RegExp(r'^\d+$').hasMatch(val)) {
    return 'Invalid number, only integers';
  }

  if(maxVal == null || maxVal.isEmpty) {
    return null;
  }

  if(!RegExp(r'^\d+$').hasMatch(maxVal)) {
    return null;
  }

  final valInt = int.parse(val);
  final maxValInt = int.parse(maxVal);

  if(valInt>=maxValInt) {
    return 'Must be less than max value';
  }

  return null;
}

String? _maxValueValidator(String? value, String? minValue) {
  final val = value?.trim();
  final minVal = minValue?.trim();

  if(val == null || val.isEmpty) {
    return '';
  }

  if(!RegExp(r'^\d+$').hasMatch(val)) {
    return 'Invalid number, only integers';
  }

  if(minVal == null || minVal.isEmpty) {
    return null;
  }

  if(!RegExp(r'^\d+$').hasMatch(minVal)) {
    return null;
  }

  final valInt = int.parse(val);
  final minValInt = int.parse(minVal);

  if(valInt<=minValInt) {
    return 'Must be greater than min value';
  }

  return null;
}


