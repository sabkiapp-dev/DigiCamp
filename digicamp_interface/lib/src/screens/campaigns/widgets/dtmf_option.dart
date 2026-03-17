import 'package:flutter/material.dart';
import 'package:digicamp_interface/src/models/models.dart';

class DtmfOption extends StatelessWidget {
  const DtmfOption({
    super.key,
    this.onChanged,
    required this.dialPlan,
    this.value,
    required this.entries,
  });
  final ValueChanged<int?>? onChanged;
  final DialPlanModel dialPlan;
  final int? value;
  final List<DialPlanModel> entries;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        padding: EdgeInsets.zero,
        items: [
          for (final entry in entries)
            DropdownMenuItem(
              value: entry.id,
              child: Text("Goto Extension ${entry.extensionId}"),
            ),
          const DropdownMenuItem(
            value: 0,
            child: Text('Just Record DTMF'),
          ),
        ],
        hint: const Text("N/A"),
        disabledHint: const Text("Option voice is required"),
        onChanged: dialPlan.optionVoiceId == null ? null : onChanged,
        isDense: true,
        value: value,
      ),
    );
  }
}
