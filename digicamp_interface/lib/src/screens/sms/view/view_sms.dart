import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:digicamp_interface/injection_container.dart';
import 'package:digicamp_interface/src/config/app_constants.dart';
import 'package:digicamp_interface/src/models/models.dart';
import 'package:digicamp_interface/src/screens/sms/sms.dart';
import 'package:digicamp_interface/src/utils/services/rest_api.dart';

class ViewSmsPage extends StatefulWidget {
  const ViewSmsPage({super.key});

  @override
  State<ViewSmsPage> createState() => _ViewSmsPageState();
}

class _ViewSmsPageState extends State<ViewSmsPage> {
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
    final status =
        GoRouterState.of(context).path == AppRoutes.selectSms.path ? '1' : null;
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
              return FutureBuilder<Data<SmsResponseModel>>(
                future: locator<ApiClient>().getSMSTemplates(
                  query: value.text.isEmpty ? null : value.text,
                  pageSize: _rowsPerPage,
                  order: _filter,
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

                  final smsDataSource = SmsDataSource(
                    context: context,
                    pageSize: _rowsPerPage,
                    templates: snapshot.data!.data!.templates!,
                    query: value.text.isEmpty ? null : value.text,
                  );
                  return Column(
                    children: [
                      Expanded(
                        child: SfDataGrid(
                          controller: _dataGridController,
                          selectionMode: SelectionMode.none,
                          allowColumnsResizing: true,
                          columnWidthMode: ColumnWidthMode.auto,
                          allowSorting: true,
                          onCellTap: (details) async {
                            final columnName = details.column.columnName;
                            if (columnName != _sortColumn) {
                              _sortColumn = columnName;
                              _isAscending = true;
                            } else if (columnName == _sortColumn) {
                              _isAscending = !_isAscending;
                            }
                            _filter =
                                '$_sortColumn ${_isAscending ? 'asc' : 'desc'}';
                            smsDataSource.customSort(_filter!);
                          },
                          columns: [
                            if (GoRouterState.of(context).path ==
                                AppRoutes.selectSms.path)
                              GridColumn(
                                columnName: 'selection',
                                minimumWidth: 100,
                                label: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16.0,
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text('Selection'),
                                ),
                              ),
                            GridColumn(
                              columnName: 'id',
                              minimumWidth: 150,
                              label: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                ),
                                alignment: Alignment.center,
                                child: const Text('Id'),
                              ),
                            ),
                            GridColumn(
                              columnName: 'template_name',
                              minimumWidth: 150,
                              label: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                ),
                                alignment: Alignment.center,
                                child: const Text('Template Name'),
                              ),
                            ),
                            GridColumn(
                              columnName: 'template',
                              minimumWidth: 150,
                              label: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                ),
                                alignment: Alignment.center,
                                child: const Text('Template'),
                              ),
                            ),
                            if (GoRouterState.of(context).path !=
                                AppRoutes.selectSms.path)
                              GridColumn(
                                columnName: 'status',
                                maximumWidth: 100,
                                allowSorting: false,
                                label: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16.0,
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text('Status'),
                                ),
                              ),
                            GridColumn(
                              columnName: 'action',
                              allowSorting: false,
                              maximumWidth: 50,
                              label: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                ),
                                alignment: Alignment.center,
                                child: const Text('Action'),
                              ),
                            ),
                          ],
                          source: smsDataSource,
                          rowsPerPage: _rowsPerPage,
                        ),
                      ),
                      if (snapshot.data!.data!.totalPages != 0)
                        SfDataPager(
                          pageCount:
                              snapshot.data!.data!.totalPages!.toDouble(),
                          delegate: smsDataSource,
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
