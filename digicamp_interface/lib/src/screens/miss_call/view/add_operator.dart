import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:quickalert/quickalert.dart';
import 'package:digicamp_interface/injection_container.dart';
import 'package:digicamp_interface/src/config/app_constants.dart';
import 'package:digicamp_interface/src/models/models.dart';
import 'package:digicamp_interface/src/utils/services/rest_api.dart';

class AddOperator extends StatefulWidget {
  const AddOperator({super.key});

  @override
  State<AddOperator> createState() => _AddOperatorState();
}

class _AddOperatorState extends State<AddOperator> {
  CampaignModel? _campaign;
  final _campaignCtrl = TextEditingController();
  final _operatorCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _associatedNumberCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  OperatorModel? _operator;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _operator = GoRouterState.of(context).extra as OperatorModel?;
      if (_operator != null) {
        _campaign = _operator!.campaignAssociated!;
        _campaignCtrl.text = _operator!.campaignAssociated!.name!;
        _operatorCtrl.text = _operator!.operator ?? '';
        _descriptionCtrl.text = _operator!.description ?? '';
        _associatedNumberCtrl.text = _operator!.associatedNumber ?? '';
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _campaignCtrl,
            onTap: () async {
              _campaign = await context.push(AppRoutes.selectCampaign.path);
              if (_campaign != null) {
                _campaignCtrl.text = _campaign!.name!;
              }
            },
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Campaign Associated',
              hintText: 'Campaign Associated',
            ),
          ),
          const Gap(10),
          TextFormField(
            controller: _operatorCtrl,
            decoration: const InputDecoration(
              labelText: 'Operator',
              hintText: 'Operator',
            ),
          ),
          const Gap(10),
          TextFormField(
            controller: _descriptionCtrl,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Description',
              contentPadding: EdgeInsets.all(10),
            ),
            maxLines: 5,
          ),
          const Gap(10),
          TextFormField(
            controller: _associatedNumberCtrl,
            decoration: const InputDecoration(
              labelText: 'Associated Number',
              hintText: 'Associated Number',
            ),
          ),
          const Gap(10),
          ElevatedButton(
            onPressed: _operator != null ? _updateOperator : _addOperator,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _addOperator() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final response = await locator<ApiClient>().addOperator(
      campaignAssociated: _campaign!.id!,
      operator: _operatorCtrl.text,
      description: _descriptionCtrl.text,
      associatedNumber: _associatedNumberCtrl.text.isEmpty
          ? null
          : _associatedNumberCtrl.text,
    );
    if (response.isSuccess) {
      _campaign = null;
      _campaignCtrl.clear();
      _operatorCtrl.clear();
      _descriptionCtrl.clear();
      _associatedNumberCtrl.clear();
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        text: response.message,
        width: 200,
      );
      context.go(AppRoutes.allOperators.path);
    } else {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: response.message,
        width: 200,
      );
    }
  }

  void _updateOperator() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final response = await locator<ApiClient>().editOperator(
      campaignAssociated: _campaign!.id!,
      operator: _operatorCtrl.text,
      description: _descriptionCtrl.text,
      associatedNumber: _associatedNumberCtrl.text.isEmpty
          ? null
          : _associatedNumberCtrl.text,
      status: _operator!.status.value,
    );
    if (mounted && response.isSuccess) {
      context.pop();
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        text: response.message,
        width: 200,
      );
    }
  }
}
