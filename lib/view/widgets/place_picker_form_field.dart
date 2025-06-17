import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/google_place_models/google_place.dart';
import 'package:swift_contest/model/google_place_models/google_place_suggestion.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/viewmodel/blocs/widgets_blocs/place_picker_form_field_bloc/place_picker_form_field_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class PlacePickerFormField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final Function(GooglePlace)? onSelected;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final bool? isFilled;
  final Color? fillColor;
  final Icon? externalIcon;
  final Color? externalIconColor;
  final Icon? prefixIcon;
  final Color? prefixIconColor;
  final bool? enabled;

  const PlacePickerFormField({
    required this.controller,
    this.label,
    this.onSelected,
    this.validator,
    this.autovalidateMode,
    this.isFilled,
    this.fillColor,
    this.externalIcon,
    this.externalIconColor,
    this.prefixIcon,
    this.prefixIconColor,
    this.enabled,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      enabled: enabled,
      controller: controller,
      validator: validator,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        label: Text(label ?? ''),
        filled: isFilled,
        fillColor: fillColor,
        icon: externalIcon,
        iconColor: externalIconColor,
        prefixIcon: prefixIcon,
        prefixIconColor: prefixIconColor,
        suffixIcon: TextButton(
          onPressed: (enabled ?? true) ? () async {
            FocusManager.instance.primaryFocus?.unfocus();
            final place = await _showLocationSearchDialog(context: context);
            if (place != null) {
              controller.text = place.address;
              if (onSelected != null) {
                onSelected!(place);
              }
            }
          } : null,
          child: Text('Select'),
        ),
        helperText: '',
        helperStyle: TextStyle(height: 1),
        errorStyle: TextStyle(height: 1),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.surfaceDim,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.errorContainer,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}

Future<GooglePlace?> _showLocationSearchDialog({
  required BuildContext context,
}) async {
  final TextEditingController searchController = TextEditingController();
  GooglePlaceSuggestion? selectedSuggestion;
  final placePickerFormFieldBloc = context.read<PlacePickerFormFieldBloc>();

  return await showDialog<GooglePlace?>(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return BlocProvider.value(
          value: placePickerFormFieldBloc,
          child: BlocListener<PlacePickerFormFieldBloc, PlacePickerFormFieldState>(
            listener: (context, state) {
              if (state.message != null) {
                showSnackBar(context: context, text: state.message!);
              }
              if (state.status.isSuccess && state.sourceEvent is PlacePickerFormFieldFetchPlace) {
                context.pop(state.googlePlace);
              }
            },
            child: AlertDialog(
              title: const Text('Location'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BlocBuilder<PlacePickerFormFieldBloc, PlacePickerFormFieldState>(
                    builder: (context, state) {
                      return SizedBox(
                        width: 250,
                        child: TextField(
                          controller: searchController,
                          decoration: const InputDecoration(
                            labelText: 'Search',
                            prefixIcon: Icon(Icons.search, size: 24),
                          ),
                          onChanged: (value) {
                            context
                                .read<PlacePickerFormFieldBloc>()
                                .add(PlacePickerFormFieldSearchPlaceSuggestions(query: value));
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  BlocBuilder<PlacePickerFormFieldBloc, PlacePickerFormFieldState>(
                    builder: (context, state) {
                      if (state.googlePlaceSuggestions == null ||
                          state.googlePlaceSuggestions!.isEmpty) {
                        return SizedBox.shrink();
                      } else {
                        final suggestions = state.googlePlaceSuggestions!;
                        return SizedBox(
                          height: 150,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (var suggestion in suggestions)
                                  ListTile(
                                    title: Text(suggestion.address),
                                    onTap: () {
                                      searchController.text = suggestion.address;
                                      setState(() => selectedSuggestion = suggestion);
                                    },
                                  )
                              ],
                            ),
                          ),
                          // child: ListView.builder(
                          //   // shrinkWrap: true,
                          //   itemCount: 4,
                          //   itemBuilder: (context, index) {
                          //     final suggestion = suggestions[index];
                          //     return ListTile(
                          //       title: Text(suggestion.address),
                          //       onTap: () {
                          //         searchController.text = suggestion.address;
                          //         setState(() => selectedSuggestion = suggestion);
                          //       },
                          //     );
                          //   },
                          // ),
                        );
                      }
                      // if (suggestions == null) {
                      //   return const Center(child: Text('No suggestion'));
                      // }
                      // if (suggestions.isNotEmpty) {
                      //   return SizedBox(
                      //     width: 250,
                      //     height: 150,
                      //     child: ListView.builder(
                      //       itemCount: (suggestions.length > 5) ? 5 : suggestions.length,
                      //       itemBuilder: (context, index) {
                      //         final suggestion = suggestions[index];
                      //         return ListTile(
                      //           title: Text(suggestion.address),
                      //           onTap: () {
                      //             searchController.text = suggestion.address;
                      //             setState(() => selectedSuggestion = suggestion);
                      //           },
                      //         );
                      //       },
                      //     ),
                      //   );
                      // }
                      // if (suggestions.isEmpty) {
                      //   return const Center(child: Text('No suggestion'));
                      // }
                      // return Container();
                    },
                  ),
                ],
              ),
              actions: [
                BlocBuilder<PlacePickerFormFieldBloc, PlacePickerFormFieldState>(
                  builder: (context, state) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            context.pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: (selectedSuggestion != null)
                              ? () {
                                  context.read<PlacePickerFormFieldBloc>().add(
                                      PlacePickerFormFieldFetchPlace(
                                          id: selectedSuggestion!.placeId));
                                }
                              : null,
                          child: Text('Confirm'),
                        )
                      ],
                    );
                  },
                )
              ],
            ),
          ),
        );
      });
    },
  );
}
