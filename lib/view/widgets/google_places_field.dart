// import 'package:flutter/material.dart';
// import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
// import 'package:swift_contest/utils/constants/constants.dart';
// import 'package:swift_contest/utils/functions/show_snack_bar.dart';
//
// class GooglePlacesField extends StatefulWidget {
//   final String label;
//   final TextEditingController textController;
//   final String? Function(String?)? validator;
//
//   const GooglePlacesField({
//     required this.label,
//     required this.textController,
//     this.validator,
//     super.key,
//   });
//
//   @override
//   State<GooglePlacesField> createState() => _GooglePlacesFieldState();
// }
//
// class _GooglePlacesFieldState extends State<GooglePlacesField> {
//   final _placesSdk = FlutterGooglePlacesSdk(Constants.googlePlacesApiKey);
//   OverlayEntry? _overlayEntry;
//   final LayerLink _layerLink = LayerLink();
//   final FocusNode _focusNode = FocusNode();
//   late final VoidCallback _textControllerListener;
//   late final VoidCallback _focusNodeListener;
//   List<AutocompletePrediction> _suggestions = [];
//   String? _selectedPlaceFromSuggestions;
//
//   OverlayEntry _createOverlayEntry() {
//     RenderBox renderBox = context.findRenderObject() as RenderBox;
//     final size = renderBox.size;
//
//     return OverlayEntry(
//       builder: (context) => Positioned(
//         width: size.width,
//         child: CompositedTransformFollower(
//           link: _layerLink,
//           showWhenUnlinked: false,
//           offset: Offset(0.0, size.height),
//           child: Material(
//             elevation: 2.0,
//             child: ConstrainedBox(
//               constraints: BoxConstraints(maxHeight: 200),
//               child: ListView.builder(
//                 padding: EdgeInsets.zero,
//                 itemCount: _suggestions.length > 5 ? 5 : _suggestions.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     title: Text(_suggestions[index].fullText),
//                     onTap: () {
//                       widget.textController.text = _suggestions[index].fullText;
//                       _selectedPlaceFromSuggestions = _suggestions[index].fullText;
//                       debugPrint(_selectedPlaceFromSuggestions);
//                       _removeOverlay();
//                       FocusScope.of(context).unfocus();
//                     },
//                   );
//                 },
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _showOverlay() {
//     if (_suggestions.isEmpty) return;
//     _removeOverlay();
//     _overlayEntry = _createOverlayEntry();
//     Overlay.of(context).insert(_overlayEntry!);
//   }
//
//   void _removeOverlay() {
//     _overlayEntry?.remove();
//     _overlayEntry = null;
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _textControllerListener = () async {
//       final query = widget.textController.text;
//       if (query.trim().isNotEmpty) {
//         if(query!= _selectedPlaceFromSuggestions) {
//           _selectedPlaceFromSuggestions = null;
//         }
//         final result = await _placesSdk.findAutocompletePredictions(query);
//         if (_focusNode.hasFocus) {
//           setState(() {
//             _suggestions = result.predictions;
//           });
//           _showOverlay();
//         }
//       } else {
//         _suggestions = [];
//         _removeOverlay();
//       }
//     };
//     widget.textController.addListener(_textControllerListener);
//     _focusNodeListener = () {
//       if (!_focusNode.hasFocus) {
//         _removeOverlay();
//         if(_selectedPlaceFromSuggestions==null) {
//           showSnackBar(context, 'Select a place from the suggestions');
//         }
//       }
//     };
//     _focusNode.addListener(_focusNodeListener);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return CompositedTransformTarget(
//       link: _layerLink,
//       child: TextFormField(
//         controller: widget.textController,
//         focusNode: _focusNode,
//         validator: widget.validator,
//         decoration: InputDecoration(
//           label: Text(widget.label),
//           errorStyle: TextStyle(height: 0),
//           prefixIcon: Icon(Icons.location_on_outlined),
//           suffixIcon: widget.textController.text.isNotEmpty
//               ? Row(
//                   mainAxisSize: MainAxisSize.min,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     IconButton(
//                       onPressed: () {
//                         setState(() {
//                           widget.textController.clear();
//                         });
//                       },
//                       icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
//                     ),
//                     Visibility(
//                       visible: (_overlayEntry != null),
//                       child: IconButton(
//                         onPressed: () {
//                           _removeOverlay();
//                         },
//                         icon: Icon(Icons.keyboard_arrow_up,
//                             color: Theme.of(context).colorScheme.onSurface),
//                       ),
//                     ),
//                   ],
//                 )
//               : null,
//           border: OutlineInputBorder(
//             borderSide: BorderSide(color: Theme.of(context).colorScheme.inversePrimary),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           filled: false,
//           fillColor: Theme.of(context).colorScheme.surface,
//           focusedBorder: OutlineInputBorder(
//             borderSide: BorderSide(color: Theme.of(context).colorScheme.inversePrimary),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderSide: BorderSide(color: Theme.of(context).colorScheme.inversePrimary),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           errorBorder: OutlineInputBorder(
//             borderSide: BorderSide(color: Theme.of(context).colorScheme.errorContainer),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           focusedErrorBorder: OutlineInputBorder(
//             borderSide: BorderSide(color: Theme.of(context).colorScheme.errorContainer),
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _overlayEntry?.remove();
//     _overlayEntry?.dispose();
//     _focusNode.dispose();
//     super.dispose();
//   }
// }
//
// String? _noEmptyValidator(String? value) {
//   String? valueTrm = value?.trim();
//
//   if (valueTrm == null || valueTrm.isEmpty) {
//     return '';
//   }
//   return null;
// }
