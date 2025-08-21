import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:swift_contest/utils/permissions/permissions.dart';
import 'package:swift_contest/view/widgets/adaptive_local_image.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';

class ImagesPickerFormField extends StatefulWidget {
  final List<XFile> initialValue;
  final int? maxImages;
  final String? Function(List<XFile>?)? validator;
  final void Function(List<XFile>?)? onSaved;

  const ImagesPickerFormField({
    this.initialValue = const [],
    this.validator,
    this.onSaved,
    this.maxImages,
    super.key,
  });

  @override
  State<ImagesPickerFormField> createState() => _ImagesPickerFormFieldState();
}

class _ImagesPickerFormFieldState extends State<ImagesPickerFormField> {
  late final int? maxImages;

  @override
  void initState() {
    super.initState();
    maxImages = widget.maxImages;
  }

  @override
  Widget build(BuildContext context) {
    return FormField<List<XFile>>(
      initialValue: widget.initialValue,
      onSaved: widget.onSaved,
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (field) {
        return Column(
          children: [
            (field.value!.isEmpty)
                ? Center(child: Text('No image selected yet.'))
                : ReorderableGridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                    ),
                    onReorder: (oldIndex, newIndex) {
                      // Create a mutable copy of the list to avoid modification errors.
                      final reorderedList = List<XFile>.from(field.value!);
                      final XFile item = reorderedList.removeAt(oldIndex);
                      reorderedList.insert(newIndex, item);
                      field.didChange(reorderedList);
                    },
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: field.value!.length,
                    itemBuilder: (context, index) {
                      return Card(
                        key: ValueKey(field.value![index].path),
                        elevation: 0,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: AdaptiveLocalImage(
                          image: field.value![index],
                          fit: BoxFit.contain,
                        ),
                      );
                    },
                  ),
            SizedBox(height: 10),
            FilledButton(
              onPressed: () async {
                // 1. If maxImages is set, show a confirmation dialog.
                if (maxImages != null) {
                  final choice =
                      await _showMaxImagesDialog(context: context, maxImages: maxImages!);
                  // User cancelled the dialog.
                  if (choice != true) return;
                }

                // 2. Request permissions (platform-aware).
                if (!kIsWeb) {
                  final bool permission = await requestPhotoLibraryPermission();
                  if (!context.mounted) return;
                  if (!permission) {
                    showSnackBar(
                        context: context, text: 'Storage permission is required to select images.');
                    return;
                  }
                }

                // 3. Pick images.
                var newImages = await pickMultipleImages();
                if (newImages.isEmpty) return;

                // 4. Check if widget is still mounted after async gap.
                if (!context.mounted) return;

                // 5. Enforce maxImages limit if necessary.
                if (maxImages != null && newImages.length > maxImages!) {
                  newImages = newImages.take(maxImages!).toList();
                  showSnackBar(context: context, text: 'Exceeded images have been discarded');
                }

                // 6. Update the FormField with the new list.
                // This is the correct way to update the value and trigger a rebuild.
                field.didChange(newImages);
              },
              child: Text('Pick images'),
            ),
            if (field.hasError)
              Text(field.errorText!,
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: Theme.of(context).colorScheme.error)),
          ],
        );
      },
    );
  }
}

Future<bool?> _showMaxImagesDialog({required BuildContext context, required int maxImages}) async {
  return await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Pick images'),
          content: Text('Select at most $maxImages images. Exceeded images will be discarded.'),
          actions: [
            TextButton(
              onPressed: () {
                context.router.pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.router.pop(true);
              },
              child: const Text('Ok'),
            ),
          ],
        );
      });
}

Future<List<XFile>> pickMultipleImages() async {
  final ImagePicker picker = ImagePicker();
  final List<XFile> pickedImages = await picker.pickMultiImage(imageQuality: 60);

  return pickedImages;
}
