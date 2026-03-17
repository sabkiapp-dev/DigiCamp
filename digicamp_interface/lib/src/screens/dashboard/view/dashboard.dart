import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:digicamp_interface/injection_container.dart';
import 'package:digicamp_interface/src/commons/general_dialogs.dart';
import 'package:digicamp_interface/src/commons/responsive_layout_builder.dart';
import 'package:digicamp_interface/src/config/app_constants.dart';
import 'package:digicamp_interface/src/config/font_sizes.dart';
import 'package:digicamp_interface/src/models/models.dart';
import 'package:digicamp_interface/src/providers/providers.dart';
import 'package:digicamp_interface/src/utils/services/rest_api.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late final AuthProvider _authProvider;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _authProvider = context.read<AuthProvider>();
      _authProvider.addListener(_listener);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _authProvider.removeListener(_listener);
  }

  void _listener() async {
    if (_authProvider.isUnauthenticated) {
      await generalDialog(
        context: context,
        title: const Text("Session Expired"),
        content: const Text("Your session has expired. Please login again"),
        actions: [
          TextButton(
            onPressed: () {
              context.go(AppRoutes.users.path);
            },
            child: const Text("Login"),
          ),
        ],
      );
      context.go(AppRoutes.users.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayoutBuilder(
      small: (context, constraints, child) {
        return child!;
      },
      large: (context, constraints, child) {
        return Column(
          children: [
            ListTile(
              title: Text(
                context.read<AuthProvider>().userName != null
                    ? "${context.read<AuthProvider>().userName}'s dashboard."
                    : "Dashboard",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () {
                  setState(() {});
                },
              ),
            ),
            Expanded(
              child: child!,
            ),
          ],
        );
      },
      child: FutureBuilder<Data<List<HostModel>>>(
        future: locator<ApiClient>().activeHostStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            );
          }
          if (!snapshot.data!.isSuccess) {
            return Center(
              child: Text(snapshot.data!.message),
            );
          }
          return Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ListView.separated(
              separatorBuilder: (context, index) {
                return const Divider(
                  color: Colors.grey,
                  thickness: 1,
                  height: 1,
                );
              },
              itemBuilder: (context, index) {
                final host = snapshot.data!.data![index];
                return _hostCard(host);
              },
              itemCount: snapshot.data!.data!.length,
            ),
          );
        },
      ),
    );
  }

  Widget _hostCard(HostModel host) {
    return StatefulBuilder(
      builder: (context, setState) {
        return ExpansionTile(
          onExpansionChanged: (value) {
            if (value) {
              setState(() {});
            }
          },
          title: Row(
            children: [
              Text(
                host.host!,
                style: const TextStyle(
                  fontSize: FontSizes.button,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(10),
              if (host.status == 1)
                const Icon(
                  Icons.power_rounded,
                  color: Colors.green,
                )
              else
                const Icon(
                  Icons.power_off_rounded,
                  color: Colors.red,
                )
            ],
          ),
          // childrenPadding: const EdgeInsets.all(8.0),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder(
              future: locator<ApiClient>().machineStatus(
                host: host.host!,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      snapshot.error.toString(),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  );
                }
                if (!snapshot.data!.isSuccess) {
                  return Center(
                    child: Text(snapshot.data!.message),
                  );
                }
                final machineStatus = snapshot.data!.data!;
                final ports = machineStatus.portData
                  ..sort((a, b) => a.port!.compareTo(b.port!));
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _card(
                            icon: Icons.block,
                            text: "SIM Blocked Today",
                            value: "${machineStatus.numberOfSimsBlocked ?? 0}",
                            onTap: () {},
                            badgeColor: Colors.red,
                          ),
                          _card(
                            icon: Icons.sim_card_alert_rounded,
                            text: "Port Without SIM",
                            value:
                                "${machineStatus.numberOfPortsWithNoSim ?? 0}",
                            onTap: () {},
                            badgeColor: Colors.red,
                          ),
                          _card(
                            icon: Icons
                                .signal_cellular_connected_no_internet_0_bar_rounded,
                            text: "SIM Without Signal",
                            value:
                                "${machineStatus.numberOfPortsWithNoSignal ?? 0}",
                            onTap: () {},
                            badgeColor: Colors.red,
                          ),
                          _card(
                            icon: Icons.no_cell,
                            text: "SIM Without Recharge",
                            value:
                                "${machineStatus.numberOfSimsWithNoRecharge ?? 0}",
                            onTap: () {},
                            badgeColor: Colors.red,
                          ),
                          _card(
                            icon: Icons.sim_card,
                            text: "New SIM",
                            value: "${machineStatus.numberOfNewSims ?? 0}",
                            onTap: () {},
                            badgeColor: Colors.blue,
                          ),
                          _card(
                            icon: Icons.timer,
                            text: "Waiting SIM",
                            value: "${machineStatus.numberOfSimsWaiting ?? 0}",
                            onTap: () {},
                            badgeColor: Colors.brown,
                          ),
                          _card(
                            icon: Icons.cell_tower,
                            text: "Ready SIM",
                            value: "${machineStatus.numberOfSimsReady ?? 0}",
                            onTap: () {},
                            badgeColor: Colors.green,
                          ),
                          _card(
                            icon: Icons.call_missed_outgoing_rounded,
                            text: "Busy SIM",
                            value: "${machineStatus.numberOfSimsBusy ?? 0}",
                            onTap: () {},
                            badgeColor: Colors.blue,
                          ),
                          _card(
                            icon: Icons.sms,
                            text: "Total SMS Balance",
                            value: "${machineStatus.totalSmsBalance ?? 0}",
                            onTap: () {},
                            badgeColor: Colors.green,
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                      thickness: 1,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                      ),
                      child: Text(
                        "Available Ports: ${machineStatus.portData.length}",
                        style: const TextStyle(
                          fontSize: FontSizes.large,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Gap(5),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          "Port",
                          "Signal",
                          "Status",
                          "Phone Number",
                          "Operator",
                          "Call Made Today",
                          "Call Time Today",
                          "Daily SMS Balance",
                          "Call Made Total",
                          "Call Time Total",
                          "Validity",
                          "Today Block Status",
                          "Waiting Time",
                          "Last Call Time",
                        ].map((column) {
                          return DataColumn(label: Text(column));
                        }).toList(),
                        rows: [
                          for (int index = 0; index < ports.length; index++)
                            DataRow(
                              cells: [
                                DataCell(Text("${ports[index].port ?? 0}")),
                                if (ports[index].phoneNumber != null)
                                  DataCell(
                                    _buildBar(int.tryParse(
                                            ports[index].signal.toString()) ??
                                        0),
                                  )
                                else
                                  DataCell(
                                    _buildBar(-1),
                                  ),
                                DataCell(
                                  ports[index].finalStatus != "Rechargeless"
                                      ? ports[index].finalStatus == "Blocked"
                                          ? OutlinedButton(
                                              onPressed: () => _testBlockedSim(
                                                host: machineStatus.host,
                                                port: ports[index].port,
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                side: const BorderSide(
                                                  color: Colors.black,
                                                ),
                                              ),
                                              child: Text(
                                                ports[index].finalStatus ??
                                                    'N/A',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            )
                                          : Text(
                                              ports[index].finalStatus ?? 'N/A',
                                              style: TextStyle(
                                                color: _finalStatusColor(
                                                    ports[index].finalStatus),
                                              ),
                                            )
                                      : OutlinedButton(
                                          onPressed: () => _checkForRecharge(
                                            host: machineStatus.host,
                                            ussdForcefully: "1",
                                            portForcefully: ports[index].port,
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                              color: Colors.red,
                                            ),
                                          ),
                                          child: Text(
                                            ports[index].finalStatus ?? 'N/A',
                                            style: const TextStyle(
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                ),
                                DataCell(Text(ports[index].phoneNo ?? 'N/A')),
                                DataCell(Text(ports[index].operator ?? 'N/A')),
                                DataCell(
                                  Text(
                                    ports[index].callsMadeToday?.toString() ??
                                        'N/A',
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    ports[index].callTimeToday?.toString() ??
                                        'N/A',
                                  ),
                                ),
                                DataCell(Text(
                                    ports[index].smsBalance?.toString() ??
                                        'N/A')),
                                DataCell(
                                  Text(
                                    ports[index].callsMadeTotal?.toString() ??
                                        'N/A',
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    ports[index].callTimeTotal?.toString() ??
                                        'N/A',
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    ports[index].validity ?? 'N/A',
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    ports[index].todayBlockStatus?.toString() ??
                                        'N/A',
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    ports[index].callAfter?.toString() ?? 'N/A',
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    ports[index].lastCallTime ?? 'N/A',
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildBar(int strength) {
    Color bar1Color = Colors.grey;
    Color bar2Color = Colors.grey;
    Color bar3Color = Colors.grey;
    Color bar4Color = Colors.grey;

    if (!strength.isNegative) {
      if (strength >= 6 && strength <= 11) {
        bar1Color = Colors.black;
      } else if (strength >= 12 && strength <= 17) {
        bar1Color = Colors.black;
        bar2Color = Colors.black;
      } else if (strength >= 18 && strength <= 23) {
        bar1Color = Colors.black;
        bar2Color = Colors.black;
        bar3Color = Colors.black;
      } else if (strength >= 24 && strength <= 31) {
        bar1Color = Colors.black;
        bar2Color = Colors.black;
        bar3Color = Colors.black;
        bar4Color = Colors.black;
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          height: 5,
          width: 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: bar1Color,
          ),
        ),
        const Gap(1),
        Container(
          height: 8,
          width: 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: bar2Color,
          ),
        ),
        const Gap(1),
        Container(
          height: 11,
          width: 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: bar3Color,
          ),
        ),
        const Gap(1),
        Container(
          height: 14,
          width: 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: bar4Color,
          ),
        ),
      ],
    );
  }

  Widget _card({
    required IconData icon,
    required String text,
    required GestureTapCallback? onTap,
    required String value,
    required Color badgeColor,
  }) {
    return SizedBox(
      height: 120,
      width: 120,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 30,
                    ),
                    const Gap(10),
                    Text(
                      text,
                      style: const TextStyle(
                        fontSize: FontSizes.body1,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: badgeColor,
              ),
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: FontSizes.small,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _checkForRecharge({
    String? host,
    required String ussdForcefully,
    int? portForcefully,
  }) async {
    context.read<HudProvider>().showProgress();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "Please wait while we are checking for recharge, Please refresh after 1 minute.",
        ),
        duration: const Duration(seconds: 10),
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
    await locator<ApiClient>().machineStatus(
      host: host,
      ussdForcefully: ussdForcefully,
      portForcefully: portForcefully.toString(),
    );
    if (mounted) {
      context.read<HudProvider>().hideProgress();
    }
  }

  Color _finalStatusColor(String? finalStatus) {
    switch (finalStatus) {
      case "Ready":
        return Colors.green;
      case "Busy":
        return Colors.blue;
      default:
        return Colors.black;
    }
  }

  void _testBlockedSim({required String? host, required int? port}) async {
    String? phoneNumber;
    final status = await generalDialog(
      context: context,
      title: const Text("Enter Phone Number"),
      content: TextField(
        onChanged: (value) => phoneNumber = value,
        decoration: const InputDecoration(
          hintText: "Enter Phone Number",
        ),
        maxLength: 10,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(false),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => context.pop(true),
          child: const Text("Submit"),
        ),
      ],
    );
    if (status == false) {
      return;
    }
    if (phoneNumber == null ||
        phoneNumber!.isEmpty ||
        phoneNumber!.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid phone number"),
        ),
      );
      return;
    }
    await locator<ApiClient>().testBlockedSim(
      host: host!,
      port: port!,
      phoneNumber: int.parse(phoneNumber!),
    );
  }
}
