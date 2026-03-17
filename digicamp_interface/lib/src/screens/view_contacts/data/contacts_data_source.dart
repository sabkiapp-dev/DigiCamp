import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:digicamp_interface/injection_container.dart';
import 'package:digicamp_interface/src/commons/general_dialogs.dart';
import 'package:digicamp_interface/src/models/models.dart';
import 'package:digicamp_interface/src/providers/providers.dart';
import 'package:digicamp_interface/src/utils/services/rest_api.dart';

class ContactsDataSource extends DataGridSource {
  ContactsDataSource({
    required List<ContactsModel> contacts,
    this.pageSize = 20,
    this.query,
    this.cat1Filter,
    this.cat2Filter,
    this.cat3Filter,
    this.cat4Filter,
    this.cat5Filter,
    required this.context,
  }) {
    buildDataGridRow(contacts: contacts);
  }

  // Filters
  int pageSize;
  String? query;
  final List<String>? cat1Filter;
  final List<String>? cat2Filter;
  final List<String>? cat3Filter;
  final List<String>? cat4Filter;
  final List<String>? cat5Filter;
  BuildContext context;

  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        if (dataGridCell.columnName == 'delete') {
          return Center(
            child: IconButton(
              onPressed: () async {
                final result = await generalDialog(
                  context: context,
                  title: const Text("Delete Contact"),
                  content: const Text(
                    "Are you sure you want to delete this contact?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        context.pop(false);
                      },
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        context.pop(true);
                      },
                      child: const Text("Delete"),
                    ),
                  ],
                );
                if (result == true) {
                  context.read<HudProvider>().showProgress();
                  final response = await locator<ApiClient>().deleteContacts(
                    contacts: [
                      row.getCells()[1].value.toString(),
                    ],
                  );
                  if (response.isSuccess) {
                    notifyListeners();
                  }
                  context.read<HudProvider>().hideProgress();
                }
              },
              icon: const Icon(Icons.delete),
              tooltip: "Delete",
            ),
          );
        }
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(16.0),
          child: Text(dataGridCell.value.toString()),
        );
      }).toList(),
    );
  }

  @override
  Future<bool> handlePageChange(int oldPageIndex, int newPageIndex) async {
    final response = await locator<ApiClient>().contacts(
      page: newPageIndex + 1,
      pageSize: pageSize,
      query: query,
      category1: cat1Filter,
      category2: cat2Filter,
      category3: cat3Filter,
      category4: cat4Filter,
      category5: cat5Filter,
    );
    if (response.isSuccess) {
      buildDataGridRow(contacts: response.data!.results!);
      notifyListeners();
    }
    return super.handlePageChange(oldPageIndex, newPageIndex);
  }

  void buildDataGridRow({required List<ContactsModel> contacts}) {
    dataGridRows = contacts.map<DataGridRow>((contact) {
      return DataGridRow(
        cells: [
          DataGridCell<String>(
            columnName: 'name',
            value: contact.name,
          ),
          DataGridCell<String>(
            columnName: 'phone_number',
            value: contact.phoneNumber,
          ),
          DataGridCell<String>(
            columnName: 'category_1',
            value: contact.category1,
          ),
          DataGridCell<String>(
            columnName: 'category_2',
            value: contact.category2,
          ),
          DataGridCell<String>(
            columnName: 'category_3',
            value: contact.category3,
          ),
          DataGridCell<String>(
            columnName: 'category_4',
            value: contact.category4,
          ),
          DataGridCell<String>(
            columnName: 'category_5',
            value: contact.category5,
          ),
          DataGridCell<int>(
            columnName: 'delete',
            value: contact.id,
          ),
        ],
      );
    }).toList();
  }

  Future<void> removeContacts(List<String> contacts) async {
    final response = await locator<ApiClient>().deleteContacts(
      contacts: contacts,
    );
    if (response.isSuccess) {
      notifyListeners();
    }
  }
}
