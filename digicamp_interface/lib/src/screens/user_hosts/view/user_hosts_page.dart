import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:digicamp_interface/injection_container.dart';
import 'package:digicamp_interface/src/commons/general_dialogs.dart';
import 'package:digicamp_interface/src/models/models.dart';
import 'package:digicamp_interface/src/providers/providers.dart';
import 'package:digicamp_interface/src/utils/services/rest_api.dart';

class UserHostsPage extends StatefulWidget {
  const UserHostsPage({
    super.key,
    required this.userId,
  });
  final int userId;

  @override
  State<UserHostsPage> createState() => _UserHostsPageState();
}

class _UserHostsPageState extends State<UserHostsPage> {
  late final Future<Data<List<HostModel>>> _hostFuture;
  var _hosts = <HostModel>[];

  @override
  void initState() {
    super.initState();
    _hostFuture = locator<ApiClient>().getHostsByUser(userId: widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Data<List<HostModel>>>(
        future: _hostFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }
          if (!snapshot.data!.isSuccess) {
            return Center(
              child: Text(snapshot.data!.message),
            );
          }
          if (snapshot.data!.data!.isEmpty) {
            return const Center(
              child: Text("No hosts found"),
            );
          }
          _hosts = snapshot.data!.data!;
          return ListView.builder(
            itemBuilder: (context, index) {
              final item = _hosts[index];
              return ListTile(
                title: Text(
                  "Host: ${item.host!}",
                ),
                isThreeLine: true,
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Password: ${item.systemPassword!}"),
                    Text("Priority: ${item.priority!}"),
                    Text("Allow SMS: ${item.allowSms == 1 ? "Yes" : "No"}"),
                  ],
                ),
                onTap: () => _addModifyHosts(item),
                // trailing: IconButton(
                //   onPressed: () => _deleteHost(item),
                //   icon: const Icon(Icons.delete),
                // ),
                trailing: CupertinoSwitch(
                  value: item.status == 1,
                  onChanged: (value) async {
                    context.read<HudProvider>().showProgress();
                    final response =
                        await locator<ApiClient>().changeHostStatus(
                      hostId: item.id!,
                      status: value ? 1 : 0,
                    );
                    context.read<HudProvider>().hideProgress();
                    if (response.isSuccess && mounted) {
                      if (response.isSuccess) {
                        item.status = value ? 1 : 0;
                        setState(() {});
                      }
                    }
                  },
                ),
              );
            },
            itemCount: _hosts.length,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addModifyHosts,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _deleteHost(HostModel host) async {
    final status = await generalDialog(
      context: context,
      content: Text("Are you sure you want to delete '${host.host}' host?"),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () async {
            context.pop(true);
          },
          child: const Text("Delete"),
        ),
      ],
    );
    if (status == true && mounted) {
      context.read<HudProvider>().showProgress();
      final response = await locator<ApiClient>().removeHost(hostId: host.id!);
      if (mounted) {
        context.read<HudProvider>().hideProgress();
        if (response.isSuccess) {
          _hosts.remove(host);
          setState(() {});
        }
      }
    }
  }

  void _addModifyHosts([HostModel? host]) {
    final formKey = GlobalKey<FormState>();
    final hostController = TextEditingController(
      text: host?.host,
    );
    final passwordController = TextEditingController(
      text: host?.systemPassword,
    );
    final priorityController = TextEditingController(
      text: host?.priority.toString(),
    );
    final allowSmsValues = {
      1: 'Yes',
      0: 'No',
    };
    int allowSms = host?.allowSms ?? 0;
    ValueNotifier<bool> isExists = ValueNotifier(false);
    generalDialog(
      context: context,
      title: host == null ? const Text("Add Host") : const Text("Edit Host"),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              onChanged: (value) async {
                final response =
                    await locator<ApiClient>().getHostPassword(value);
                if (response.isSuccess) {
                  isExists.value = true;
                  passwordController.text = response.data!;
                } else {
                  isExists.value = false;
                }
              },
              readOnly: host != null,
              controller: hostController,
              decoration: const InputDecoration(
                labelText: "Host",
              ),
              validator: (value) => value!.isEmpty ? "Host is required" : null,
            ),
            const Gap(10),
            ValueListenableBuilder(
              valueListenable: isExists,
              builder: (context, value, child) {
                return TextFormField(
                  readOnly: value,
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: "Password",
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Password is required" : null,
                );
              },
            ),
            const Gap(10),
            TextFormField(
              controller: priorityController,
              decoration: const InputDecoration(
                labelText: "Priority",
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) =>
                  value!.isEmpty ? "Priority is required" : null,
            ),
            const Gap(10),
            DropdownButtonFormField(
              items: allowSmsValues.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: "Allow SMS",
              ),
              value: allowSms,
              onChanged: (int? value) {
                allowSms = value!;
              },
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
            if (!formKey.currentState!.validate()) {
              return;
            }
            context.read<HudProvider>().showProgress();
            if (host == null) {
              final response = await locator<ApiClient>().addHost(
                userId: widget.userId,
                host: hostController.text,
                systemPassword: passwordController.text,
                priority: int.parse(priorityController.text),
                allowSms: allowSms,
              );
              if (mounted) {
                context
                  ..read<HudProvider>().hideProgress()
                  ..pop();
                if (response.isSuccess) {
                  _hosts.add(response.data!);
                  setState(() {});
                }
              }
            } else {
              final response = await locator<ApiClient>().editHost(
                hostId: host.id!,
                host: hostController.text,
                systemPassword: passwordController.text,
                priority: int.parse(priorityController.text),
                allowSms: allowSms,
              );
              if (mounted) {
                context
                  ..read<HudProvider>().hideProgress()
                  ..pop();
                if (response.isSuccess) {
                  host.host = hostController.text;
                  host.systemPassword = passwordController.text;
                  host.priority = int.parse(priorityController.text);
                  host.allowSms = allowSms;
                  setState(() {});
                }
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Host updated successfully'),
                ),
              );
            }
          },
          child: host == null ? const Text("Add") : const Text("Update"),
        ),
      ],
    );
  }
}
