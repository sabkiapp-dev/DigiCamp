import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:digicamp_interface/injection_container.dart';
import 'package:digicamp_interface/src/config/app_constants.dart';
import 'package:digicamp_interface/src/models/models.dart';
import 'package:digicamp_interface/src/screens/audios/audios.dart';
import 'package:digicamp_interface/src/utils/services/rest_api.dart';

class ViewAudiosPage extends StatefulWidget {
  const ViewAudiosPage({super.key});

  @override
  State<ViewAudiosPage> createState() => _ViewAudiosPageState();
}

class _ViewAudiosPageState extends State<ViewAudiosPage> {
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
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    super.dispose();
    _queryCtrl.dispose();
    _dataGridController.dispose();
    _audioPlayer.dispose();
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
              return FutureBuilder<Data<AudioResponseModel>>(
                future: locator<ApiClient>().audios(
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
                  final audioDataSource = AudioDataSource(
                    pageSize: _rowsPerPage,
                    audios: snapshot.data!.data!.data!,
                    query: value.text.isEmpty ? null : value.text,
                    context: context,
                    status: status,
                    audioPlayer: _audioPlayer,
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
                            if (columnName == 'audio' ||
                                columnName == 'selection') {
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
                            audioDataSource.customSort(_filter!);
                          },
                          columns: [
                            if (GoRouterState.of(context).path ==
                                AppRoutes.selectAudio.path)
                              GridColumn(
                                columnName: 'selection',
                                allowSorting: false,
                                maximumWidth: 110,
                                allowFiltering: false,
                                label: Container(
                                  padding: const EdgeInsets.all(16.0),
                                  alignment: Alignment.center,
                                  child: const Text('Selection'),
                                ),
                              ),
                            GridColumn(
                              columnName: 'id',
                              minimumWidth: 150,
                              label: Container(
                                padding: const EdgeInsets.all(16.0),
                                alignment: Alignment.center,
                                child: const Text('Id'),
                              ),
                            ),
                            GridColumn(
                              columnName: 'voice_name',
                              minimumWidth: 150,
                              label: Container(
                                padding: const EdgeInsets.all(16.0),
                                alignment: Alignment.center,
                                child: const Text('Name'),
                              ),
                            ),
                            GridColumn(
                              columnName: 'voice_desc',
                              minimumWidth: 150,
                              label: Container(
                                padding: const EdgeInsets.all(16.0),
                                alignment: Alignment.center,
                                child: const Text('Description'),
                              ),
                            ),
                            GridColumn(
                              columnName: 'audio',
                              minimumWidth: 150,
                              allowSorting: false,
                              label: Container(
                                padding: const EdgeInsets.all(16.0),
                                alignment: Alignment.center,
                                child: const Text('Audio'),
                              ),
                            ),
                            if (GoRouterState.of(context).path !=
                                AppRoutes.selectAudio.path)
                              GridColumn(
                                columnName: 'status',
                                minimumWidth: 150,
                                allowSorting: false,
                                label: Container(
                                  padding: const EdgeInsets.all(16.0),
                                  alignment: Alignment.center,
                                  child: const Text('Status'),
                                ),
                              ),
                            GridColumn(
                              columnName: 'action',
                              minimumWidth: 150,
                              allowSorting: false,
                              label: Container(
                                padding: const EdgeInsets.all(16.0),
                                alignment: Alignment.center,
                                child: const Text('Action'),
                              ),
                            )
                          ],
                          source: audioDataSource,
                          rowsPerPage: _rowsPerPage,
                        ),
                      ),
                      if (snapshot.data!.data!.totalPages != 0)
                        SfDataPager(
                          pageCount:
                              snapshot.data!.data!.totalPages!.toDouble(),
                          delegate: audioDataSource,
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
