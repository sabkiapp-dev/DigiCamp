import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:digicamp_interface/injection_container.dart';
import 'package:digicamp_interface/src/commons/general_dialogs.dart';
import 'package:digicamp_interface/src/config/app_constants.dart';
import 'package:digicamp_interface/src/models/models.dart';
import 'package:digicamp_interface/src/utils/services/rest_api.dart';

class BulkSmsDataSource extends DataGridSource {
  BulkSmsDataSource({
    required List<BulkSmsModel> bulkSms,
    this.pageSize = 20,
    this.query,
    this.status,
    required this.context,
  }) {
    buildDataGridRow(bulkSms: bulkSms);
  }

  // Filters
  int page = 1;
  int pageSize;
  String? query;
  String? order;
  String? status;
  BuildContext context;

  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        if (dataGridCell.columnName == 'status') {
          final sms = dataGridCell.value as BulkSmsModel;
          Color statusColor = switch (sms.status.value) {
            0 => Colors.transparent,
            1 => Colors.green,
            2 => Colors.yellow,
            3 => Colors.blue,
            4 => Colors.red,
            5 => Colors.orange,
            _ => Colors.transparent,
          };

          final status = {
            if (sms.status.value == 1) 1: "Running",
            if (sms.status.value == 2 || sms.status.value == 1) 2: "Paused",
            if (sms.status.value == 3) 3: "Completed",
            if (sms.status.value == 4 ||
                sms.status.value == 1 ||
                sms.status.value == 2)
              4: "Cancelled",
          };

          return InkWell(
            onTap: () {
              if (sms.status.value == 3 || sms.status.value == 4) return;
              generalDialog(
                context: context,
                title: const Text("Change Status"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: status.entries.map((status) {
                    return ListTile(
                      title: Text(status.value),
                      onTap: () {
                        _changeStatus(sms, status.key);
                      },
                    );
                  }).toList(),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      context.pop();
                    },
                    child: const Text("Cancel"),
                  ),
                ],
              );
            },
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(16.0),
              color: statusColor,
              child: Text(status[sms.status.value]!),
            ),
          );
        }

        if (dataGridCell.columnName == 'action') {
          final sms = dataGridCell.value as BulkSmsModel;
          return UnconstrainedBox(
            child: IconButton(
              onPressed: () {
                if (sms.status.value != 1) {
                  context.push(AppRoutes.updateBulkSms.path, extra: sms);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Cannot edit a running campaign"),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.edit),
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
    final response = await locator<ApiClient>().bulkSms(
      page: page,
      pageSize: pageSize,
      query: query,
      order: order,
      status: status,
    );
    if (response.isSuccess) {
      buildDataGridRow(bulkSms: response.data!.data!);
      notifyListeners();
    }
    return super.handlePageChange(oldPageIndex, newPageIndex);
  }

  void buildDataGridRow({required List<BulkSmsModel> bulkSms}) {
    dataGridRows = bulkSms.map<DataGridRow>((sms) {
      return DataGridRow(
        cells: [
          DataGridCell<int>(
            columnName: 'id',
            value: sms.id,
          ),
          DataGridCell<String>(
            columnName: 'name',
            value: sms.name,
          ),
          DataGridCell<String>(
            columnName: 'description',
            value: sms.description,
          ),
          DataGridCell<int>(
            columnName: 'priority',
            value: sms.priority,
          ),
          DataGridCell<String>(
            columnName: 'start_date',
            value: DateFormat('dd-MM-yyyy').format(sms.startDate!),
          ),
          DataGridCell<String>(
            columnName: 'end_date',
            value: DateFormat('dd-MM-yyyy').format(sms.endDate!),
          ),
          DataGridCell<String>(
            columnName: 'start_time',
            value: sms.startTime,
          ),
          DataGridCell<String>(
            columnName: 'end_time',
            value: sms.endTime,
          ),
          DataGridCell<int>(
            columnName: 'contact_count',
            value: sms.contactCount,
          ),
          DataGridCell<String>(
            columnName: 'template',
            value: sms.template!.templateName!,
          ),
          DataGridCell<BulkSmsModel>(
            columnName: 'status',
            value: sms,
          ),
          DataGridCell<BulkSmsModel>(
            columnName: 'action',
            value: sms,
          ),
        ],
      );
    }).toList();
  }

  void customSort(String sort) async {
    order = sort;
    final response = await locator<ApiClient>().bulkSms(
      page: page,
      pageSize: pageSize,
      query: query,
      order: order,
      status: status,
    );
    if (response.isSuccess) {
      buildDataGridRow(bulkSms: response.data!.data!);
      notifyListeners();
    }
  }

  void _changeStatus(BulkSmsModel sms, int? currentValue) async {
    final previousValue = sms.status.value;
    sms.status.value = currentValue!;
    final response = await locator<ApiClient>().updateBulkSmsStatus(
      id: sms.id!,
      status: sms.status.value,
    );

    if (!response.isSuccess) {
      sms.status.value = previousValue;
    }
    notifyListeners();
    context.pop();
  }
}
