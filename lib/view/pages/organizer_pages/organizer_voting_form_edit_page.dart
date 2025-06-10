import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/bundles/voting_form_bundle.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';
import 'package:swift_contest/utils/functions/gen_uuid.dart';
import 'package:swift_contest/utils/functions/now.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
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
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Voting Form',
        actions: [
          BlocConsumer<OrganizerVotingFormEditPageBloc, OrganizerVotingFormEditPageState>(
            listener: (context, state) {
              if (state.message != null) {
                showSnackBar(context: context, text: state.message!);
              }
              if (state.status.isSuccess && state.sourceEvent is OrganizerVotingFormEditPageUpdateVotingForm) {
                context.pop(true);
              }
            },
            builder: (context, state) {
              return FilledButton(
                onPressed: (isEdited)
                    ? () {
                        context.read<OrganizerVotingFormEditPageBloc>().add(
                            OrganizerVotingFormEditPageUpdateVotingForm(
                                votingFormId: votingFormBundle.votingForm.id,
                                votingFormFields: updatedFields));
                      }
                    : null,
                child: Text('Save'),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<OrganizerVotingFormEditPageBloc, OrganizerVotingFormEditPageState>(
          builder: (context, state) {
            if (state.status.isLoading) {
              return Loader();
            }
            return (updatedFields.isEmpty)
                ? Text('No field added yet')
                : ListView.builder(
                    itemCount: updatedFields.length,
                    itemBuilder: (context, index) {
                      final field = updatedFields[index];
                      return ListTile(
                        title: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(field.name),
                            Row(
                              children: [
                                Text('min: '),
                                ((field).minValue == null)
                                    ? Text('0, ')
                                    : Text((field).minValue.toString()),
                                Text('max: '),
                                ((field).maxValue == null)
                                    ? Text('\u221E', style: TextStyle(fontSize: 24))
                                    : Text((field).maxValue.toString()),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  isEdited = true;
                                  updatedFields.remove(field);
                                });
                              },
                              icon: Icon(Icons.remove),
                            ),
                          ],
                        ),
                      );
                    },
                  );
          },
        ),
      ),
      floatingActionButton: IconButton(
        onPressed: () async {
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
        },
        icon: Icon(Icons.add),
      ),
    );

    // return BlocConsumer<OrganizerVotingFormEditPageBloc, OrganizerVotingFormEditPageState>(
    //   listener: (context, state) {},
    //   builder: (context, state) {
    //     switch (state.status) {
    //       case BlocStatus.initial:
    //         return SizedBox.shrink();
    //       case BlocStatus.loading:
    //         return Loader();
    //       case BlocStatus.failure:
    //         return RefreshIndicator.adaptive(
    //           onRefresh: () async => context
    //               .read<OrganizerSingleOperationBloc>()
    //               .add(OrganizerSingleOperationGetVotingForm(votingFormId: widget.votingFormId)),
    //           child: ListView(physics: AlwaysScrollableScrollPhysics()),
    //         );
    //       case BlocStatus.success:
    //         return Scaffold(
    //           appBar: AppBar(
    //             title: Text('Voting form'),
    //             actions: [
    //               FilledButton(
    //                 onPressed: (isEdited)
    //                     ? () {
    //                         final List<Map<String, dynamic>> fieldsJson =
    //                             fields.map((e) => e.toJson()).toList();
    //                         context.pop(fieldsJson);
    //                       }
    //                     : null,
    //                 child: Text('Save'),
    //               ),
    //             ],
    //           ),
    //           body: SafeArea(child: LayoutBuilder(
    //             builder: (context, constraints) {
    //               return SizedBox(
    //                 width: constraints.maxWidth,
    //                 height: constraints.maxHeight,
    //                 child: Stack(
    //                   fit: StackFit.loose,
    //                   children: [
    //                     (fields.isEmpty)
    //                         ? Text('No field added yet')
    //                         : ListView.builder(
    //                             itemCount: fields.length,
    //                             itemBuilder: (context, index) {
    //                               final field = fields[index];
    //                               return ListTile(
    //                                 title: Column(
    //                                   children: [
    //                                     Row(
    //                                       children: [
    //                                         Text('['),
    //                                         ((field).minValue == null)
    //                                             ? Text('und')
    //                                             : Text((field).minValue.toString()),
    //                                         Text(' - '),
    //                                         ((field).maxValue == null)
    //                                             ? Text('und')
    //                                             : Text((field).maxValue.toString()),
    //                                         Text(']'),
    //                                       ],
    //                                     ),
    //                                   ],
    //                                 ),
    //                                 trailing: Row(
    //                                   mainAxisSize: MainAxisSize.min,
    //                                   children: [
    //                                     IconButton(
    //                                       onPressed: () {
    //                                         setState(() {
    //                                           isEdited = true;
    //                                           fields.remove(field);
    //                                         });
    //                                       },
    //                                       icon: Icon(Icons.minimize),
    //                                     ),
    //                                   ],
    //                                 ),
    //                               );
    //                             },
    //                           ),
    //                     Positioned(
    //                       bottom: 32,
    //                       right: 16,
    //                       child: IconButton(
    //                         onPressed: () async {
    //                           final VotingFormFieldRaw? newField =
    //                               await showAddFieldDialog(context);
    //                           if (newField != null) {
    //                             setState(() {
    //                               isEdited = true;
    //                               fields.add(newField);
    //                             });
    //                           }
    //                         },
    //                         icon: Icon(Icons.add),
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               );
    //             },
    //           )),
    //         );
    //     }
    //   },
    // );
  }
}

Future<VotingFormField?> showAddFieldDialog(
    {required BuildContext context, required String votingFormId, required int orderIndex}) async {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final minValueController = TextEditingController();
  final maxValueController = TextEditingController();

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
                            final minValueInt = int.tryParse(minValueController.text.trim());
                            final maxValueInt = int.tryParse(maxValueController.text.trim());
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
                )
              ],
            ),
          );
        },
      );
    },
  );
}
