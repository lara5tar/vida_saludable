import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;
  final bool addAge;

  const CustomDropdown({
    super.key,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.addAge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        hint: Text(hint),
        value: value,
        onChanged: onChanged,
        underline: const SizedBox(),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              addAge && !value.toLowerCase().contains('año')
                  ? '$value años'
                  : value,
            ),
          );
        }).toList(),
      ),
    );
  }
}
