import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart' hide Data;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:digicamp_interface/injection_container.dart';
import 'package:digicamp_interface/src/commons/general_dialogs.dart';
import 'package:digicamp_interface/src/formz_model/formz_model.dart';
import 'package:digicamp_interface/src/models/models.dart';
import 'package:digicamp_interface/src/providers/hud_provider/hud_provider.dart';
import 'package:digicamp_interface/src/utils/palette.dart';
import 'package:digicamp_interface/src/utils/services/rest_api.dart';
import 'package:digicamp_interface/src/utils/utils.dart';

class AddContacts extends StatefulWidget {
  const AddContacts({super.key});

  @override
  State<AddContacts> createState() => _AddContactsState();
}

class _AddContactsState extends State<AddContacts> {
  // final Future<Data<List<String>>> _groupsFuture =
  //     locator<ApiClient>().contactGroups();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneNumberCtrl = TextEditingController();
  final TextEditingController _category1Ctrl = TextEditingController();
  final TextEditingController _category2Ctrl = TextEditingController();
  final TextEditingController _category3Ctrl = TextEditingController();
  final TextEditingController _category4Ctrl = TextEditingController();
  final TextEditingController _category5Ctrl = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FilePicker _picker = FilePicker.platform;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    hintText: "Name",
                  ),
                  validator: const Name.pure().validator,
                ),
                // const Gap(10),
                TextFormField(
                  controller: _phoneNumberCtrl,
                  decoration: const InputDecoration(
                    hintText: "Phone Number",
                  ),
                  validator: const Mobile.pure().validator,
                ),
                // const Gap(10),
                TextFormField(
                  controller: _category1Ctrl,
                  decoration: const InputDecoration(
                    hintText: "Category 1",
                  ),
                ),
                // const Gap(10),
                TextFormField(
                  controller: _category2Ctrl,
                  decoration: const InputDecoration(
                    hintText: "Category 2",
                  ),
                ),
                // const Gap(10),
                TextFormField(
                  controller: _category3Ctrl,
                  decoration: const InputDecoration(
                    hintText: "Category 3",
                  ),
                ),
                // const Gap(10),
                TextFormField(
                  controller: _category4Ctrl,
                  decoration: const InputDecoration(
                    hintText: "Category 4",
                  ),
                ),
                // const Gap(10),
                TextFormField(
                  controller: _category5Ctrl,
                  decoration: const InputDecoration(
                    hintText: "Category 5",
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      context.read<HudProvider>().showProgress();
                      final response = await locator<ApiClient>().addContacts(
                        contacts: [
                          ContactsModel(
                            name: _nameCtrl.text,
                            phoneNumber: _phoneNumberCtrl.text,
                            category1: _category1Ctrl.text.isEmpty
                                ? 'Other'
                                : _category1Ctrl.text,
                            category2: _category2Ctrl.text.isEmpty
                                ? 'Other'
                                : _category2Ctrl.text,
                            category3: _category3Ctrl.text.isEmpty
                                ? 'Other'
                                : _category3Ctrl.text,
                            category4: _category4Ctrl.text.isEmpty
                                ? 'Other'
                                : _category4Ctrl.text,
                            category5: _category5Ctrl.text.isEmpty
                                ? 'Other'
                                : _category5Ctrl.text,
                          ),
                        ],
                      );

                      if (mounted && response.isSuccess) {
                        _nameCtrl.clear();
                        _phoneNumberCtrl.clear();
                        _category1Ctrl.clear();
                        _category2Ctrl.clear();
                        _category3Ctrl.clear();
                        _category4Ctrl.clear();
                        _category5Ctrl.clear();
                        QuickAlert.show(
                          context: context,
                          width: 200,
                          type: QuickAlertType.success,
                          title: response.message,
                        );
                        context.read<HudProvider>().hideProgress();
                      }
                    }
                  },
                  child: const Text("Add Contact"),
                ),
                ElevatedButton(
                  onPressed: _pickFiles,
                  child: const Text("Import EXCEL/CSV"),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _pickFiles() async {
    // context.pop();
    final file = await _picker.pickFiles(
      allowMultiple: false,
      allowedExtensions: ["xlsx", "csv"],
      type: FileType.custom,
    );

    if (file != null && file.files.isNotEmpty) {
      final type = file.files.first.extension;
      if (type == "csv") {
        final content = utf8.decode(file.files.first.bytes!);
        final list = const CsvToListConverter().convert(
          content,
          eol: '\n',
          fieldDelimiter: ',',
        );
        _showEntries(values: list);
      } else {
        final excel = Excel.decodeBytes(file.files.first.bytes!);
        if (mounted && excel.sheets.length > 1) {
          QuickAlert.show(
            context: context,
            width: 200,
            type: QuickAlertType.warning,
            title: "Multiple pages found",
          );
        }
        excel.sheets.forEach((group, sheet) {
          _showEntries(
            label: group,
            values: sheet.rows
                .map((el) => el.map((e) => e?.value).toList())
                .toList(),
          );
        });
      }
    }
  }

  void _showEntries({
    List<List> values = const [],
    String? label,
  }) {
    // Replace the empty values with null
    values = values
        .map((e) => e
            .map((v) => v != null && v.toString().isNotEmpty ? v : null)
            .toList())
        .toList();
    final length = values.length;
    values = values.sublist(1);
    int subLength = length > 10 ? 10 : length - 1;
    final showingList = List.of(values).sublist(0, subLength);

    generalDialog(
      context: context,
      title: label != null ? Text(label) : null,
      content: SingleChildScrollView(
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  "Name",
                  "Phone Number",
                  "Category 1",
                  "Category 2",
                  "Category 3",
                  "Category 4",
                  "Category 5",
                ].map((label) {
                  return DataColumn(
                    label: Text(label),
                  );
                }).toList(),
                rows: showingList.map((value) {
                  final len = value.length;
                  if (len > 7) {
                    value.length = 7;
                  }
                  final remainingLen = 7 - len;
                  return DataRow(
                    cells: [
                      for (int i = 0; i < value.length; i++)
                        DataCell(Text(value[i]?.toString() ?? "N/A")),
                      for (int i = 0; i < remainingLen; i++)
                        const DataCell(Text("N/A"))
                    ],
                  );
                }).toList(),
              ),
            ),
            if (length > 10)
              ColoredBox(
                color: Palette.primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "${length - 10} more entries",
                    style: const TextStyle(
                      color: Palette.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () async {
            for (final value in values) {
              if (value.length < 2 ||
                  value[1] == null ||
                  value[1].toString().isEmpty) {
                QuickAlert.show(
                  context: context,
                  width: 200,
                  type: QuickAlertType.error,
                  title: "Phone Number can not be empty",
                );
                return;
              }
              if (value.length < 7) {
                for (int i = value.length; i < 7; i++) {
                  value.add('Other');
                }
              }
            }

            List<ContactsModel> contacts = values.map((value) {
              return ContactsModel(
                name: value[0]?.toString(),
                phoneNumber: value[1]?.toString(),
                category1: value[2]?.toString(),
                category2: value[3]?.toString(),
                category3: value[4]?.toString(),
                category4: value[5]?.toString(),
                category5: value[6]?.toString(),
              );
            }).toList();

            context.read<HudProvider>().showProgress();
            final batch = Utils.generateBatch(contacts, 50);

            final resps = await Future.wait(
              batch.map((contacts) {
                return locator<ApiClient>().addContacts(contacts: contacts);
              }),
            );
            List<String> added = [];
            List<String> updated = [];
            List<String> existing = [];
            List<String> invalid = [];
            for (final resp in resps) {
              if (resp.isSuccess) {
                final addedData = resp.data!["added_data"] as List;
                final updatedData = resp.data!["updated_data"] as List;
                added.addAll(addedData.map((e) => e['phone_number']));
                updated.addAll(updatedData.map((e) => e['phone_number']));
                existing.addAll(
                    resp.data!["existing_phone_numbers"]?.cast<String>());
                invalid.addAll(
                    resp.data!["invalid_phone_numbers"]?.cast<String>());
              }
            }
            print("Added - ${added.length}, $added");
            print("Updated - ${updated.length}, $updated");
            print("Existing - ${existing.length}, $existing");
            print("Invalid - ${invalid.length}, $invalid");
            if (mounted) {
              context.read<HudProvider>().hideProgress();
              context.pop();
            }
          },
          child: const Text("Import"),
        ),
      ],
    );
  }
}
