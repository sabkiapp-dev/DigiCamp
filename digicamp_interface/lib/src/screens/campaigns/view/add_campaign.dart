import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:digicamp_interface/injection_container.dart';
import 'package:digicamp_interface/src/commons/general_dialogs.dart';
import 'package:digicamp_interface/src/config/app_constants.dart';
import 'package:digicamp_interface/src/models/models.dart';
import 'package:digicamp_interface/src/providers/providers.dart';
import 'package:digicamp_interface/src/utils/extensions/size_extension.dart';
import 'package:digicamp_interface/src/utils/palette.dart';
import 'package:digicamp_interface/src/utils/services/rest_api.dart';

class AddCampaign extends StatefulWidget {
  const AddCampaign({super.key});

  @override
  State<AddCampaign> createState() => _AddCampaignState();
}

class _AddCampaignState extends State<AddCampaign> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _maxCallTimeCtrl = TextEditingController(text: "600");
  final _campaignPriorityCtrl = TextEditingController(text: "1");
  final _startDateCtrl = TextEditingController(
    text: DateFormat('dd-MM-yyyy').format(DateTime.now()),
  );
  final _endDateCtrl = TextEditingController(
    text: DateFormat('dd-MM-yyyy').format(DateTime(2050, 12, 31)),
  );
  TimeOfDay? _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay? _endTime = const TimeOfDay(hour: 9, minute: 15);
  String? _dtmfLanguage;
  int? _allowRepeat;

  final List<DateTime> _startTimeRange = [];
  final List<DateTime> _endTimeRange = [];

  final languages = [
    'Hindi',
    'English',
    'Punjabi',
    'Marathi',
    'Gujarati',
    'Bengali',
    'Tamil',
    'Telugu',
    'Malayalam',
    'Kannada',
    'Assamese',
    'Oriya',
  ];
  final _repeatOptions = {
    0: 'No',
    1: 'Once',
    2: 'Twice',
  };

  CampaignModel? _campaign;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        _getCampaignDetail();
      },
    );

    _getStartTimeRange();
    _getEndTimeRange();
  }

  void _getStartTimeRange() {
    _startTimeRange.clear();
    final now = DateTime.now();
    DateTime rangeStartFrom = DateTime(
      now.year,
      now.month,
      now.day,
      7,
    );
    DateTime rangeEndTo = DateTime(
      now.year,
      now.month,
      now.day,
      20,
      15,
    );

    while (!rangeStartFrom.isAtSameMomentAs(rangeEndTo)) {
      _startTimeRange.add(rangeStartFrom);
      rangeStartFrom = rangeStartFrom.add(const Duration(minutes: 15));
    }
  }

  void _getEndTimeRange() {
    _endTimeRange.clear();
    final now = DateTime.now();
    final startTime = _startTime ?? const TimeOfDay(hour: 9, minute: 0);

    DateTime rangeStartFrom = DateTime(
      now.year,
      now.month,
      now.day,
      startTime.hour,
      startTime.minute + 15,
    );
    DateTime rangeEndTo = DateTime(
      now.year,
      now.month,
      now.day,
      21,
      15,
    );

    while (!rangeStartFrom.isAtSameMomentAs(rangeEndTo)) {
      _endTimeRange.add(rangeStartFrom);
      rangeStartFrom = rangeStartFrom.add(const Duration(minutes: 15));
    }
  }

  void _getCampaignDetail() async {
    _campaign = GoRouterState.of(context).extra as CampaignModel?;
    if (_campaign == null) {
      return;
    }
    _nameCtrl.text = _campaign!.name!;
    _descriptionCtrl.text = _campaign!.description!;
    _maxCallTimeCtrl.text = _campaign!.callCutTime.toString();
    _campaignPriorityCtrl.text = _campaign!.campaignPriority.toString();
    _startDateCtrl.text = DateFormat('dd-MM-yyyy').format(
      _campaign!.startDate!,
    );
    _endDateCtrl.text = DateFormat('dd-MM-yyyy').format(
      _campaign!.endDate!,
    );
    _startTime = TimeOfDay.fromDateTime(
      DateFormat('HH:mm:ss').parse(_campaign!.startTime!),
    );
    _endTime = TimeOfDay.fromDateTime(
      DateFormat('HH:mm:ss').parse(_campaign!.endTime!),
    );
    _dtmfLanguage = _campaign!.language;
    _allowRepeat = _campaign!.allowRepeat;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.symmetric(
          horizontal: 16.0,
        ),
        constraints: BoxConstraints(maxWidth: context.sw(0.9)),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: const [
            BoxShadow(
              color: Palette.shadowColor,
              blurRadius: 20,
            )
          ],
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Theme(
              data: Theme.of(context).copyWith(
                inputDecorationTheme: InputDecorationTheme(
                  filled: false,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Palette.borderColor,
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Palette.borderColor,
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Palette.borderColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: "Enter Campaign Name",
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter campaign name";
                      }
                      return null;
                    },
                  ),
                  const Gap(20),
                  TextFormField(
                    controller: _descriptionCtrl,
                    decoration: const InputDecoration(
                      labelText: "Enter Campaign Description",
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter description";
                      }
                      return null;
                    },
                  ),
                  const Gap(20),
                  TextFormField(
                    controller: _maxCallTimeCtrl,
                    readOnly: _campaign != null && _campaign!.status == 5,
                    decoration: const InputDecoration(
                      labelText: "Enter Max Call Time (In Seconds)",
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter call cut time";
                      }
                      return null;
                    },
                  ),
                  const Gap(20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _campaignPriorityCtrl,
                          decoration: const InputDecoration(
                            labelText:
                                "Enter Priority (Higher will be called first)",
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter campaign priority";
                            }
                            return null;
                          },
                        ),
                      ),
                      const Gap(10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _dtmfLanguage,
                          onChanged: _campaign != null && _campaign!.status == 5
                              ? null
                              : (value) {
                                  _dtmfLanguage = value;
                                },
                          decoration: const InputDecoration(
                            labelText: "Language",
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                          ),
                          items: languages.map((language) {
                            return DropdownMenuItem(
                              value: language,
                              child: Text(language),
                            );
                          }).toList(),
                          validator: (String? value) {
                            if (value == null) {
                              return "Please select language";
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const Gap(15),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Campaign Date/Time Between:"),
                  ),
                  const Gap(10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _startDateCtrl,
                          decoration: const InputDecoration(
                            labelText: "Start Date",
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                          ),
                          readOnly: true,
                          onTap: _pickStartDate,
                        ),
                      ),
                      const Gap(5),
                      Expanded(
                        child: TextFormField(
                          controller: _endDateCtrl,
                          decoration: const InputDecoration(
                            labelText: "End Date",
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                          ),
                          readOnly: true,
                          onTap: _pickEndDate,
                        ),
                      ),
                    ],
                  ),
                  const Gap(15),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Everyday Starts Between:"),
                  ),
                  const Gap(10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<TimeOfDay>(
                          value: _startTime,
                          onChanged: (value) {
                            _startTime = value!;
                            setState(() {});
                          },
                          decoration: const InputDecoration(
                            labelText: "Start Time",
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                          ),
                          items: _startTimeRange.map((date) {
                            return DropdownMenuItem(
                              value: TimeOfDay.fromDateTime(date),
                              child: Text(DateFormat.jm().format(date)),
                            );
                          }).toList(),
                        ),
                      ),
                      const Gap(5),
                      Expanded(
                        child: DropdownButtonFormField<TimeOfDay>(
                          value: _endTime,
                          onChanged: (value) {
                            _endTime = value!;
                            setState(() {});
                          },
                          decoration: const InputDecoration(
                            labelText: "End Time",
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                          ),
                          items: _endTimeRange.map((date) {
                            return DropdownMenuItem(
                              value: TimeOfDay.fromDateTime(date),
                              child: Text(DateFormat.jm().format(date)),
                            );
                          }).toList(),
                          validator: (TimeOfDay? value) {
                            if (value == null) {
                              return "Please enter end time";
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const Gap(20),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: "Allow Repeat",
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                    ),
                    value: _allowRepeat,
                    onChanged: (value) {
                      _allowRepeat = value;
                      setState(() {});
                    },
                    validator: (value) {
                      if (value == null) {
                        return "Please select repeat option";
                      }
                      return null;
                    },
                    items: _repeatOptions.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                  ),
                  const Gap(20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_campaign?.status == 1 || _campaign?.status == 2)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: _cancelCampaign,
                          label: const Text('Cancel Campaign'),
                          icon: const Icon(
                            Icons.cancel,
                            size: 20,
                          ),
                        ),
                      const Gap(10),
                      ElevatedButton.icon(
                        onPressed:
                            _campaign == null ? _addCampaign : _updateCampaign,
                        label: _campaign == null
                            ? const Text("Add Campaign")
                            : const Text("Update Campaign"),
                        icon: _campaign == null
                            ? const Icon(Icons.add)
                            : const Icon(Icons.update),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _updateCampaign() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    /// Max call time must be greater than 30 seconds
    final callCutTime = int.parse(_maxCallTimeCtrl.text);

    if (callCutTime < 30) {
      QuickAlert.show(
        context: context,
        width: 200,
        type: QuickAlertType.warning,
        text: "Max call time should be greater than 30 sec",
      );
      return;
    }
    context.read<HudProvider>().showProgress();
    final now = DateTime.now();
    final startDateTime = now.copyWith(
      hour: _startTime!.hour,
      minute: _startTime!.minute,
      second: 0,
    );
    final endDateTime = now.copyWith(
      hour: _endTime!.hour,
      minute: _endTime!.minute,
      second: 0,
    );

    final response = await locator<ApiClient>().updateCampaign(
      id: _campaign!.id!,
      name: _nameCtrl.text,
      description: _descriptionCtrl.text,
      maxCallCutTime: callCutTime,
      language: _dtmfLanguage!,
      campaignPriority: int.parse(_campaignPriorityCtrl.text),
      startDate: DateFormat('yyyy-MM-dd')
          .format(DateFormat('dd-MM-yyyy').parse(_startDateCtrl.text)),
      endDate: DateFormat('yyyy-MM-dd')
          .format(DateFormat('dd-MM-yyyy').parse(_endDateCtrl.text)),
      startTime: DateFormat('HH:mm:ss').format(startDateTime),
      endTime: DateFormat('HH:mm:ss').format(endDateTime),
      allowRepeat: _allowRepeat!,
    );

    if (response.isSuccess) {
      _campaign!.name = _nameCtrl.text;
      _campaign!.description = _descriptionCtrl.text;
      _campaign!.callCutTime = callCutTime;
      _campaign!.language = _dtmfLanguage!;
      _campaign!.campaignPriority = int.parse(_campaignPriorityCtrl.text);
      _campaign!.startDate =
          DateFormat('dd-MM-yyyy').parse(_startDateCtrl.text);
      _campaign!.endDate = DateFormat('dd-MM-yyyy').parse(_endDateCtrl.text);
      _campaign!.startTime = DateFormat('HH:mm:ss').format(startDateTime);
      _campaign!.endTime = DateFormat('HH:mm:ss').format(endDateTime);

      // Clear all fields
      _nameCtrl.clear();
      _descriptionCtrl.clear();
      _maxCallTimeCtrl.text = "600";
      _campaignPriorityCtrl.clear();
      _startDateCtrl.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
      _endDateCtrl.text = DateFormat('dd-MM-yyyy').format(
        DateTime(2050, 12, 31),
      );
      _startTime = const TimeOfDay(hour: 9, minute: 0);
      _endTime = const TimeOfDay(hour: 9, minute: 15);
      _dtmfLanguage = null;
      _allowRepeat = null;
      if (mounted) {
        context.pop();
        QuickAlert.show(
          context: context,
          width: 200,
          type: QuickAlertType.success,
          text: response.message,
        );
      }
    } else if (mounted) {
      QuickAlert.show(
        context: context,
        width: 200,
        type: QuickAlertType.error,
        text: response.message,
      );
    }
    context.read<HudProvider>().hideProgress();
  }

  void _addCampaign() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    /// Max call time must be greater than 30 seconds
    final callCutTime = int.parse(_maxCallTimeCtrl.text);

    if (callCutTime < 30) {
      QuickAlert.show(
        context: context,
        width: 200,
        type: QuickAlertType.warning,
        text: "Max call time should be greater than 30 sec",
      );
      return;
    }
    context.read<HudProvider>().showProgress();
    final now = DateTime.now();
    final startDateTime = now.copyWith(
      hour: _startTime!.hour,
      minute: _startTime!.minute,
      second: 0,
    );
    final endDateTime = now.copyWith(
      hour: _endTime!.hour,
      minute: _endTime!.minute,
      second: 0,
    );

    final response = await locator<ApiClient>().addCampaign(
      name: _nameCtrl.text,
      description: _descriptionCtrl.text,
      maxCallCutTime: callCutTime,
      language: _dtmfLanguage!,
      campaignPriority: int.parse(_campaignPriorityCtrl.text),
      startDate: DateFormat('yyyy-MM-dd')
          .format(DateFormat('dd-MM-yyyy').parse(_startDateCtrl.text)),
      endDate: DateFormat('yyyy-MM-dd')
          .format(DateFormat('dd-MM-yyyy').parse(_endDateCtrl.text)),
      startTime: DateFormat('HH:mm:ss').format(startDateTime),
      endTime: DateFormat('HH:mm:ss').format(endDateTime),
      allowRepeat: _allowRepeat!,
    );

    if (response.isSuccess) {
      _nameCtrl.clear();
      _descriptionCtrl.clear();
      _maxCallTimeCtrl.text = "600";
      _campaignPriorityCtrl.clear();
      _startDateCtrl.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
      _endDateCtrl.text =
          DateFormat('dd-MM-yyyy').format(DateTime(2050, 12, 31));
      _startTime = const TimeOfDay(hour: 9, minute: 0);
      _endTime = const TimeOfDay(hour: 9, minute: 15);
      _dtmfLanguage = null;
      _allowRepeat = null;
      setState(() {});
      if (mounted) {
        context.read<HudProvider>().hideProgress();
        QuickAlert.show(
          context: context,
          width: 200,
          type: QuickAlertType.success,
          text: response.message,
        );
        context.go(AppRoutes.dialPlan.path
            .replaceAll(':campaignId', response.data!.id.toString()));
      }
    } else if (mounted) {
      QuickAlert.show(
        context: context,
        width: 200,
        type: QuickAlertType.success,
        text: response.message,
      );
    }
  }

  void _pickStartDate() {
    final initialDate = DateFormat('dd-MM-yyyy').parse(
      _startDateCtrl.text,
    );
    showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    ).then((value) {
      if (value != null) {
        _startDateCtrl.text = DateFormat('dd-MM-yyyy').format(value);
        final endDate = DateFormat('dd-MM-yyyy').parse(
          _endDateCtrl.text,
        );
        if (value.isAfter(endDate)) {
          _endDateCtrl.text = DateFormat('dd-MM-yyyy').format(value);
        }
      }
    });
  }

  void _pickEndDate() {
    final initialDate = DateFormat('dd-MM-yyyy').parse(
      _startDateCtrl.text,
    );
    final endDate = DateFormat('dd-MM-yyyy').parse(
      _endDateCtrl.text,
    );
    showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: initialDate,
      lastDate: DateTime(2050, 12, 31),
    ).then((value) {
      if (value != null) {
        _endDateCtrl.text = DateFormat('dd-MM-yyyy').format(value);
      }
    });
  }

  void _cancelCampaign() async {
    // Show general dialog for user consent that freezing dialplan is irreversible and can not be unfrozen
    final status = await generalDialog(
      context: context,
      useRootNavigator: false,
      content: const Text(
        "Are you sure, You want to cancel the campaign?",
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.pop(false);
          },
          child: const Text("Dismiss"),
        ),
        TextButton(
          onPressed: () {
            context.pop(true);
          },
          child: const Text("Ok"),
        ),
      ],
    );

    if (status == false) {
      return;
    }

    context.read<HudProvider>().showProgress();
    final response = await locator<ApiClient>().updateCampaignStatus(
      campaignId: _campaign!.id!,
      status: 4,
    );
    if (!response.isSuccess) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: response.message,
      );
      return;
    }
    _campaign!.status = 4;
    context.read<HudProvider>().hideProgress();
    context.pop();
  }
}
