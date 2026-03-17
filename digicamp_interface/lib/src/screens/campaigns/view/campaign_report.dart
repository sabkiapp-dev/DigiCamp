import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:digicamp_interface/injection_container.dart';
import 'package:digicamp_interface/src/models/models.dart';
import 'package:digicamp_interface/src/screens/campaigns/campaigns.dart';
import 'package:digicamp_interface/src/utils/downloads.dart';
import 'package:digicamp_interface/src/utils/extensions/string_extension.dart';
import 'package:digicamp_interface/src/utils/services/rest_api.dart';

class CampaignReportPage extends StatefulWidget {
  const CampaignReportPage({
    super.key,
    required this.campaignId,
  });
  final int campaignId;
  @override
  State<CampaignReportPage> createState() => _CampaignReportPageState();
}

class _CampaignReportPageState extends State<CampaignReportPage> {
  final _dataGridController = DataGridController();
  int _rowsPerPage = 25;
  final List<int> _availableRowsPerPage = [
    25,
    50,
    100,
    500,
    // 1000,
    // 10000,
    // 100000,
  ];
  bool _isAscending = false;
  String? _sortColumn;
  String? _filter;

  @override
  void dispose() {
    super.dispose();
    _dataGridController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Data<CampaignReportResponseModel>>(
      future: locator<ApiClient>().campaignReport(
        pageSize: _rowsPerPage,
        campaignId: widget.campaignId,
        page: 1,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.data == null || !snapshot.data!.isSuccess) {
          return const Center(
            child: Text('Data not found'),
          );
        }
        final extensions = snapshot.data!.data!.data!
            .map((e) => e.extensions.keys)
            .expand((e) => e)
            .toSet()
            .toList();
        final missCallDataSource = CampaignReportDataSource(
          pageSize: _rowsPerPage,
          campaignId: widget.campaignId,
          reports: snapshot.data!.data!.data!,
          extensions: extensions,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: PopupMenuButton<String>(
                itemBuilder: (context) {
                  return [
                    const PopupMenuItem(
                      value: 'excel',
                      child: Text('Export to Excel'),
                    ),
                    const PopupMenuItem(
                      value: 'csv',
                      child: Text('Export to CSV'),
                    ),
                  ];
                },
                onSelected: (value) async {
                  final response =
                      await locator<ApiClient>().downloadCampaignReport(
                    type: value,
                    campaignId: widget.campaignId,
                  );
                  if (response.isSuccess) {
                    String fileName = 'campaign_report.csv';
                    if (value == 'excel') {
                      fileName = 'campaign_report.xlsx';
                    }
                    download(
                      response.data!,
                      downloadName: fileName,
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Download Report',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SfDataGrid(
                controller: _dataGridController,
                allowColumnsResizing: true,
                columnWidthMode: ColumnWidthMode.auto,
                // allowSorting: true,
                onCellTap: (details) async {
                  final columnName = details.column.columnName;
                  if (columnName != _sortColumn) {
                    _sortColumn = columnName;
                    _isAscending = true;
                  } else if (columnName == _sortColumn) {
                    _isAscending = !_isAscending;
                  }
                  _filter = '$_sortColumn ${_isAscending ? 'asc' : 'desc'}';
                  missCallDataSource.customSort(_filter!);
                },
                columns: [
                  GridColumn(
                    columnName: 'phone_number',
                    width: 150,
                    label: Container(
                      padding: const EdgeInsets.all(16.0),
                      alignment: Alignment.center,
                      child: const Text('Phone Number'),
                    ),
                    allowSorting: false,
                  ),
                  GridColumn(
                    columnName: 'sent_status',
                    minimumWidth: 100,
                    label: Container(
                      padding: const EdgeInsets.all(16.0),
                      alignment: Alignment.center,
                      child: const Text('Sent Status'),
                    ),
                    allowSorting: false,
                  ),
                  GridColumn(
                    columnName: 'name',
                    allowSorting: false,
                    minimumWidth: 200,
                    label: Container(
                      padding: const EdgeInsets.all(16.0),
                      alignment: Alignment.center,
                      child: const Text('Name'),
                    ),
                  ),
                  GridColumn(
                    columnName: 'call_date_time',
                    allowSorting: false,
                    minimumWidth: 150,
                    label: Container(
                      padding: const EdgeInsets.all(16.0),
                      alignment: Alignment.center,
                      child: const Text('Call Date Time'),
                    ),
                  ),
                  GridColumn(
                    columnName: 'calling_number',
                    allowSorting: false,
                    minimumWidth: 150,
                    label: Container(
                      padding: const EdgeInsets.all(16.0),
                      alignment: Alignment.center,
                      child: const Text('Calling Number'),
                    ),
                  ),
                  GridColumn(
                    columnName: 'duration',
                    allowSorting: false,
                    minimumWidth: 100,
                    label: Container(
                      padding: const EdgeInsets.all(16.0),
                      alignment: Alignment.center,
                      child: const Text('Duration'),
                    ),
                  ),
                  ...extensions
                      .map((e) => GridColumn(
                            columnName: e,
                            allowSorting: false,
                            minimumWidth: 100,
                            label: Container(
                              padding: const EdgeInsets.all(16.0),
                              alignment: Alignment.center,
                              child: Text(
                                e.replaceAll('_', ' ').toStudlyCase(),
                              ),
                            ),
                          ))
                      .toList(),
                ],
                source: missCallDataSource,
                rowsPerPage: _rowsPerPage,
              ),
            ),
            if (snapshot.data!.data!.totalPages != 0)
              SfDataPager(
                pageCount: snapshot.data!.data!.totalPages!.toDouble(),
                delegate: missCallDataSource,
                availableRowsPerPage: _availableRowsPerPage,
                onRowsPerPageChanged: (value) {
                  setState(() {
                    _rowsPerPage = value!;
                  });
                },
              ),
          ],
        );
      },
    );
  }
}
