import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:digicamp_interface/injection_container.dart';
import 'package:digicamp_interface/src/models/models.dart';
import 'package:digicamp_interface/src/utils/services/rest_api.dart';

class MissCallDataSource extends DataGridSource {
  MissCallDataSource({
    required List<MissCallModel> missCalls,
    this.pageSize = 20,
    required this.operator,
  }) {
    buildDataGridRow(missCalls: missCalls);
  }

  // Filters
  int page = 1;
  int pageSize;
  String? order;
  final String? operator;

  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        if (dataGridCell.columnName == 'datetime') {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(16.0),
            child: Text(
              dataGridCell.value != null
                  ? DateFormat('yyyy-MM-dd HH:mm:ss').format(dataGridCell.value)
                  : 'N/A',
            ),
          );
        }
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
    final response = await locator<ApiClient>().viewMissCalls(
      page: page,
      pageSize: pageSize,
      sort: order,
      operator: operator,
    );
    if (response.isSuccess) {
      buildDataGridRow(missCalls: response.data!.data!);
      notifyListeners();
    }
    return super.handlePageChange(oldPageIndex, newPageIndex);
  }

  void buildDataGridRow({required List<MissCallModel> missCalls}) {
    dataGridRows = missCalls.map<DataGridRow>((missCall) {
      return DataGridRow(
        cells: [
          DataGridCell<int>(
            columnName: 'id',
            value: missCall.id,
          ),
          DataGridCell<String>(
            columnName: 'phone_number',
            value: missCall.phoneNumber,
          ),
          DataGridCell<DateTime>(
            columnName: 'datetime',
            value: missCall.datetime,
          ),
          DataGridCell<int>(
            columnName: 'campaign',
            value: missCall.campaign,
          ),
          DataGridCell<String>(
            columnName: 'operator',
            value: missCall.operator,
          ),
        ],
      );
    }).toList();
  }

  void customSort(String sort) async {
    order = sort;
    final response = await locator<ApiClient>().viewMissCalls(
      page: page,
      pageSize: pageSize,
      sort: order,
      operator: operator,
    );
    if (response.isSuccess) {
      buildDataGridRow(missCalls: response.data!.data!);
      notifyListeners();
    }
  }
}
