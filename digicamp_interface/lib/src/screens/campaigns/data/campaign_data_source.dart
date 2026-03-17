import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:digicamp_interface/injection_container.dart';
import 'package:digicamp_interface/src/config/app_constants.dart';
import 'package:digicamp_interface/src/models/models.dart';
import 'package:digicamp_interface/src/utils/services/rest_api.dart';

class CampaignDataSource extends DataGridSource {
  CampaignDataSource({
    required this.context,
    required List<CampaignModel> campaigns,
    this.pageSize = 20,
    this.query,
  }) {
    buildDataGridRow(campaigns: campaigns);
  }

  // Filters
  int page = 1;
  int pageSize;
  String? query;
  String? order;
  BuildContext context;

  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        late Widget child;
        switch (dataGridCell.columnName) {
          case 'allow_repeat':
            String allowRepeat = switch (dataGridCell.value) {
              0 => 'No',
              1 => 'Once',
              2 => 'Twice',
              _ => 'N/A',
            };

            child = Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(16.0),
              child: Text(allowRepeat),
            );
            break;
          case 'status':
            Color statusColor = switch (dataGridCell.value) {
              'Not Created' => Colors.transparent,
              'Running' => Colors.green,
              'Paused' => Colors.yellow,
              'Completed' => Colors.blue,
              'Cancelled' => Colors.red,
              'Dial Plan Freezed' => Colors.orange,
              _ => Colors.transparent,
            };
            child = Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(16.0),
              color: statusColor,
              child: Text(dataGridCell.value),
            );
            break;
          case 'selection':
            final campaign = dataGridCell.value as CampaignModel;
            child = Container(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  context.pop(campaign);
                },
                child: const Text("Select"),
              ),
            );
            break;
          default:
            child = Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(16.0),
              child: Text(dataGridCell.value.toString()),
            );
            break;
        }

        if (GoRouterState.of(context).path == AppRoutes.selectCampaign.path) {
          return child;
        }
        return InkWell(
          onTap: () {
            context.go(
              Uri(
                path: AppRoutes.dialPlan.path.replaceAll(
                  ':campaignId',
                  row
                      .getCells()
                      .firstWhere((element) => element.columnName == 'id')
                      .value
                      .toString(),
                ),
              ).toString(),
            );
          },
          child: child,
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
    final response = await locator<ApiClient>().campaigns(
      page: page,
      pageSize: pageSize,
      query: query,
      order: order,
    );
    if (response.isSuccess) {
      buildDataGridRow(campaigns: response.data!.data!);
      notifyListeners();
    }
    return super.handlePageChange(oldPageIndex, newPageIndex);
  }

  void buildDataGridRow({required List<CampaignModel> campaigns}) {
    dataGridRows = campaigns.map<DataGridRow>((campaign) {
      String statusMessage = switch (campaign.status) {
        0 => 'Not Created',
        1 => 'Running',
        2 => 'Paused',
        3 => 'Completed',
        4 => 'Cancelled',
        5 => 'Dial Plan Freezed',
        _ => 'Unknown'
      };
      return DataGridRow(
        cells: [
          if (GoRouterState.of(context).path == AppRoutes.selectCampaign.path)
            DataGridCell<CampaignModel>(
              columnName: 'selection',
              value: campaign,
            ),
          DataGridCell<int>(
            columnName: 'id',
            value: campaign.id,
          ),
          DataGridCell<String>(
            columnName: 'name',
            value: campaign.name,
          ),
          DataGridCell<String>(
            columnName: 'description',
            value: campaign.description,
          ),
          DataGridCell<int>(
            columnName: 'priority',
            value: campaign.campaignPriority,
          ),
          DataGridCell<String>(
            columnName: 'status',
            value: statusMessage,
          ),
          DataGridCell<String>(
            columnName: 'language',
            value: campaign.language,
          ),
          DataGridCell<int>(
            columnName: 'contacts_count',
            value: campaign.contactCount,
          ),
          DataGridCell<int>(
            columnName: 'allow_repeat',
            value: campaign.allowRepeat,
          ),
          DataGridCell<String>(
            columnName: 'start_date',
            value: DateFormat('dd-MMM-yyyy').format(campaign.startDate!),
          ),
          DataGridCell<String>(
              columnName: 'end_date',
              value: DateFormat('dd-MMM-yyyy').format(campaign.endDate!)),
          DataGridCell<String>(
            columnName: 'start_time',
            value: DateFormat.jm().format(DateTime.parse(
                '${DateFormat('yyyy-MM-dd').format(DateTime.now())} ${campaign.startTime!}')),
          ),
          DataGridCell<String>(
            columnName: 'end_time',
            value: DateFormat.jm().format(DateTime.parse(
                '${DateFormat('yyyy-MM-dd').format(DateTime.now())} ${campaign.endTime!}')),
          ),
          DataGridCell<int>(
            columnName: 'call_cut_time',
            value: campaign.callCutTime,
          ),
        ],
      );
    }).toList();
  }

  void customSort(String sort) async {
    order = sort;
    final response = await locator<ApiClient>().campaigns(
      page: page,
      pageSize: pageSize,
      query: query,
      order: order,
    );
    if (response.isSuccess) {
      buildDataGridRow(campaigns: response.data!.data!);
      notifyListeners();
    }
  }
}
