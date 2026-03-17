import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:digicamp_interface/injection_container.dart';
import 'package:digicamp_interface/src/commons/general_dialogs.dart';
import 'package:digicamp_interface/src/config/app_constants.dart';
import 'package:digicamp_interface/src/formz_model/formz_model.dart';
import 'package:digicamp_interface/src/models/models.dart';
import 'package:digicamp_interface/src/providers/providers.dart';
import 'package:digicamp_interface/src/utils/services/rest_api.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key, required this.scaffoldKey});
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ListView(
          children: [
            if (!context.read<AuthProvider>().isSuperuser) ...[
              ListTile(
                style: ListTileStyle.drawer,
                visualDensity: VisualDensity.compact,
                leading: const Icon(Icons.home),
                title: const Text("Dashboard"),
                onTap: () {
                  widget.scaffoldKey.currentState!.openEndDrawer();
                  context.go(AppRoutes.dashboard.path);
                },
                selected: AppRoutes.dashboard.path ==
                    GoRouterState.of(context).uri.path,
              ),
              ExpansionTile(
                title: const Text("Campaign Management"),
                initiallyExpanded: AppRoutes.addCampaign.path ==
                        GoRouterState.of(context).uri.path ||
                    AppRoutes.viewCampaigns.path ==
                        GoRouterState.of(context).uri.path ||
                    AppRoutes.dialPlan.path ==
                        GoRouterState.of(context).uri.path ||
                    AppRoutes.campaignReport.path ==
                        GoRouterState.of(context).uri.path,
                leading: const Icon(Icons.campaign),
                children: [
                  ListTile(
                    style: ListTileStyle.drawer,
                    visualDensity: VisualDensity.compact,
                    title: const Text("Add New Campaign"),
                    onTap: () {
                      widget.scaffoldKey.currentState!.openEndDrawer();
                      context.go(AppRoutes.addCampaign.path);
                    },
                    selected: AppRoutes.addCampaign.path ==
                        GoRouterState.of(context).uri.path,
                  ),
                  ListTile(
                    style: ListTileStyle.drawer,
                    visualDensity: VisualDensity.compact,
                    title: const Text("View All Campaigns"),
                    onTap: () {
                      widget.scaffoldKey.currentState!.openEndDrawer();
                      context.go(AppRoutes.viewCampaigns.path);
                    },
                    selected: AppRoutes.viewCampaigns.path ==
                        GoRouterState.of(context).uri.path,
                  ),
                ],
              ),
              ExpansionTile(
                title: const Text("All Contacts"),
                leading: const Icon(Icons.contacts),
                initiallyExpanded: AppRoutes.addContacts.path ==
                        GoRouterState.of(context).uri.path ||
                    AppRoutes.viewContacts.path ==
                        GoRouterState.of(context).uri.path,
                children: [
                  ListTile(
                    style: ListTileStyle.drawer,
                    visualDensity: VisualDensity.compact,
                    title: const Text("Add Contacts"),
                    onTap: () {
                      widget.scaffoldKey.currentState!.openEndDrawer();
                      context.go(AppRoutes.addContacts.path);
                    },
                    selected: AppRoutes.addContacts.path ==
                        GoRouterState.of(context).uri.path,
                  ),
                  ListTile(
                    style: ListTileStyle.drawer,
                    visualDensity: VisualDensity.compact,
                    title: const Text("View Contacts"),
                    onTap: () {
                      widget.scaffoldKey.currentState!.openEndDrawer();
                      context.go(AppRoutes.viewContacts.path);
                    },
                    selected: AppRoutes.viewContacts.path ==
                        GoRouterState.of(context).uri.path,
                  ),
                ],
              ),
              ExpansionTile(
                title: const Text("SMS Templates"),
                leading: const Icon(Icons.sms),
                initiallyExpanded: AppRoutes.addSms.path ==
                        GoRouterState.of(context).uri.path ||
                    AppRoutes.viewSms.path ==
                        GoRouterState.of(context).uri.path,
                children: [
                  ListTile(
                    style: ListTileStyle.drawer,
                    visualDensity: VisualDensity.compact,
                    title: const Text("Add SMS Template"),
                    onTap: () {
                      widget.scaffoldKey.currentState!.openEndDrawer();
                      context.go(AppRoutes.addSms.path);
                    },
                    selected: AppRoutes.addSms.path ==
                        GoRouterState.of(context).uri.path,
                  ),
                  ListTile(
                    style: ListTileStyle.drawer,
                    visualDensity: VisualDensity.compact,
                    title: const Text("View SMS Templates"),
                    onTap: () {
                      widget.scaffoldKey.currentState!.openEndDrawer();
                      context.go(AppRoutes.viewSms.path);
                    },
                    selected: AppRoutes.viewSms.path ==
                        GoRouterState.of(context).uri.path,
                  ),
                ],
              ),
              ExpansionTile(
                title: const Text("SMS Campaign"),
                leading: const Icon(Icons.campaign),
                initiallyExpanded: AppRoutes.addBulkSms.path ==
                        GoRouterState.of(context).uri.path ||
                    AppRoutes.viewBulkSms.path ==
                        GoRouterState.of(context).uri.path,
                children: [
                  ListTile(
                    style: ListTileStyle.drawer,
                    visualDensity: VisualDensity.compact,
                    title: const Text("Add Bulk SMS"),
                    onTap: () {
                      widget.scaffoldKey.currentState!.openEndDrawer();
                      context.go(AppRoutes.addBulkSms.path);
                    },
                    selected: AppRoutes.addBulkSms.path ==
                        GoRouterState.of(context).uri.path,
                  ),
                  ListTile(
                    style: ListTileStyle.drawer,
                    visualDensity: VisualDensity.compact,
                    title: const Text("View Bulk SMS"),
                    onTap: () {
                      widget.scaffoldKey.currentState!.openEndDrawer();
                      context.go(AppRoutes.viewBulkSms.path);
                    },
                    selected: AppRoutes.viewBulkSms.path ==
                        GoRouterState.of(context).uri.path,
                  ),
                ],
              ),
              ExpansionTile(
                title: const Text("Audio Management"),
                leading: const Icon(Icons.audio_file),
                initiallyExpanded: AppRoutes.addAudio.path ==
                        GoRouterState.of(context).uri.path ||
                    AppRoutes.viewAudios.path ==
                        GoRouterState.of(context).uri.path,
                children: [
                  ListTile(
                    style: ListTileStyle.drawer,
                    visualDensity: VisualDensity.compact,
                    title: const Text("Add Audio"),
                    onTap: () {
                      widget.scaffoldKey.currentState!.openEndDrawer();
                      context.go(AppRoutes.addAudio.path);
                    },
                    selected: AppRoutes.addAudio.path ==
                        GoRouterState.of(context).uri.path,
                  ),
                  ListTile(
                    style: ListTileStyle.drawer,
                    visualDensity: VisualDensity.compact,
                    title: const Text("View Audios"),
                    onTap: () {
                      widget.scaffoldKey.currentState!.openEndDrawer();
                      context.go(AppRoutes.viewAudios.path);
                    },
                    selected: AppRoutes.viewAudios.path ==
                        GoRouterState.of(context).uri.path,
                  ),
                ],
              ),
              ExpansionTile(
                title: const Text("Missed Call Management"),
                leading: const Icon(Icons.call_missed),
                initiallyExpanded: [
                  AppRoutes.addOperator.path,
                  AppRoutes.viewMissCall.path,
                  AppRoutes.allOperators.path,
                ].any(
                    (element) => element == GoRouterState.of(context).uri.path),
                children: [
                  ///
                  /// Add Miss call operator
                  /// View->Edit->Change Miss call operator
                  /// All Miss calls -> Download CSV & Excel
                  ListTile(
                    style: ListTileStyle.drawer,
                    visualDensity: VisualDensity.compact,
                    title: const Text("All Operators"),
                    onTap: () {
                      widget.scaffoldKey.currentState!.openEndDrawer();
                      context.go(AppRoutes.allOperators.path);
                    },
                    selected: AppRoutes.allOperators.path ==
                        GoRouterState.of(context).uri.path,
                  ),
                  ListTile(
                    style: ListTileStyle.drawer,
                    visualDensity: VisualDensity.compact,
                    title: const Text("Add Operator"),
                    onTap: () {
                      widget.scaffoldKey.currentState!.openEndDrawer();
                      context.go(AppRoutes.addOperator.path);
                    },
                    selected: AppRoutes.addOperator.path ==
                        GoRouterState.of(context).uri.path,
                  ),
                  ListTile(
                    style: ListTileStyle.drawer,
                    visualDensity: VisualDensity.compact,
                    title: const Text("View Miss Calls"),
                    onTap: () {
                      widget.scaffoldKey.currentState!.openEndDrawer();
                      context.go(AppRoutes.viewMissCall.path);
                    },
                    selected: AppRoutes.viewMissCall.path ==
                        GoRouterState.of(context).uri.path,
                  ),
                ],
              ),
            ],
            if (context.read<AuthProvider>().isSuperuser)
              ListTile(
                leading: const Icon(Icons.person),
                style: ListTileStyle.drawer,
                visualDensity: VisualDensity.compact,
                title: const Text("Users"),
                selected:
                    AppRoutes.users.path == GoRouterState.of(context).uri.path,
                onTap: () {
                  widget.scaffoldKey.currentState!.openEndDrawer();
                  context.go(AppRoutes.users.path);
                },
              ),
            ListTile(
              style: ListTileStyle.drawer,
              visualDensity: VisualDensity.compact,
              leading: const Icon(Icons.lock),
              title: const Text("Reset Password"),
              onTap: _resetPassword,
            ),
            ExpansionTile(
              title: const Text("Api's"),
              leading: const Icon(Icons.api),
              children: [
                ListTile(
                  style: ListTileStyle.drawer,
                  visualDensity: VisualDensity.compact,
                  title: const Text("Add Api Key"),
                  onTap: _addApiKey,
                ),
                ListTile(
                  style: ListTileStyle.drawer,
                  visualDensity: VisualDensity.compact,
                  title: const Text("Api List"),
                  onTap: () {
                    widget.scaffoldKey.currentState!.openEndDrawer();
                    context.go(AppRoutes.apiList.path);
                  },
                  selected: AppRoutes.apiList.path ==
                      GoRouterState.of(context).uri.path,
                ),
              ],
            ),
            if (context.read<AuthProvider>().hasSuperuser)
              ListTile(
                style: ListTileStyle.drawer,
                visualDensity: VisualDensity.compact,
                leading: const Icon(Icons.logout_rounded),
                title: const Text("Back to Superuser"),
                onTap: () async {
                  await context.read<AuthProvider>().logoutUser();
                  if (mounted) {
                    context.go(AppRoutes.users.path);
                  }
                },
              )
            else
              ListTile(
                style: ListTileStyle.drawer,
                visualDensity: VisualDensity.compact,
                leading: const Icon(Icons.logout_rounded),
                title: const Text("Logout"),
                onTap: _logout,
              ),
          ],
        ),
      ),
    );
  }

  void _logout() {
    generalDialog(
      context: context,
      title: const Text("Alert"),
      content: const Text("Are you sure you want to logout?"),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text("No"),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<AuthProvider>().logout();
            context.go(AppRoutes.signIn.path);
          },
          child: const Text("Yes"),
        ),
      ],
    );
  }

  void _resetPassword() {
    final TextEditingController oldPassword = TextEditingController();
    final TextEditingController newPassword = TextEditingController();
    final TextEditingController confirmNewPassword = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    generalDialog(
      context: context,
      title: const Text("Reset Password"),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: oldPassword,
              decoration: const InputDecoration(
                hintText: "Old Password",
              ),
              validator: const Password.pure().validator,
            ),
            const Gap(10),
            TextFormField(
              controller: newPassword,
              decoration: const InputDecoration(
                hintText: "New Password",
              ),
              validator: const Password.pure().validator,
            ),
            const Gap(10),
            TextFormField(
              controller: confirmNewPassword,
              decoration: const InputDecoration(
                hintText: "Confirm New Password",
              ),
              validator: const Password.pure().validator,
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

            if (newPassword.text != confirmNewPassword.text && mounted) {
              QuickAlert.show(
                context: context,
                width: 200,
                type: QuickAlertType.warning,
                text: "Passwords do not match",
              );
              return;
            }

            context.read<HudProvider>().showProgress();

            final response = await locator<ApiClient>().changePassword(
              oldPassword: oldPassword.text,
              newPassword: newPassword.text,
            );
            if (mounted) {
              context
                ..pop()
                ..read<HudProvider>().hideProgress();
              QuickAlert.show(
                context: context,
                type: response.isSuccess
                    ? QuickAlertType.success
                    : QuickAlertType.error,
                width: 200,
                text: response.message,
              );
            }
          },
          child: const Text("Change Password"),
        ),
      ],
    );
  }

  void _addApiKey() {
    generalDialog(
      context: context,
      title: const Text("API Key"),
      content: StatefulBuilder(
        builder: (context, setState) {
          TextEditingController controller = TextEditingController();
          return FutureBuilder<Data<String>>(
            future: locator<ApiClient>().getApiKey(),
            builder: (context, snapshot) {
              controller.text = snapshot.data?.data ?? "";
              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "API Key",
                      suffixIcon: snapshot.data?.data != null
                          ? IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(
                                    text: snapshot.data!.data!,
                                  ),
                                );
                              },
                            )
                          : null,
                    ),
                    readOnly: true,
                  ),
                  const Gap(10),
                  ElevatedButton(
                    onPressed: () async {
                      final status = await generalDialog(
                        context: context,
                        title: const Text("Alert"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Are you sure, you want to generate a new token?",
                            ),
                            const Gap(10),
                            const Text.rich(
                              TextSpan(
                                text: 'Type',
                                children: [
                                  TextSpan(text: '"Generate Token"'),
                                ],
                              ),
                            ),
                            TextFormField(),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => context.pop(false),
                            child: const Text("No"),
                          ),
                          TextButton(
                            onPressed: () => context.pop(true),
                            child: const Text("Yes"),
                          ),
                        ],
                      );
                      if (status == false) {
                        return;
                      }

                      final response =
                          await locator<ApiClient>().generateApiKey();
                      if (response.isSuccess) {
                        setState(() {});
                      } else {
                        QuickAlert.show(
                          context: context,
                          width: 200,
                          type: QuickAlertType.error,
                          text: response.data!,
                        );
                      }
                    },
                    child: const Text("Refresh Key"),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Note: Refreshing key will invalidate the previous key",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
