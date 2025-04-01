import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/google_place_models/google_place.dart';
import 'package:swift_contest/model/google_place_models/google_place_suggestion.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/viewmodel/blocs/bloc_status.dart';
import 'package:swift_contest/viewmodel/blocs/widgets_blocs/place_picker_field_bloc/place_picker_field_bloc.dart';
import 'package:swift_contest/viewmodel/repositories/google_place_repository.dart';

class PlacePickerField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final Function(GooglePlace) onSelected;
  final String? Function(String?)? validator;

  const PlacePickerField({
    required this.controller,
    required this.label,
    required this.onSelected,
    this.validator,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
      controller: controller,
      validator: validator,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        helperText: '',
        helperStyle: TextStyle(height: 1),
        errorStyle: TextStyle(height: 1),
        label: Text(label),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: Icon(Icons.calendar_today),
        suffixIcon: TextButton(
            onPressed: () async {
              final place = await _showLocationSearchDialog(context: context);
              if (place != null) {
                controller.text = place.address;
                onSelected(place);
              }
            },
            child: Text('Select')),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.inversePrimary),
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.inversePrimary),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.inversePrimary),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.errorContainer),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.errorContainer),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

Future<GooglePlace?> _showLocationSearchDialog({required BuildContext context}) async {
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
            content: BlocProvider<PlacePickerFieldBloc>(
              create: (context) => PlacePickerFieldBloc(
                googlePlaceRepository: context.read<GooglePlaceRepository>(),
              ),
              child: Column(
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
                        if (value.trim().isNotEmpty) {
                          context
                              .read<PlacePickerFieldBloc>()
                              .add(PlacePickerFieldSearchPlaceSuggestions(query: value));
                        } else {
                          context
                              .read<PlacePickerFieldBloc>()
                              .add(PlacePickerFieldSearchPlaceSuggestions(query: ' '));
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  BlocConsumer<PlacePickerFieldBloc, PlacePickerFieldState>(
                    listener: (context, state) {
                      if (state.status.isFailure) {
                        showSnackBar(context: context, text: state.message!);
                      }
                    },
                    builder: (context, state) {
                      if (state.status.isLoading) {
                        return Loader();
                      }
                      if (state.status.isSuccess) {
                        final suggestions = state.googlePlaceSuggestions;
                        if (suggestions!.isNotEmpty) {
                          return SizedBox(
                            width: 250,
                            height: 200,
                            child: ListView.builder(
                              itemCount: (suggestions.length > 5) ? 5 : suggestions.length,
                              itemBuilder: (context, index) {
                                final suggestion = suggestions[index];
                                return ListTile(
                                  title: Text(suggestion.address),
                                  onTap: () {
                                    searchController.text = suggestion.address;
                                    setState(() => selectedSuggestion = suggestion);
                                  },
                                );
                              },
                            ),
                          );
                        }
                      }
                      return const Center(child: Text('No suggestion'));
                    },
                  ),
                ],
              ),
            ),
            actions: [
              BlocProvider<PlacePickerFieldBloc>(
                create: (context) => PlacePickerFieldBloc(
                    googlePlaceRepository: context.read<GooglePlaceRepository>()),
                child: BlocConsumer<PlacePickerFieldBloc, PlacePickerFieldState>(
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
                                  context.read<PlacePickerFieldBloc>().add(
                                      PlacePickerFieldFetchPlace(id: selectedSuggestion!.placeId));
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
