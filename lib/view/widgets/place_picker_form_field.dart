import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/google_place_models/google_place.dart';
import 'package:swift_contest/model/google_place_models/google_place_suggestion.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/viewmodel/blocs/bloc_status.dart';
import 'package:swift_contest/viewmodel/blocs/widgets_blocs/place_picker_form_field_bloc/place_picker_form_field_bloc.dart';
import 'package:swift_contest/viewmodel/repositories/google_place_repository.dart';

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
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      style: TextStyle(
          fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
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
          onPressed: () async {
            final place = await _showLocationSearchDialog(context: context);
            if (place != null) {
              controller.text = place.address;
              if (onSelected != null) {
                onSelected!(place);
              }
            }
          },
          child: Text('Select'),
        ),
        helperText: '',
        helperStyle: TextStyle(height: 1),
        errorStyle: TextStyle(height: 1),
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).colorScheme.inversePrimary),
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
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).colorScheme.inversePrimary),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

Future<GooglePlace?> _showLocationSearchDialog(
    {required BuildContext context}) async {
  final TextEditingController searchController = TextEditingController();
  GooglePlaceSuggestion? selectedSuggestion;

  return await showDialog<GooglePlace?>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Location'),
            content: BlocProvider<PlacePickerFormFieldBloc>(
              create: (context) => PlacePickerFormFieldBloc(
                  googlePlaceRepository: context.read<GooglePlaceRepository>()),
              child: Builder(
                builder:(context) =>  Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 250,
                      child: TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          labelText: 'Search',
                          prefixIcon: Icon(Icons.search, size: 24),
                        ),
                        onChanged: (value) {
                          context.read<PlacePickerFormFieldBloc>().add(
                              PlacePickerFormFieldSearchPlaceSuggestions(
                                  query: value));
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    BlocConsumer<PlacePickerFormFieldBloc,
                        PlacePickerFormFieldState>(
                      listener: (context, state) {
                        if (state.status.isFailure) {
                          showSnackBar(context: context, text: state.message!);
                        }
                      },
                      builder: (context, state) {
                        final suggestions = state.googlePlaceSuggestions;
                        if (suggestions == null) {
                          return const Center(child: Text('No suggestion'));
                        }
                        if (suggestions.isNotEmpty) {
                          return SizedBox(
                            width: 250,
                            height: 150,
                            child: ListView.builder(
                              itemCount: (suggestions.length > 5)
                                  ? 5
                                  : suggestions.length,
                              itemBuilder: (context, index) {
                                final suggestion = suggestions[index];
                                return ListTile(
                                  title: Text(suggestion.address),
                                  onTap: () {
                                    searchController.text = suggestion.address;
                                    setState(
                                        () => selectedSuggestion = suggestion);
                                  },
                                );
                              },
                            ),
                          );
                        }
                        if (suggestions.isEmpty) {
                          return const Center(child: Text('No suggestion'));
                        }
                        return Container();
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              BlocProvider<PlacePickerFormFieldBloc>(
                create: (context) => PlacePickerFormFieldBloc(
                    googlePlaceRepository:
                        context.read<GooglePlaceRepository>()),
                child: BlocConsumer<PlacePickerFormFieldBloc,
                    PlacePickerFormFieldState>(
                  listener: (context, state) {
                    if (state.status.isSuccess) {
                      context.pop(state.googlePlace);
                    }
                    if (state.status.isFailure) {
                      showSnackBar(context: context, text: state.message!);
                    }
                  },
                  builder: (context, state) {
                    if (state.status.isLoading) {
                      return Loader();
                    }
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
                ),
              )
            ],
          );
        },
      );
    },
  );
}
