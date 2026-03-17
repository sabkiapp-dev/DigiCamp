import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:digicamp_interface/injection_container.dart';
import 'package:digicamp_interface/src/config/app_constants.dart';
import 'package:digicamp_interface/src/input_formatters/length_limiting_formatter.dart';
import 'package:digicamp_interface/src/models/models.dart';
import 'package:digicamp_interface/src/providers/providers.dart';
import 'package:digicamp_interface/src/utils/services/rest_api.dart';

class AddSmsPage extends StatefulWidget {
  const AddSmsPage({super.key});

  @override
  State<AddSmsPage> createState() => _AddSmsPageState();
}

class _AddSmsPageState extends State<AddSmsPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _templateName = TextEditingController();
  final TextEditingController _smsTemplate = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  SMSTemplateModel? _template;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (GoRouterState.of(context).path == AppRoutes.editSms.path) {
        _template = GoRouterState.of(context).extra as SMSTemplateModel;
        _templateName.text = _template!.templateName!;
        _smsTemplate.text = _template!.template!;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _templateName,
              decoration: const InputDecoration(
                hintText: "Template Name",
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Template name is required";
                }
                return null;
              },
            ),
            const Gap(10),
            TextFormField(
              readOnly: _template != null,
              controller: _smsTemplate,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(10),
                hintText: "Template",
              ),
              inputFormatters: [
                LengthLimitingFormatter(),
              ],
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Template is required";
                }
                return null;
              },
            ),
            const Gap(10),
            if (_template != null)
              ElevatedButton(
                onPressed: _updateSms,
                child: const Text("Update Template"),
              )
            else
              ElevatedButton(
                onPressed: _addSms,
                child: const Text("Add Template"),
              ),
          ],
        ),
      ),
    );
  }

  void _addSms() async {
    if (_formKey.currentState!.validate()) {
      context.read<HudProvider>().showProgress();
      final response = await locator<ApiClient>().addSMSTemplate(
        templateName: _templateName.text,
        template: _smsTemplate.text,
      );

      if (response.isSuccess) {
        _templateName.clear();
        _smsTemplate.clear();
        setState(() {});
      }
      if (mounted) {
        context.read<HudProvider>().hideProgress();
        QuickAlert.show(
          context: context,
          width: 200,
          type: response.isSuccess
              ? QuickAlertType.success
              : QuickAlertType.error,
          title: response.message,
        );
      }
    }
  }

  void _updateSms() async {
    if (_formKey.currentState!.validate()) {
      context.read<HudProvider>().showProgress();
      final response = await locator<ApiClient>().updateSMSTemplate(
        id: _template!.id!,
        name: _templateName.text,
      );
      context.read<HudProvider>().hideProgress();
      if (response.isSuccess) {
        context.pop();
      }
    }
  }
}
