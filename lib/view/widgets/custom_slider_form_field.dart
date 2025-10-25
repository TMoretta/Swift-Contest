import 'package:flutter/material.dart';
import 'package:swift_contest/model/database/entities/voting_form_field.dart';

class CustomSliderFormField extends StatefulWidget {
  final VotingFormField votingFormField;
  final TextEditingController controller;
  final bool isEnabled;
  final String? Function(String?)? validator;

  const CustomSliderFormField({
    required this.votingFormField,
    required this.controller,
    this.validator,
    this.isEnabled = true,
    super.key,
  });

  @override
  State<CustomSliderFormField> createState() => _CustomSliderFormFieldState();
}

class _CustomSliderFormFieldState extends State<CustomSliderFormField> {
  late final VotingFormField votingFormField;
  late final TextEditingController controller;
  late final bool isEnabled;
  late final String? Function(String?)? validator;


  @override
  void initState() {
    super.initState();
    votingFormField = widget.votingFormField;
    controller = widget.controller;
    isEnabled = widget.isEnabled;
    validator = widget.validator;
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      enabled: isEnabled,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (field) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: RadioGroup<String>(
                onChanged: (value) {
                  if(isEnabled) {
                    setState(() {
                      field.didChange(value!);
                      controller.text = value;
                    });
                  }
                },
                groupValue: controller.text,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!votingFormField.isRequired)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio<String>(
                            activeColor: Theme.of(context).colorScheme.tertiary,
                            value: '',
                          ),
                          const Text('None'),
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
                          ),
                          Text(i.toString()),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  field.errorText!,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        );
      },
    );
  }
}
