import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/data_models/voting_form/voting_form.dart';
import 'package:swift_contest/model/data_models/voting_form/voting_form_field.dart';
import 'package:swift_contest/model/data_models/voting_form/voting_form_field_type.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';

class OrganizerVotingFormEditPage extends StatefulWidget {
  final String contestId;
  final Map<String, dynamic> votingFormJson;

  const OrganizerVotingFormEditPage({
    super.key,
    required this.contestId,
    required this.votingFormJson,
  });

  @override
  State<OrganizerVotingFormEditPage> createState() => _OrganizerVotingFormEditPageState();
}

class _OrganizerVotingFormEditPageState extends State<OrganizerVotingFormEditPage> {
  bool isEdited = false;
  final List<VotingFormField> fields = [];

  @override
  void initState() {
    super.initState();
    final votingForm = VotingForm.fromJson(widget.votingFormJson);
    fields.addAll(votingForm.fields);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voting form'),
        actions: [
          FilledButton(
            onPressed: (isEdited) ? () {
              context.pop(fields);
            } : null,
            child: Text('Save'),
          ),
        ],
      ),
      body: SafeArea(child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Stack(
              fit: StackFit.loose,
              children: [
                (fields.isEmpty)
                    ? Text('No field added yet')
                    : ListView.builder(
                        itemCount: fields.length,
                        itemBuilder: (context, index) {
                          final field = fields[index];
                          return ListTile(
                            title: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(field.name),
                                    (field.isOptional) ? Text(' [Optional]') : SizedBox.shrink(),
                                  ],
                                ),
                                if (field is TextualVotingFormField)
                                  Row(
                                    children: [
                                      Text('textual'),
                                    ],
                                  ),
                                if (field is NumericVotingFormField)
                                  Row(
                                    children: [
                                      Text('numeric '),
                                      Text('['),
                                      ((field).minValue == null)
                                          ? Text('unlimited')
                                          : Text((field).minValue.toString()),
                                      Text('-'),
                                      ((field).maxValue == null)
                                          ? Text('unlimited')
                                          : Text((field).maxValue.toString()),
                                      Text(']'),
                                    ],
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isEdited = true;
                                      fields.remove(field);
                                    });
                                  },
                                  icon: Icon(Icons.minimize),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                Positioned(
                  bottom: 32,
                  right: 16,
                  child: IconButton(
                    onPressed: () async {
                      final VotingFormField? newField = await showAddFieldDialog(context);
                      if (newField != null) {
                        setState(() {
                          isEdited = true;
                          fields.add(newField);
                        });
                      }
                    },
                    icon: Icon(Icons.add),
                  ),
                ),
              ],
            ),
          );
        },
      )),
    );
  }
}

Future<VotingFormField?> showAddFieldDialog(BuildContext context) async {
  final formKey = GlobalKey<FormState>();
  VotingFormFieldType selectedVotingFormFieldType = VotingFormFieldType.textual;
  bool isOptional = false;
  String name = '';
  String minValue = '';
  String maxValue = '';

  return await showDialog<VotingFormField?>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Form(
            key: formKey,
            child: AlertDialog(
              title: Text('Add field'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: RadioListTile<VotingFormFieldType>(
                            title: const Text('Textual'),
                            value: VotingFormFieldType.textual,
                            groupValue: selectedVotingFormFieldType,
                            contentPadding: EdgeInsets.all(1),
                            shape: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            onChanged: (value) {
                              setState(
                                () => selectedVotingFormFieldType = value!,
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<VotingFormFieldType>(
                            title: const Text('Numeric'),
                            value: VotingFormFieldType.numeric,
                            groupValue: selectedVotingFormFieldType,
                            contentPadding: EdgeInsets.all(1),
                            shape: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            onChanged: (value) {
                              setState(
                                () => selectedVotingFormFieldType = value!,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('True'),
                            value: true,
                            groupValue: isOptional,
                            contentPadding: EdgeInsets.all(1),
                            shape: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            onChanged: (value) {
                              setState(
                                () => isOptional = value!,
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('False'),
                            value: false,
                            groupValue: isOptional,
                            contentPadding: EdgeInsets.all(1),
                            shape: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            onChanged: (value) {
                              setState(
                                () => isOptional = value!,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    CustomTextFormFieldUnderlined(
                      label: 'Name',
                      onChanged: (value) => name = value,
                    ),
                    (selectedVotingFormFieldType == VotingFormFieldType.numeric)
                        ? Column(
                            children: [
                              CustomTextFormFieldUnderlined(
                                label: 'Min value',
                                onChanged: (value) => minValue = value,
                              ),
                              CustomTextFormFieldUnderlined(
                                label: 'Max value',
                                onChanged: (value) => maxValue = value,
                              ),
                            ],
                          )
                        : SizedBox.shrink(),
                  ],
                ),
              ),
              actions: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () {
                          context.pop();
                        },
                        child: Text('Cancel')),
                    TextButton(
                        onPressed: () {
                          if (formKey.currentState?.validate() ?? false) {
                            if (selectedVotingFormFieldType == VotingFormFieldType.textual) {
                              final newField =
                                  TextualVotingFormField(name: name, isOptional: isOptional);
                              context.pop(newField);
                            } else if (selectedVotingFormFieldType == VotingFormFieldType.numeric) {
                              final minValueInt = int.tryParse(minValue);
                              final maxValueInt = int.tryParse(maxValue);
                              final newField = NumericVotingFormField(
                                  name: name,
                                  isOptional: isOptional,
                                  minValue: minValueInt,
                                  maxValue: maxValueInt);
                              context.pop(newField);
                            }
                          }
                        },
                        child: Text('Add')),
                  ],
                )
              ],
            ),
          );
        },
      );
    },
  );
}
