import 'package:flutter/material.dart';

/// A decimal numeric input with a unit suffix (e.g. "kg", "lb"). The value
/// itself stays in whatever unit [unitLabel] names — conversion to a
/// canonical storage unit, if any, is the caller's responsibility.
class UnitAwareNumberField extends StatelessWidget {
  const UnitAwareNumberField({
    required this.controller,
    required this.unitLabel,
    required this.labelText,
    this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final String unitLabel;
  final String labelText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: labelText, suffixText: unitLabel),
      onChanged: onChanged,
    );
  }
}
