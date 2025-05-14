import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';
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
  late List<VotingFormFieldRaw> fields;

  @override
  void initState() {
    super.initState();
    fields = widget.votingFormFieldsJson
        .map((e) => VotingFormFieldRaw.fromJson(e))
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
                      final VotingFormFieldRaw? newField =
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

Future<VotingFormFieldRaw?> showAddFieldDialog(BuildContext context) async {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final minValueController = TextEditingController();
  final maxValueController = TextEditingController();

  return await showDialog<VotingFormFieldRaw?>(
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
                    CustomTextFormFieldUnderlined(
                      controller: nameController,
                      label: 'Name',
                    ),
                    Column(
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
                    ),
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
                            final minValueInt =
                                int.tryParse(minValueController.text.trim());
                            final maxValueInt =
                                int.tryParse(maxValueController.text.trim());
                            final newField = VotingFormFieldRaw(
                              name: nameController.text.trim(),
                              minValue: minValueInt,
                              maxValue: maxValueInt,
                            );
                            context.pop(newField);
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
