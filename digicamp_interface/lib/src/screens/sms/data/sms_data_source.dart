import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:digicamp_interface/injection_container.dart';
import 'package:digicamp_interface/src/config/app_constants.dart';
import 'package:digicamp_interface/src/models/models.dart';
import 'package:digicamp_interface/src/utils/services/rest_api.dart';

class SmsDataSource extends DataGridSource {
  SmsDataSource({
    required List<SMSTemplateModel> templates,
    required this.context,
    this.pageSize = 20,
    this.query,
    this.status,
  }) {
    buildDataGridRow(templates: templates);
  }

  // Filters
  int page = 1;
  int pageSize;
  String? query;
  String? order;
  BuildContext context;
  String? status;

  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        if (dataGridCell.columnName == 'action') {
          final template = dataGridCell.value as SMSTemplateModel;
          return UnconstrainedBox(
            child: IconButton(
              onPressed: () async {
                await context.push(AppRoutes.editSms.path, extra: template);
                notifyListeners();
              },
              icon: const Icon(Icons.edit),
            ),
          );
        }
        if (dataGridCell.columnName == 'status') {
          final template = dataGridCell.value as SMSTemplateModel;
          return ValueListenableBuilder(
            valueListenable: template.status,
            builder: (context, value, child) {
              return CupertinoSwitch(
                value: value == 1,
                onChanged: (value) => _changeStatus(template),
              );
            },
          );
        }
        if (dataGridCell.columnName == 'selection') {
          final template = dataGridCell.value as SMSTemplateModel;
          return UnconstrainedBox(
            child: ElevatedButton(
              onPressed: () {
                context.pop(template);
              },
              child: const Text("Select"),
            ),
          );
        }
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(16.0),
          child: Text(dataGridCell.value.toString()),
        );
      }).toList(),
    );
  }

  @override
  Future<bool> handlePageChange(int oldPageIndex, int newPageIndex) async {
    if (oldPageIndex == newPageIndex) {
      return super.handlePageChange(oldPageIndex, newPageIndex);
    }
    page = newPageIndex + 1;
    final response = await locator<ApiClient>().getSMSTemplates(
      page: page,
      pageSize: pageSize,
      query: query,
      order: order,
      status: status,
    );
    if (response.isSuccess) {
      buildDataGridRow(templates: response.data!.templates!);
      notifyListeners();
    }
    return super.handlePageChange(oldPageIndex, newPageIndex);
  }

  void buildDataGridRow({required List<SMSTemplateModel> templates}) {
    dataGridRows = templates.map<DataGridRow>((template) {
      return DataGridRow(
        cells: [
          if (GoRouterState.of(context).path == AppRoutes.selectSms.path)
            DataGridCell<SMSTemplateModel>(
              columnName: 'selection',
              value: template,
            ),
          DataGridCell<int>(
            columnName: 'id',
            value: template.id,
          ),
          DataGridCell<String>(
            columnName: 'template_name',
            value: template.templateName,
          ),
          DataGridCell<String>(
            columnName: 'template',
            value: template.template,
          ),
          if (GoRouterState.of(context).path != AppRoutes.selectSms.path)
            DataGridCell<SMSTemplateModel>(
              columnName: 'status',
              value: template,
            ),
          DataGridCell<SMSTemplateModel>(
            columnName: 'action',
            value: template,
          ),
        ],
      );
    }).toList();
  }

  void customSort(String sort) async {
    order = sort;
    final response = await locator<ApiClient>().getSMSTemplates(
      page: page,
      pageSize: pageSize,
      query: query,
      order: order,
      status: status,
    );
    if (response.isSuccess) {
      buildDataGridRow(templates: response.data!.templates!);
      notifyListeners();
    }
  }

  void _changeStatus(SMSTemplateModel template) async {
    final previousValue = template.status.value;
    template.status.value = template.status.value == 0 ? 1 : 0;
    final response = await locator<ApiClient>().updateSMSTemplateStatus(
      templateId: template.id!,
      status: template.status.value,
    );

    if (!response.isSuccess) {
      template.status.value = previousValue;
    }
  }
}
