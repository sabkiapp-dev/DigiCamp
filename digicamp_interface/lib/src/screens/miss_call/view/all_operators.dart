import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quickalert/quickalert.dart';
import 'package:digicamp_interface/injection_container.dart';
import 'package:digicamp_interface/src/config/app_constants.dart';
import 'package:digicamp_interface/src/models/models.dart';
import 'package:digicamp_interface/src/utils/services/rest_api.dart';

class AllOperators extends StatefulWidget {
  const AllOperators({super.key});

  @override
  State<AllOperators> createState() => _AllOperatorsState();
}

class _AllOperatorsState extends State<AllOperators> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Data<List<OperatorModel>>>(
      future: locator<ApiClient>().operators(),
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

        return SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const <DataColumn>[
                DataColumn(
                  label: Text('ID'),
                ),
                DataColumn(
                  label: Text('Description'),
                ),
                DataColumn(
                  label: Text('Operator'),
                ),
                DataColumn(
                  label: Text('Associated Number'),
                ),
                DataColumn(
                  label: Text('Campaign Associated'),
                ),
                DataColumn(
                  label: Text('Status'),
                ),
                DataColumn(
                  label: Text('Edit'),
                ),
              ],
              rows: snapshot.data!.data!.map((e) {
                return DataRow(
                  cells: <DataCell>[
                    DataCell(
                      Text(e.id.toString()),
                      onTap: () => _viewMissCalls(e),
                    ),
                    DataCell(
                      Text(e.description ?? 'N/A'),
                      onTap: () => _viewMissCalls(e),
                    ),
                    DataCell(
                      Text(e.operator ?? 'N/A'),
                      onTap: () => _viewMissCalls(e),
                    ),
                    DataCell(
                      Text(e.associatedNumber ?? 'N/A'),
                      onTap: () => _viewMissCalls(e),
                    ),
                    DataCell(
                      Text(e.campaignAssociated!.name!),
                      onTap: () => _viewMissCalls(e),
                    ),
                    DataCell(
                      ValueListenableBuilder<int>(
                        valueListenable: e.status,
                        builder: (context, value, child) {
                          return CupertinoSwitch(
                            value: value == 1,
                            onChanged: (value) async {
                              final status = value ? 1 : 0;
                              final response = await locator<ApiClient>()
                                  .updateOperatorStatus(
                                id: e.id!,
                                status: status,
                              );
                              if (response.isSuccess) {
                                e.status.value = status;
                                QuickAlert.show(
                                  context: context,
                                  width: 300,
                                  type: QuickAlertType.success,
                                  title: response.message,
                                );
                              } else {
                                QuickAlert.show(
                                  context: context,
                                  width: 300,
                                  type: QuickAlertType.error,
                                  title: response.message,
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          await context.push(
                            AppRoutes.addOperator.path,
                            extra: e,
                          );
                          setState(() {});
                        },
                      ),
                    )
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _viewMissCalls(OperatorModel operator) {
    context.push(AppRoutes.viewMissCall.path, extra: operator.operator);
  }
}
