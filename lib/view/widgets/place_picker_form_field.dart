import 'package:flutter/material.dart';

class PlacePickerFormField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? label;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final bool? isFilled;
  final Color? fillColor;
  final Widget? externalIcon;
  final Color? externalIconColor;
  final Widget? prefixIcon;
  final Color? prefixIconColor;
  final Widget? suffixIcon;
  final Color? suffixIconColor;
  final bool? enabled;
  final Widget? prefix;
  final TextStyle? prefixStyle;
  final Widget? suffix;
  final TextStyle? suffixStyle;


  const PlacePickerFormField({
    required this.controller,
     this.focusNode,
    this.label,
    this.validator,
    this.autovalidateMode,
    this.isFilled,
    this.fillColor,
    this.externalIcon,
    this.externalIconColor,
    this.prefixIcon,
    this.prefixIconColor,
    this.suffixIcon,
    this.suffixIconColor,
    this.enabled,
    this.prefix,
    this.prefixStyle,
    this.suffix,
    this.suffixStyle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      enabled: enabled,
      controller: controller,
      focusNode: focusNode,
      onTapOutside: (event) => focusNode?.unfocus(),
      validator: validator,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        label: Text(label ?? ''),
        filled: isFilled,
        fillColor: fillColor,
        icon: externalIcon,
        iconColor: externalIconColor,
        prefixIcon: prefixIcon,
        prefixIconColor: prefixIconColor,
        suffixIcon: suffixIcon,
        prefix: prefix,
        prefixStyle: prefixStyle,
        suffix: suffix,
        suffixStyle: suffixStyle,
        helperText: '',
        helperStyle: const TextStyle(height: 1),
        errorStyle: const TextStyle(height: 1),
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

// Future<GooglePlace?> showLocationSearchDialog({
//   required BuildContext context,
// }) async {
//   final TextEditingController searchController = TextEditingController();
//   GooglePlaceSuggestion? selectedSuggestion;
//   final placePickerFormFieldBloc = context.read<PlacePickerFormFieldBloc>();
//   final formKey = GlobalKey<FormState>();
//
//   return await showDialog<GooglePlace?>(
//     context: context,
//     builder: (context) {
//       return BlocProvider.value(
//         value: placePickerFormFieldBloc,
//         child: BlocListener<PlacePickerFormFieldBloc, PlacePickerFormFieldState>(
//           listener: (context, state) {
//             if (state.message != null) {
//               showSnackBar(context: context, text: state.message!);
//             }
//             if (state.status.isSuccess && state.sourceEvent is PlacePickerFormFieldFetchPlace) {
//               context.pop(state.googlePlace);
//             }
//           },
//           child: AlertDialog(
//             title: const Text('Location'),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 BlocBuilder<PlacePickerFormFieldBloc, PlacePickerFormFieldState>(
//                   builder: (context, state) {
//                     return SizedBox(
//                       width: 250,
//                       child: Form(
//                         key: formKey,
//                         child: CustomTextFormField(
//                           borderType: InputBorderType.outlined,
//                           controller: searchController,
//                           label: 'Search',
//                           validator: (_) => (selectedSuggestion == null) ? 'Select a result' : null,
//                           prefixIcon: Icon(Icons.search, size: 24),
//                           onChanged: (value) async => context
//                               .read<PlacePickerFormFieldBloc>()
//                               .add(PlacePickerFormFieldSearchPlaceSuggestions(query: value)),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 10),
//                 BlocBuilder<PlacePickerFormFieldBloc, PlacePickerFormFieldState>(
//                   builder: (context, state) {
//                     if (state.googlePlaceSuggestions == null ||
//                         state.googlePlaceSuggestions!.isEmpty) {
//                       return VoidWidget();
//                     } else {
//                       final suggestions = state.googlePlaceSuggestions!;
//                       return SizedBox(
//                         height: 150,
//                         child: ListView(
//                           shrinkWrap: true,
//                           children: [
//                             for (var suggestion in suggestions)
//                               ListTile(
//                                 title: Text(suggestion.address),
//                                 onTap: () {
//                                   searchController.text = suggestion.address;
//                                   selectedSuggestion = suggestion;
//                                 },
//                               )
//                           ],
//                         ),
//                       );
//                     }
//                   },
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   context.router.pop();
//                 },
//                 child: const Text('Cancel'),
//               ),
//               TextButton(
//                 onPressed: () {
//                   if (formKey.currentState?.validate() ?? false) {
//                     context
//                         .read<PlacePickerFormFieldBloc>()
//                         .add(PlacePickerFormFieldFetchPlace(id: selectedSuggestion!.placeId));
//                   }
//                 },
//                 child: Text('Confirm'),
//               )
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }
