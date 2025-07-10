import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String) onChanged;

  const CustomSearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    super.key,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late final TextEditingController controller;
  late final FocusNode focusNode;
  late final void Function(String) onChanged;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
    focusNode = widget.focusNode;
    onChanged = widget.onChanged;
  }

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      controller: controller,
      focusNode: focusNode,
      leading: Icon(Icons.search),
      elevation: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.focused)) {
            return 1.2;
          }
          return 0.5;
        },
      ),
      backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.secondaryContainer),
      onChanged: (value) => onChanged(value),
      onTapOutside: (event) => focusNode.unfocus(),
      trailing: [
        if (controller.text.isNotEmpty)
          IconButton(
            onPressed: () {
              setState(() {
                controller.clear();
                onChanged('');
              });
            },
            icon: Icon(Icons.clear),
          ),
      ],
    );
  }
}
