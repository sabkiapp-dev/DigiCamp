import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:digicamp_interface/injection_container.dart';
import 'package:digicamp_interface/src/models/models.dart';
import 'package:digicamp_interface/src/utils/services/rest_api.dart';

class CampaignReportDataSource extends DataGridSource {
  CampaignReportDataSource({
    required List<CallReportModel> reports,
    this.pageSize = 20,
    required this.campaignId,
    required this.extensions,
  }) {
    buildDataGridRow(reports: reports);
  }

  // Filters
  int campaignId;
  int page = 1;
  int pageSize;
  String? order;
  final List<String> extensions;

  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(16.0),
          child: Text(dataGridCell.value?.toString() ?? 'N/A'),
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
    final response = await locator<ApiClient>().campaignReport(
      campaignId: campaignId,
      page: page,
      pageSize: pageSize,
    );
    if (response.isSuccess) {
      buildDataGridRow(reports: response.data!.data!);
      notifyListeners();
    }
    return super.handlePageChange(oldPageIndex, newPageIndex);
  }

  void buildDataGridRow({required List<CallReportModel> reports}) {
    dataGridRows = reports.map<DataGridRow>((report) {
      return DataGridRow(
        cells: [
          DataGridCell<String>(
            columnName: 'phone_number',
            value: report.phoneNumber,
          ),
          DataGridCell<String>(
            columnName: 'sent_status',
            value: report.sentStatus,
          ),
          DataGridCell<String>(
            columnName: 'name',
            value: report.name,
          ),
          DataGridCell<String>(
            columnName: 'call_date_time',
            value: report.sendDatetime,
          ),
          DataGridCell<String>(
            columnName: 'calling_number',
            value: report.callThrough,
          ),
          DataGridCell<int>(
            columnName: 'duration',
            value: report.duration,
          ),
          ...extensions.map<DataGridCell<int>>((key) {
            return DataGridCell<int>(
              columnName: key,
              value: report.extensions[key],
            );
          }).toList(),
        ],
      );
    }).toList();
  }

  void customSort(String sort) async {
    order = sort;
    final response = await locator<ApiClient>().campaignReport(
      page: page,
      pageSize: pageSize,
      campaignId: campaignId,
    );
    if (response.isSuccess) {
      buildDataGridRow(reports: response.data!.data!);
      notifyListeners();
    }
  }
}
