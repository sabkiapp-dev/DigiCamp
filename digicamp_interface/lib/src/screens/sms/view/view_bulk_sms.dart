import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:digicamp_interface/injection_container.dart';
import 'package:digicamp_interface/src/config/app_constants.dart';
import 'package:digicamp_interface/src/models/models.dart';
import 'package:digicamp_interface/src/screens/sms/sms.dart';
import 'package:digicamp_interface/src/utils/services/rest_api.dart';

class ViewBulkSmsPage extends StatefulWidget {
  const ViewBulkSmsPage({super.key});

  @override
  State<ViewBulkSmsPage> createState() => _ViewBulkSmsPageState();
}

class _ViewBulkSmsPageState extends State<ViewBulkSmsPage> {
  final DataGridController _dataGridController = DataGridController();
  final TextEditingController _queryCtrl = TextEditingController();
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
    _queryCtrl.dispose();
    _dataGridController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = GoRouterState.of(context).path == AppRoutes.selectAudio.path
        ? '1'
        : null;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            controller: _queryCtrl,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: "Search",
            ),
          ),
        ),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: _queryCtrl,
            builder: (context, value, child) {
              return FutureBuilder<Data<BulkSmsResponse>>(
                future: locator<ApiClient>().bulkSms(
                  query: value.text.isEmpty ? null : value.text,
                  pageSize: _rowsPerPage,
                  status: status,
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
                  final bulkSmsDataSource = BulkSmsDataSource(
                    pageSize: _rowsPerPage,
                    bulkSms: snapshot.data!.data!.data!,
                    query: value.text.isEmpty ? null : value.text,
                    status: status,
                    context: context,
                  );

                  return Column(
                    children: [
                      Expanded(
                        child: SfDataGrid(
                          controller: _dataGridController,
                          allowColumnsResizing: true,
                          columnWidthMode: ColumnWidthMode.auto,
                          allowSorting: true,
                          onCellTap: (details) async {
                            final columnName = details.column.columnName;
                            if (columnName == 'status') {
                              return;
                            }
                            if (columnName != _sortColumn) {
                              _sortColumn = columnName;
                              _isAscending = true;
                            } else if (columnName == _sortColumn) {
                              _isAscending = !_isAscending;
                            }
                            _filter =
                                '$_sortColumn ${_isAscending ? 'asc' : 'desc'}';
                            bulkSmsDataSource.customSort(_filter!);
                          },
                          columns: [
                            GridColumn(
                              columnName: 'id',
                              label: Container(
                                padding: const EdgeInsets.all(16.0),
                                alignment: Alignment.center,
                                child: const Text('Id'),
                              ),
                            ),
                            GridColumn(
                              columnName: 'name',
                              width: 150,
                              label: Container(
                                padding: const EdgeInsets.all(16.0),
                                alignment: Alignment.center,
                                child: const Text('Name'),
                              ),
                            ),
                            GridColumn(
                              columnName: 'description',
                              label: Container(
                                padding: const EdgeInsets.all(16.0),
                                alignment: Alignment.center,
                                child: const Text('Description'),
                              ),
                            ),
                            GridColumn(
                              columnName: 'priority',
                              minimumWidth: 100,
                              allowSorting: false,
                              label: Container(
                                padding: const EdgeInsets.all(16.0),
                                alignment: Alignment.center,
                                child: const Text('Priority'),
                              ),
                            ),
                            GridColumn(
                              columnName: 'start_date',
                              minimumWidth: 150,
                              allowSorting: false,
                              label: Container(
                                padding: const EdgeInsets.all(16.0),
                                alignment: Alignment.center,
                                child: const Text('Start Date'),
                              ),
                            ),
                            GridColumn(
                              columnName: 'end_date',
                              allowSorting: false,
                              minimumWidth: 150,
                              label: Container(
                                padding: const EdgeInsets.all(16.0),
                                alignment: Alignment.center,
                                child: const Text('End Date'),
                              ),
                            ),
                            GridColumn(
                              columnName: 'start_time',
                              minimumWidth: 150,
                              allowSorting: false,
                              label: Container(
                                padding: const EdgeInsets.all(16.0),
                                alignment: Alignment.center,
                                child: const Text('Start Time'),
                              ),
                            ),
                            GridColumn(
                              columnName: 'end_time',
                              allowSorting: false,
                              minimumWidth: 150,
                              label: Container(
                                padding: const EdgeInsets.all(16.0),
                                alignment: Alignment.center,
                                child: const Text('End Time'),
                              ),
                            ),
                            GridColumn(
                              columnName: 'contact_count',
                              allowSorting: false,
                              minimumWidth: 150,
                              label: Container(
                                padding: const EdgeInsets.all(16.0),
                                alignment: Alignment.center,
                                child: const Text('Contact Count'),
                              ),
                            ),
                            GridColumn(
                              columnName: 'template',
                              allowSorting: false,
                              minimumWidth: 150,
                              label: Container(
                                padding: const EdgeInsets.all(16.0),
                                alignment: Alignment.center,
                                child: const Text('Template'),
                              ),
                            ),
                            GridColumn(
                              columnName: 'status',
                              allowSorting: false,
                              minimumWidth: 100,
                              label: Container(
                                padding: const EdgeInsets.all(16.0),
                                alignment: Alignment.center,
                                child: const Text('Status'),
                              ),
                            ),
                            GridColumn(
                              columnName: 'action',
                              allowSorting: false,
                              label: Container(
                                padding: const EdgeInsets.all(16.0),
                                alignment: Alignment.center,
                                child: const Text('Action'),
                              ),
                            ),
                          ],
                          source: bulkSmsDataSource,
                          rowsPerPage: _rowsPerPage,
                        ),
                      ),
                      if (snapshot.data!.data!.totalPages != 0)
                        SfDataPager(
                          pageCount:
                              snapshot.data!.data!.totalPages!.toDouble(),
                          delegate: bulkSmsDataSource,
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
            },
          ),
        ),
      ],
    );
  }
}
