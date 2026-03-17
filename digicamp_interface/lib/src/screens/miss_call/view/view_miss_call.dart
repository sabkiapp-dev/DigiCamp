import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:digicamp_interface/injection_container.dart';
import 'package:digicamp_interface/src/models/models.dart';
import 'package:digicamp_interface/src/screens/miss_call/miss_call.dart';
import 'package:digicamp_interface/src/utils/services/rest_api.dart';

class ViewMissCallPage extends StatefulWidget {
  const ViewMissCallPage({super.key});

  @override
  State<ViewMissCallPage> createState() => _ViewMissCallPageState();
}

class _ViewMissCallPageState extends State<ViewMissCallPage> {
  final DataGridController _dataGridController = DataGridController();
  int _rowsPerPage = 25;
  final _operatorsFuture = locator<ApiClient>().operators();
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
  String _operator = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _operator = GoRouterState.of(context).extra as String? ?? 'All';
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _dataGridController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
          ),
          child: Row(
            children: [
              Text(
                'Select Operator:',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Gap(5),
              FutureBuilder<Data<List<OperatorModel>>>(
                future: _operatorsFuture,
                builder: (context, snapshot) {
                  final operators = [
                    'All',
                    ...snapshot.data?.data?.map((e) => e.operator).toList() ??
                        <String>[]
                  ];

                  if (!operators.contains(_operator)) {
                    operators.add(_operator);
                  }
                  return DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      value: _operator,
                      onChanged: (String? value) {
                        _operator = value!;
                        setState(() {});
                      },
                      hint: const Text('Select Operator'),
                      items: operators
                          .map<DropdownMenuItem<String>>((String? operator) {
                        return DropdownMenuItem<String>(
                          value: operator,
                          child: Text(operator!),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
              const Spacer(),
              // Popup menu button for excel/csv
              PopupMenuButton<String>(
                onSelected: (String value) async {
                  // final response = await locator<ApiClient>().exportMissCalls(
                  //   operator: operator,
                  //   sort: _filter,
                  // );
                  // if (response.isSuccess) {
                  //   final url = response.data!.data!.url;
                  //   if (value == 'excel') {
                  //     locator<ApiClient>().downloadFile(url, 'miss_call.xlsx');
                  //   } else if (value == 'csv') {
                  //     locator<ApiClient>().downloadFile(url, 'miss_call.csv');
                  //   }
                  // }
                },
                itemBuilder: (BuildContext context) {
                  return <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'excel',
                      child: Text('Export to Excel'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'csv',
                      child: Text('Export to CSV'),
                    ),
                  ];
                },
                child: const Icon(Icons.download),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<Data<MissCallResponseModel>>(
            future: locator<ApiClient>().viewMissCalls(
              pageSize: _rowsPerPage,
              sort: _filter,
              operator: _operator == 'All' ? null : _operator,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.data == null || !snapshot.data!.isSuccess) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }
              final missCallDataSource = MissCallDataSource(
                pageSize: _rowsPerPage,
                missCalls: snapshot.data!.data!.data!,
                operator: _operator == 'All' ? null : _operator,
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
                        if (columnName != 'id') {
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
                        missCallDataSource.customSort(_filter!);
                      },
                      columns: [
                        GridColumn(
                          columnName: 'id',
                          minimumWidth: 100,
                          label: Container(
                            padding: const EdgeInsets.all(16.0),
                            alignment: Alignment.center,
                            child: const Text('Sr. No.'),
                          ),
                        ),
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
                          columnName: 'datetime',
                          minimumWidth: 100,
                          label: Container(
                            padding: const EdgeInsets.all(16.0),
                            alignment: Alignment.center,
                            child: const Text('Date Time'),
                          ),
                          allowSorting: false,
                        ),
                        GridColumn(
                          columnName: 'campaign',
                          allowSorting: false,
                          minimumWidth: 100,
                          label: Container(
                            padding: const EdgeInsets.all(16.0),
                            alignment: Alignment.center,
                            child: const Text('Campaign'),
                          ),
                        ),
                        GridColumn(
                          columnName: 'operator',
                          allowSorting: false,
                          minimumWidth: 100,
                          label: Container(
                            padding: const EdgeInsets.all(16.0),
                            alignment: Alignment.center,
                            child: const Text('Operator'),
                          ),
                        ),
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
          ),
        ),
      ],
    );
  }
}
