import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart' hide Data;
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:quickalert/quickalert.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:digicamp_interface/injection_container.dart';
import 'package:digicamp_interface/src/models/models.dart';
import 'package:digicamp_interface/src/screens/view_contacts/view_contacts.dart';
import 'package:digicamp_interface/src/utils/downloads.dart';
import 'package:digicamp_interface/src/utils/extensions/size_extension.dart';
import 'package:digicamp_interface/src/utils/services/rest_api.dart';

class ViewContacts extends StatefulWidget {
  const ViewContacts({super.key});

  @override
  State<ViewContacts> createState() => _ViewContactsState();
}

class _ViewContactsState extends State<ViewContacts> {
  final DataGridController _dataGridController = DataGridController();
  String? _query;
  final List<String> _cat1Filter = [];
  final List<String> _cat2Filter = [];
  final List<String> _cat3Filter = [];
  final List<String> _cat4Filter = [];
  final List<String> _cat5Filter = [];
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

  @override
  void initState() {
    super.initState();
    // _dataGridController.addListener(() {
    //   _dataGridController.selectedRows = _selectedRows;
    //   _dataGridController.notifyListeners();
    // });
  }

  @override
  void dispose() {
    super.dispose();
    _dataGridController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Data<ContactsResponse>>(
      future: locator<ApiClient>().contacts(
        query: _query,
        pageSize: _rowsPerPage,
        category1: _cat1Filter,
        category2: _cat2Filter,
        category3: _cat3Filter,
        category4: _cat4Filter,
        category5: _cat5Filter,
      ),
      builder: (context, snapshot) {
        late ContactsDataSource contactsDataSource;

        if (snapshot.connectionState == ConnectionState.done) {
          contactsDataSource = ContactsDataSource(
            context: context,
            pageSize: _rowsPerPage,
            contacts: snapshot.data!.data!.results!,
            query: _query,
            cat1Filter: _cat1Filter,
            cat2Filter: _cat2Filter,
            cat3Filter: _cat3Filter,
            cat4Filter: _cat4Filter,
            cat5Filter: _cat5Filter,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      onChanged: (value) {
                        setState(() {
                          _query = value;
                        });
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText:
                            "Search from ${snapshot.data?.data?.count ?? 0} contacts",
                      ),
                    ),
                  ),
                  const Gap(10),
                  IconButton(
                    onPressed: _filter,
                    icon: const Icon(Icons.sort),
                  ),
                  const Gap(10),
                  IconButton(
                    onPressed: _categoryContactsDelete,
                    icon: const Icon(Icons.delete),
                    tooltip: "Delete selected",
                  ),
                  const Gap(10),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.download),
                    tooltip: "Export all contact",
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    // onSelected: _export,
                    onSelected: _export,
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: "csv",
                        height: 30,
                        child: Text("Export CSV"),
                      ),
                      const PopupMenuItem(
                        value: "xlsx",
                        height: 30,
                        child: Text("Export EXCEL"),
                      ),
                      const PopupMenuItem(
                        value: "sample_excel",
                        height: 30,
                        child: Text("Export Sample EXCEL"),
                      ),
                      const PopupMenuItem(
                        value: "sample_csv",
                        height: 30,
                        child: Text("Export Sample CSV"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (snapshot.data == null || !snapshot.data!.isSuccess)
              const Center(
                child: Text('Data not found'),
              )
            else
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: SfDataGrid(
                        controller: _dataGridController,
                        // allowPullToRefresh: true,
                        // showCheckboxColumn: true,
                        // selectionMode: SelectionMode.multiple,
                        allowColumnsResizing: true,
                        columnWidthMode: ColumnWidthMode.auto,
                        columns: [
                          GridColumn(
                            columnName: 'name',
                            minimumWidth: 100,
                            label: Container(
                              padding: const EdgeInsets.all(16.0),
                              alignment: Alignment.center,
                              child: const Text('Name'),
                            ),
                          ),
                          GridColumn(
                            columnName: 'phone_number',
                            minimumWidth: 100,
                            label: Container(
                              padding: const EdgeInsets.all(16.0),
                              alignment: Alignment.center,
                              child: const Text('Phone'),
                            ),
                          ),
                          GridColumn(
                            columnName: 'category_1',
                            minimumWidth: 100,
                            label: Container(
                              padding: const EdgeInsets.all(16.0),
                              alignment: Alignment.center,
                              child: const Text('Category 1'),
                            ),
                          ),
                          GridColumn(
                            columnName: 'category_2',
                            minimumWidth: 100,
                            label: Container(
                              padding: const EdgeInsets.all(16.0),
                              alignment: Alignment.center,
                              child: const Text('Category 2'),
                            ),
                          ),
                          GridColumn(
                            columnName: 'category_3',
                            minimumWidth: 100,
                            label: Container(
                              padding: const EdgeInsets.all(16.0),
                              alignment: Alignment.center,
                              child: const Text('Category 3'),
                            ),
                          ),
                          GridColumn(
                            columnName: 'category_4',
                            minimumWidth: 100,
                            label: Container(
                              padding: const EdgeInsets.all(16.0),
                              alignment: Alignment.center,
                              child: const Text('Category 4'),
                            ),
                          ),
                          GridColumn(
                            columnName: 'category_5',
                            minimumWidth: 100,
                            label: Container(
                              padding: const EdgeInsets.all(16.0),
                              alignment: Alignment.center,
                              child: const Text('Category 5'),
                            ),
                          ),
                          GridColumn(
                            columnName: 'action',
                            minimumWidth: 100,
                            label: Container(
                              padding: const EdgeInsets.all(16.0),
                              alignment: Alignment.center,
                              child: const Text('Action'),
                            ),
                          ),
                        ],
                        source: contactsDataSource,
                        rowsPerPage: _rowsPerPage,
                      ),
                    ),
                    if (snapshot.data!.data!.count != 0)
                      SfDataPager(
                        pageCount: _pageCount(
                          snapshot.data!.data!.count!,
                        ),
                        delegate: contactsDataSource,
                        availableRowsPerPage: _availableRowsPerPage,
                        onRowsPerPageChanged: (value) {
                          setState(() {
                            _rowsPerPage = value!;
                          });
                        },
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  void _export(String type) async {
    final cols = [
      "Name",
      "Phone Number",
      "Category 1",
      "Category 2",
      "Category 3",
      "Category 4",
      "Category 5",
    ];

    final sampleValues = [
      [
        "Gaurav",
        "8012345678",
        "Apple",
        "Banana",
        "Cherry",
        "Donut",
        "Eclair",
      ],
      [
        "Ravi",
        "8012345678",
        "Apple",
      ],
      [
        "Gopal",
        "8012345678",
        "Apple",
        "Banana",
        "Cherry",
      ],
    ];

    if (type == "sample_excel") {
      final excel = Excel.createExcel();
      final sheet = excel["Sheet1"];

      sheet.insertRowIterables(cols, 0);
      int rowIndex = 1;

      for (final value in sampleValues) {
        sheet.insertRowIterables(value, rowIndex);
        rowIndex++;
      }
      excel.save(fileName: "sample_contacts.xlsx");
      return;
    } else if (type == "sample_csv") {
      const lst = ListToCsvConverter(fieldDelimiter: ",");
      final csvValue = [
        cols,
        ...sampleValues,
      ];
      download(
        utf8.encode(lst.convert(csvValue)),
        downloadName: "contacts.csv",
      );
      return;
    }

    final cat1Filter = <String>[];
    final cat2Filter = <String>[];
    final cat3Filter = <String>[];
    final cat4Filter = <String>[];
    final cat5Filter = <String>[];
    // Show filter option to select categories
    await showModalBottomSheet(
      context: context,
      isDismissible: true,
      constraints: BoxConstraints(
        maxWidth: context.sw() - 20,
        minWidth: context.sw() - 20,
      ),
      builder: (context) {
        return ContactsFilter(
          cat1Filter: cat1Filter,
          cat2Filter: cat2Filter,
          cat3Filter: cat3Filter,
          cat4Filter: cat4Filter,
          cat5Filter: cat5Filter,
          setState: (_) {},
          confirmText: "Confirm",
          cancelText: "Cancel",
        );
      },
    );

    if (cat1Filter.isEmpty &&
        cat2Filter.isEmpty &&
        cat3Filter.isEmpty &&
        cat4Filter.isEmpty &&
        cat5Filter.isEmpty) {
      QuickAlert.show(
        context: context,
        width: 200,
        type: QuickAlertType.warning,
        text: "Please select at least one category",
      );
      return;
    }

    final response = await locator<ApiClient>().contacts(
      category1: cat1Filter,
      category2: cat2Filter,
      category3: cat3Filter,
      category4: cat4Filter,
      category5: cat5Filter,
      pageSize: 1000000,
    );

    if (!response.isSuccess) {
      QuickAlert.show(
        context: context,
        width: 200,
        type: QuickAlertType.error,
        text: response.message,
      );
      return;
    }

    final values = response.data!.results!.map((row) {
      return [
        row.name,
        row.phoneNumber,
        row.category1,
        row.category2,
        row.category3,
        row.category4,
        row.category5,
      ];
    }).toList();

    switch (type) {
      case "csv":
        const lst = ListToCsvConverter(fieldDelimiter: ",");
        final csvValue = [
          cols,
          ...values,
        ];
        download(
          utf8.encode(lst.convert(csvValue)),
          downloadName: "contacts.csv",
        );
        break;
      case "xlsx":
        final excel = Excel.createExcel();
        final sheet = excel["Sheet1"];

        sheet.insertRowIterables(cols, 0);
        int rowIndex = 1;

        for (final value in values) {
          sheet.insertRowIterables(value, rowIndex);
          rowIndex++;
        }
        excel.save(fileName: "contacts.xlsx");
        break;
    }
  }

  double _pageCount(int size) {
    final rem = size % _rowsPerPage > 0 ? 1 : 0;
    final div = size ~/ _rowsPerPage;
    return (rem + div).toDouble();
  }

  void _filter() {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      constraints: BoxConstraints(
        maxWidth: context.sw() - 20,
        minWidth: context.sw() - 20,
      ),
      builder: (context) {
        return ContactsFilter(
          cat1Filter: _cat1Filter,
          cat2Filter: _cat2Filter,
          cat3Filter: _cat3Filter,
          cat4Filter: _cat4Filter,
          cat5Filter: _cat5Filter,
          setState: setState,
          confirmText: "Filter",
          cancelText: "Cancel",
        );
      },
    );
  }

  void _categoryContactsDelete() async {
    // if (_dataGridController.selectedRows.isNotEmpty) {
    //   generalDialog(
    //     context: context,
    //     title: const Text("Delete contacts"),
    //     content: Text(
    //       "Are you sure? you want to delete ${_dataGridController.selectedRows.length} contact(s)?",
    //     ),
    //     actions: [
    //       TextButton(
    //         onPressed: () => context.pop(),
    //         child: const Text("No"),
    //       ),
    //       TextButton(
    //         onPressed: () async {
    //           final response = await locator<ApiClient>().deleteContacts(
    //             contacts: _dataGridController.selectedRows
    //                 .map((e) => e.getCells()[1].value.toString())
    //                 .toList(),
    //           );
    //           if (response.isSuccess) {
    //             _dataGridController.selectedRows.clear();
    //             setState(() {});
    //             if (mounted) {
    //               context.pop();
    //             }
    //           } else {
    //             QuickAlert.show(
    //               context: context,
    //               width: 200,
    //               type: QuickAlertType.error,
    //               text: response.message,
    //             );
    //           }
    //         },
    //         child: const Text("Yes"),
    //       ),
    //     ],
    //   );
    //   return;
    // }
    final cat1 = <String>[];
    final cat2 = <String>[];
    final cat3 = <String>[];
    final cat4 = <String>[];
    final cat5 = <String>[];
    await showModalBottomSheet(
      context: context,
      isDismissible: true,
      constraints: BoxConstraints(
        maxWidth: context.sw() - 20,
        minWidth: context.sw() - 20,
      ),
      builder: (context) {
        return ContactsFilter(
          cat1Filter: cat1,
          cat2Filter: cat2,
          cat3Filter: cat3,
          cat4Filter: cat4,
          cat5Filter: cat5,
          setState: (_) {},
          confirmText: "Delete",
          cancelText: "Cancel",
        );
      },
    );

    if (cat1.isEmpty &&
        cat2.isEmpty &&
        cat3.isEmpty &&
        cat4.isEmpty &&
        cat5.isEmpty) {
      QuickAlert.show(
        context: context,
        width: 200,
        type: QuickAlertType.warning,
        text: "Please select at least one category",
      );
      return;
    }

    final response = await locator<ApiClient>().categoryContactsDelete(
      category1: cat1,
      category2: cat2,
      category3: cat3,
      category4: cat4,
      category5: cat5,
    );
    if (response.isSuccess) {
      context.pop();
      QuickAlert.show(
        context: context,
        width: 200,
        type: QuickAlertType.success,
        text: response.message,
      );
    } else {
      QuickAlert.show(
        context: context,
        width: 200,
        type: QuickAlertType.error,
        text: response.message,
      );
    }
  }
}
