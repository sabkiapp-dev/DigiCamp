import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';
import 'package:digicamp_interface/injection_container.dart';
import 'package:digicamp_interface/src/config/app_constants.dart';
import 'package:digicamp_interface/src/models/models.dart';
import 'package:digicamp_interface/src/utils/services/rest_api.dart';

class AddBulkSmsPage extends StatefulWidget {
  const AddBulkSmsPage({super.key});

  @override
  State<AddBulkSmsPage> createState() => _AddBulkSmsPageState();
}

class _AddBulkSmsPageState extends State<AddBulkSmsPage> {
  final _nameCtrl = TextEditingController();
  final _description = TextEditingController();
  final _priority = TextEditingController(text: "1");
  SMSTemplateModel? _template;
  final _smsTemplate = TextEditingController();
  final _startDate = TextEditingController();
  final _endDate = TextEditingController();

  final List<DateTime> _startDateRange = [];
  final List<DateTime> _endDateRange = [];
  DateTime? _selectedStartDateTime;
  DateTime? _selectedEndDateTime;
  final _formKey = GlobalKey<FormState>();
  bool _isEditable = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _init();
    });
  }

  void _init() {
    final extra = GoRouterState.of(context).extra;
    _startDate.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    _endDate.text = DateFormat('dd-MM-yyyy').format(DateTime(2050, 12, 31));
    if (extra is BulkSmsModel) {
      final now = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd').format(now);
      _isEditable = false;
      _nameCtrl.text = extra.name!;
      _description.text = extra.description!;
      _priority.text = extra.priority.toString();
      _smsTemplate.text = extra.template!.templateName!;
      _selectedStartDateTime =
          DateTime.parse("$formattedDate ${extra.startTime!}");
      _selectedEndDateTime = DateTime.parse("$formattedDate ${extra.endTime!}");
      _startDate.text = DateFormat('dd-MM-yyyy').format(extra.startDate!);
      _endDate.text = DateFormat('dd-MM-yyyy').format(extra.endDate!);
      _template = extra.template;
    }
    _calculateStartDateRange();
    _calculateEndDateRange();
    setState(() {});
  }

  void _calculateStartDateRange() {
    final now = DateTime.now();
    DateTime start = DateTime(
      now.year,
      now.month,
      now.day,
      7,
      0,
      0,
      0,
    );
    final end = _selectedEndDateTime ??
        DateTime(
          now.year,
          now.month,
          now.day,
          20,
          15,
          0,
          0,
        );
    _startDateRange.clear();
    while (start.isBefore(end)) {
      _startDateRange.add(start);
      start = start.add(const Duration(minutes: 15));
    }
  }

  void _calculateEndDateRange() {
    final now = DateTime.now();
    DateTime start = _selectedStartDateTime?.add(const Duration(minutes: 15)) ??
        DateTime(
          now.year,
          now.month,
          now.day,
          9,
          15,
          0,
          0,
        );

    final end = DateTime(
      now.year,
      now.month,
      now.day,
      21,
      15,
      0,
      0,
    );
    _endDateRange.clear();
    while (start.isBefore(end)) {
      _endDateRange.add(start);
      start = start.add(const Duration(minutes: 15));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Campaign Name',
            ),
            validator: (value) {
              return value != null && value.isNotEmpty
                  ? null
                  : 'Invalid campaign name';
            },
          ),
          const Gap(10),
          TextFormField(
            controller: _description,
            decoration: const InputDecoration(
              labelText: 'Campaign Description',
            ),
            validator: (value) {
              return value != null && value.isNotEmpty
                  ? null
                  : 'Invalid campaign description';
            },
          ),
          const Gap(10),
          TextFormField(
            controller: _priority,
            decoration: const InputDecoration(
              labelText: 'Priority (Higher will be called first)',
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            validator: (value) {
              return value != null && value.isNotEmpty
                  ? null
                  : 'Invalid campaign priority';
            },
          ),
          const Gap(10),
          TextFormField(
            controller: _smsTemplate,
            onTap: () async {
              _template = await context
                  .push<SMSTemplateModel>(AppRoutes.selectSms.path);
              if (_template != null) {
                _smsTemplate.text = _template!.templateName!;
                setState(() {});
              }
            },
            decoration: const InputDecoration(
              labelText: 'Select SMS Template',
            ),
            readOnly: true,
            validator: (value) {
              return _template != null ? null : 'Please select sms template';
            },
          ),
          const Gap(10),
          const Text('Campaign Schedule Time(For Each Day):'),
          const Gap(5),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _startDate,
                  decoration: const InputDecoration(
                    labelText: 'Start Date',
                  ),
                  readOnly: true,
                  onTap: _pickStartDate,
                  validator: (value) {
                    return value != null && value.isNotEmpty
                        ? null
                        : 'Please select start date';
                  },
                ),
              ),
              const Gap(10),
              Expanded(
                child: TextFormField(
                  controller: _endDate,
                  decoration: const InputDecoration(
                    labelText: 'End Date',
                  ),
                  readOnly: true,
                  onTap: _pickEndDate,
                  validator: (value) {
                    return value != null && value.isNotEmpty
                        ? null
                        : 'Please select end date';
                  },
                ),
              ),
            ],
          ),
          const Gap(10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<DateTime>(
                  items: _startDateRange.map((dateTime) {
                    return DropdownMenuItem<DateTime>(
                      value: dateTime,
                      child: Text(DateFormat.jm().format(dateTime)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (_selectedEndDateTime != null &&
                        _selectedEndDateTime!.isBefore(value!)) {
                      _selectedEndDateTime = null;
                    }
                    _selectedStartDateTime = value;
                    _calculateEndDateRange();
                    setState(() {});
                  },
                  value: _selectedStartDateTime,
                  decoration: const InputDecoration(
                    labelText: 'Start Time',
                  ),
                  validator: (value) {
                    return _selectedStartDateTime != null
                        ? null
                        : 'Please select start time';
                  },
                ),
              ),
              const Gap(10),
              Expanded(
                child: DropdownButtonFormField<DateTime>(
                  items: _endDateRange.map((dateTime) {
                    return DropdownMenuItem<DateTime>(
                      value: dateTime,
                      child: Text(DateFormat.jm().format(dateTime)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (_selectedStartDateTime != null &&
                        _selectedStartDateTime!.isAfter(value!)) {
                      _selectedStartDateTime = null;
                    }

                    _selectedEndDateTime = value;
                    _calculateStartDateRange();
                    setState(() {});
                  },
                  value: _selectedEndDateTime,
                  decoration: const InputDecoration(
                    labelText: 'End Time',
                  ),
                  validator: (value) {
                    return _selectedEndDateTime != null
                        ? null
                        : 'Please select end time';
                  },
                ),
              ),
            ],
          ),
          const Gap(10),
          ElevatedButton(
            onPressed: _isEditable ? _saveSmsCampaign : _updateSmsCampaign,
            child: Text(_isEditable ? 'Save' : 'Update'),
          )
        ],
      ),
    );
  }

  void _saveSmsCampaign() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final startDate = DateFormat('dd-MM-yyyy').parse(_startDate.text);
    final endDate = DateFormat('dd-MM-yyyy').parse(_startDate.text);
    final response = await locator<ApiClient>().addSmsCampaign(
      name: _nameCtrl.text,
      description: _description.text,
      priority: int.parse(_priority.text),
      startTime: DateFormat('HH:mm:ss').format(_selectedStartDateTime!),
      endTime: DateFormat('HH:mm:ss').format(_selectedEndDateTime!),
      startDate: DateFormat('yyyy-MM-dd').format(startDate),
      endDate: DateFormat('yyyy-MM-dd').format(endDate),
      templateId: _template!.id!,
    );
    if (response.isSuccess) {
      _nameCtrl.clear();
      _description.clear();
      _priority.text = "1";
      _smsTemplate.clear();
      _template = null;
      _selectedStartDateTime = null;
      _selectedEndDateTime = null;
      setState(() {});
    }
    if (mounted) {
      QuickAlert.show(
        context: context,
        width: 200,
        type:
            response.isSuccess ? QuickAlertType.success : QuickAlertType.error,
        text: response.message,
      );
    }
  }

  void _updateSmsCampaign() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final startDate = DateFormat('dd-MM-yyyy').parse(_startDate.text);
    final endDate = DateFormat('dd-MM-yyyy').parse(_startDate.text);
    final response = await locator<ApiClient>().updateSmsCampaign(
      id: (GoRouterState.of(context).extra as BulkSmsModel).id!,
      name: _nameCtrl.text,
      description: _description.text,
      priority: int.parse(_priority.text),
      startTime: DateFormat('HH:mm:ss').format(_selectedStartDateTime!),
      endTime: DateFormat('HH:mm:ss').format(_selectedEndDateTime!),
      startDate: DateFormat('yyyy-MM-dd').format(startDate),
      endDate: DateFormat('yyyy-MM-dd').format(endDate),
      templateId: _template!.id!,
    );

    if (response.isSuccess && mounted) {
      context.pop();
      QuickAlert.show(
        context: context,
        width: 200,
        type: QuickAlertType.success,
        text: response.message,
      );
    } else if (mounted) {
      QuickAlert.show(
        context: context,
        width: 200,
        type: QuickAlertType.error,
        text: response.message,
      );
    }
  }

  void _pickStartDate() {
    final initialDate = DateFormat('dd-MM-yyyy').parse(
      _startDate.text,
    );
    showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: initialDate,
      lastDate: initialDate.add(const Duration(days: 30)),
    ).then((value) {
      if (value != null) {
        _startDate.text = DateFormat('dd-MM-yyyy').format(value);
        _endDate.text = DateFormat('dd-MM-yyyy').format(value);
      }
    });
  }

  void _pickEndDate() {
    final initialDate = DateFormat('dd-MM-yyyy').parse(
      _startDate.text,
    );
    showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: initialDate,
      lastDate: DateTime(2050, 12, 31),
    ).then((value) {
      if (value != null) {
        _endDate.text = DateFormat('dd-MM-yyyy').format(value);
      }
    });
  }
}
