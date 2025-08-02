import 'package:flutter/material.dart';
import 'package:swift_contest/model/database/entities/voting_form_field.dart';

class CustomSliderFormField extends StatefulWidget {
  final VotingFormField votingFormField;
  final TextEditingController controller;
  final bool isEnabled;
  const CustomSliderFormField({required this.votingFormField, required this.controller, this.isEnabled = true, super.key});

  @override
  State<CustomSliderFormField> createState() => _CustomSliderFormFieldState();
}

class _CustomSliderFormFieldState extends State<CustomSliderFormField> {
  late final VotingFormField votingFormField;
  late final TextEditingController controller;
  late final bool isEnabled;

  @override
  void initState() {
    super.initState();
    votingFormField = widget.votingFormField;
    controller = widget.controller;
    isEnabled = widget.isEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      enabled: isEnabled,
      validator: (isEnabled)
          ? (value) => _validateSliderField(value, votingFormField.isRequired) : null,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (field) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if(!votingFormField.isRequired)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<String>(
                          activeColor: Theme.of(context).colorScheme.tertiary,
                          value: '',
                          groupValue:
                          controller
                              .text,
                          onChanged: (isEnabled) ? (value) {
                            setState(() {
                              field.didChange(value!);
                              controller
                                  .text = value;
                            });
                          } : null,
                        ),
                        Text('None'),
                      ],
                    ),
                  for (int i = votingFormField.sliderMinValue!;
                  i <= votingFormField.sliderMaxValue!;
                  i++)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<String>(
                          activeColor: Theme.of(context).colorScheme.tertiary,
                          value: i.toString(),
                          groupValue: controller
                              .text,
                          onChanged: (isEnabled) ? (value) {
                            setState(() {
                              field.didChange(value!);
                              controller
                                  .text = value;
                            });
                          } : null,
                        ),
                        Text(i.toString()),
                      ],
                    ),
                ],
              ),
            ),
            if (field.hasError)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  field.errorText!,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(
                      color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        );
      },
    );
  }
}

String? _validateSliderField(String? value, bool isRequired) {
  if (value == null || value.trim().isEmpty) {
    return (isRequired) ? 'Required' : null;
  }
  return null;
}
