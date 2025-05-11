import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';
import 'package:swift_contest/model/enums/form_field_type.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';

class OrganizerVotingFormEditPage extends StatefulWidget {
  final List<Map<String, dynamic>> votingFormFieldsJson;

  const OrganizerVotingFormEditPage({
    required this.votingFormFieldsJson,
    super.key,
  });

  @override
  State<OrganizerVotingFormEditPage> createState() =>
      _OrganizerVotingFormEditPageState();
}

class _OrganizerVotingFormEditPageState
    extends State<OrganizerVotingFormEditPage> {
  bool isEdited = false;
  late List<RawVotingFormField> fields;

  @override
  void initState() {
    super.initState();
    fields = widget.votingFormFieldsJson
        .map((e) => RawVotingFormField.fromJson(e))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voting form'),
        actions: [
          FilledButton(
            onPressed: (isEdited)
                ? () {
                    final List<Map<String, dynamic>> fieldsJson =
                        fields.map((e) => e.toJson()).toList();
                    context.pop(fieldsJson);
                  }
                : null,
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
                                    (field.isOptional)
                                        ? Text(' [Optional]')
                                        : SizedBox.shrink(),
                                  ],
                                ),
                                if (field.fieldType == FormFieldType.textual)
                                  Row(
                                    children: [
                                      Text('textual'),
                                    ],
                                  ),
                                if (field.fieldType == FormFieldType.numeric)
                                  Row(
                                    children: [
                                      Text('numeric '),
                                      Text('['),
                                      ((field).minValue == null)
                                          ? Text('und')
                                          : Text((field).minValue.toString()),
                                      Text(' - '),
                                      ((field).maxValue == null)
                                          ? Text('und')
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
                      final RawVotingFormField? newField =
                          await showAddFieldDialog(context);
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

Future<RawVotingFormField?> showAddFieldDialog(BuildContext context) async {
  final formKey = GlobalKey<FormState>();
  FormFieldType selectedFormFieldType = FormFieldType.textual;
  bool isOptional = false;
  final nameController = TextEditingController();
  final minValueController = TextEditingController();
  final maxValueController = TextEditingController();

  return await showDialog<RawVotingFormField?>(
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
                          child: RadioListTile<FormFieldType>(
                            title: const Text('Textual'),
                            value: FormFieldType.textual,
                            groupValue: selectedFormFieldType,
                            contentPadding: EdgeInsets.all(1),
                            shape: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            onChanged: (value) {
                              setState(
                                () => selectedFormFieldType = value!,
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<FormFieldType>(
                            title: const Text('Numeric'),
                            value: FormFieldType.numeric,
                            groupValue: selectedFormFieldType,
                            contentPadding: EdgeInsets.all(1),
                            shape: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            onChanged: (value) {
                              setState(
                                () => selectedFormFieldType = value!,
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
                      controller: nameController,
                      label: 'Name',
                    ),
                    (selectedFormFieldType == FormFieldType.numeric)
                        ? Column(
                            children: [
                              CustomTextFormFieldUnderlined(
                                controller: minValueController,
                                label: 'Min value',
                              ),
                              CustomTextFormFieldUnderlined(
                                controller: maxValueController,
                                label: 'Max value',
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
                            if (selectedFormFieldType ==
                                FormFieldType.textual) {
                              final newField = RawVotingFormField(
                                name: nameController.text.trim(),
                                isOptional: isOptional,
                                fieldType: FormFieldType.textual,
                              );
                              context.pop(newField);
                            } else if (selectedFormFieldType ==
                                FormFieldType.numeric) {
                              final minValueInt =
                                  int.tryParse(minValueController.text.trim());
                              final maxValueInt =
                                  int.tryParse(maxValueController.text.trim());
                              final newField = RawVotingFormField(
                                name: nameController.text.trim(),
                                fieldType: FormFieldType.numeric,
                                isOptional: isOptional,
                                minValue: minValueInt,
                                maxValue: maxValueInt,
                              );
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
