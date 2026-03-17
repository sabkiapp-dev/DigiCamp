import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:digicamp_interface/injection_container.dart';
import 'package:digicamp_interface/src/config/app_constants.dart';
import 'package:digicamp_interface/src/models/models.dart';
import 'package:digicamp_interface/src/screens/campaigns/campaigns.dart';
import 'package:digicamp_interface/src/utils/services/rest_api.dart';

class ViewCampaigns extends StatefulWidget {
  const ViewCampaigns({super.key});

  @override
  State<ViewCampaigns> createState() => _ViewCampaignsState();
}

class _ViewCampaignsState extends State<ViewCampaigns> {
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

  final ValueNotifier<bool?> _isAscending = ValueNotifier(null);
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
              return FutureBuilder<Data<CampaignResponse>>(
                future: locator<ApiClient>().campaigns(
                  query: value.text.isEmpty ? null : value.text,
                  pageSize: _rowsPerPage,
                  order: _filter,
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

                  final campaignDataSource = CampaignDataSource(
                    context: context,
                    pageSize: _rowsPerPage,
                    campaigns: snapshot.data!.data!.data!,
                    query: value.text.isEmpty ? null : value.text,
                  );
                  return Column(
                    children: [
                      Expanded(
                        child: SfDataGrid(
                          isScrollbarAlwaysShown: true,
                          controller: _dataGridController,
                          // allowPullToRefresh: true,
                          // showCheckboxColumn: true,
                          selectionMode: SelectionMode.none,
                          allowColumnsResizing: true,
                          columnWidthMode: ColumnWidthMode.auto,
                          // allowSorting: true,
                          onCellTap: (details) async {
                            final columnName = details.column.columnName;
                            if (columnName != _sortColumn) {
                              _sortColumn = columnName;
                              _isAscending.value = null;
                              _isAscending.value = true;
                            } else if (columnName == _sortColumn) {
                              _isAscending.value = !_isAscending.value!;
                            }
                            _filter =
                                '$_sortColumn ${_isAscending.value! ? 'asc' : 'desc'}';
                            campaignDataSource.customSort(_filter!);
                          },

                          columns: [
                            if (GoRouterState.of(context).path ==
                                AppRoutes.selectCampaign.path)
                              GridColumn(
                                columnName: 'selection',
                                label: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16.0,
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text('Selection'),
                                ),
                              ),
                            _gridColumn(
                              columnName: 'Id',
                              columnKey: 'id',
                            ),
                            _gridColumn(
                              columnName: 'Name',
                              columnKey: 'name',
                            ),
                            _gridColumn(
                              columnName: 'Description',
                              columnKey: 'description',
                            ),
                            _gridColumn(
                              columnName: 'Priority',
                              columnKey: 'priority',
                            ),
                            _gridColumn(
                              columnName: 'Status',
                              columnKey: 'status',
                            ),
                            _gridColumn(
                              columnName: 'Language',
                              columnKey: 'language',
                            ),
                            _gridColumn(
                              columnName: 'Contact Count',
                              columnKey: 'contacts_count',
                            ),
                            _gridColumn(
                              columnName: 'Allow Repeat',
                              columnKey: 'allow_repeat',
                            ),
                            _gridColumn(
                              columnName: 'Start Date',
                              columnKey: 'start_date',
                            ),
                            _gridColumn(
                              columnName: 'End Date',
                              columnKey: 'end_date',
                            ),
                            _gridColumn(
                              columnName: 'Start Time',
                              columnKey: 'start_time',
                            ),
                            _gridColumn(
                              columnName: 'End Time',
                              columnKey: 'end_time',
                            ),
                            _gridColumn(
                              columnName: 'Max Call Time',
                              columnKey: 'call_cut_time',
                            ),
                          ],
                          source: campaignDataSource,
                          rowsPerPage: _rowsPerPage,
                        ),
                      ),
                      if (snapshot.data!.data!.totalPages != 0)
                        SfDataPager(
                          pageCount:
                              snapshot.data!.data!.totalPages!.toDouble(),
                          delegate: campaignDataSource,
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

  GridColumn _gridColumn({
    required String columnName,
    required String columnKey,
  }) {
    return GridColumn(
      columnName: columnKey,
      label: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 16.0,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(columnName),
            const Gap(5),
            ValueListenableBuilder(
              valueListenable: _isAscending,
              builder: (context, value, child) {
                if (_sortColumn == columnKey) {
                  if (value == true) {
                    return const Icon(
                      Icons.arrow_upward,
                      size: 18,
                    );
                  } else {
                    return const Icon(
                      Icons.arrow_downward,
                      size: 18,
                    );
                  }
                } else {
                  return const Icon(
                    IconData(
                      0xe700,
                      fontFamily: 'UnsortIcon',
                      fontPackage: 'syncfusion_flutter_datagrid',
                    ),
                    size: 18.0,
                    // color: iconColor,
                    key: ValueKey<String>('datagrid_filtering_id_filterIcon'),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
