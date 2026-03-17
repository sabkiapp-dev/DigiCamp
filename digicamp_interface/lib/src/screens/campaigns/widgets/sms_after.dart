import 'package:flutter/material.dart';
import 'package:digicamp_interface/src/models/models.dart';

class SMSAfterWidget extends StatelessWidget {
  const SMSAfterWidget({
    super.key,
    required this.dialPlan,
    this.onChanged,
  });
  final DialPlanModel dialPlan;
  final ValueChanged<int?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        padding: EdgeInsets.zero,
        items: _buildSmsAfter().entries.toList().map((entry) {
          return DropdownMenuItem(
            value: entry.key,
            child: Text(entry.value),
          );
        }).toList(),
        hint: const Text("N/A"),
        disabledHint: const Text(
          "Please select SMS",
        ),
        onChanged: dialPlan.templateId == null ? null : onChanged,
        isDense: true,
        value: dialPlan.smsAfter,
      ),
    );
  }

  Map<int, String> _buildSmsAfter() {
    final map = <int, String>{};
    for (int dtmf = 0; dtmf < 10; dtmf++) {
      if (dialPlan.options[dtmf] != null) {
        map.addAll({dtmf: "DTMF $dtmf"});
      }
    }
    if (dialPlan.mainVoiceId != null) {
      map.addAll({-1: "Main Voice"});
    }
    if (dialPlan.optionVoiceId != null) {
      map.addAll({-2: "Option Voice"});
    }
    return map;
  }
}
