import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:digicamp_interface/injection_container.dart';
import 'package:digicamp_interface/src/commons/general_dialogs.dart';
import 'package:digicamp_interface/src/config/app_constants.dart';
import 'package:digicamp_interface/src/formz_model/formz_model.dart';
import 'package:digicamp_interface/src/models/models.dart';
import 'package:digicamp_interface/src/providers/providers.dart';
import 'package:digicamp_interface/src/screens/users/widgets/widgets.dart';
import 'package:digicamp_interface/src/utils/services/rest_api.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
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
              context.go(AppRoutes.signIn.path);
            },
            child: const Text("Login"),
          ),
        ],
      );
      context.go(AppRoutes.signIn.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder(
          future: locator<ApiClient>().getReferredUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
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
            return ListView.builder(
              itemCount: snapshot.data?.data?.length ?? 0,
              itemBuilder: (context, index) {
                final item = snapshot.data!.data![index];
                return ListTile(
                  onTap: () => context.go(
                    AppRoutes.userHosts.path.replaceAll(
                      ':userId',
                      item.id.toString(),
                    ),
                  ),
                  title: Text(
                    "${item.mobileNumber!} (${item.name!})",
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Created At: ${DateFormat("dd-MM-yyyy").format(item.createdAt!)}",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () async {
                          context.read<HudProvider>().showProgress();
                          final response = await context
                              .read<AuthProvider>()
                              .loginUser(item.id!);
                          if (mounted) {
                            context.read<HudProvider>().hideProgress();
                            if (response) {
                              context.go(AppRoutes.dashboard.path);
                            }
                          }
                        },
                        tooltip: "Login to ${item.name}'s dashboard",
                        icon: const Icon(Icons.login),
                      ),
                      IconButton(
                        onPressed: () => _changePassword(item),
                        tooltip: "Change Password",
                        icon: const Icon(Icons.lock),
                      ),
                      StatefulBuilder(
                        builder: (context, setState) {
                          if (item.status == 1) {
                            return IconButton(
                              onPressed: () => _changeStatus(
                                user: item,
                                setState: setState,
                              ),
                              tooltip: "Deactivate",
                              icon: const Icon(Icons.person_off_rounded),
                            );
                          } else {
                            return IconButton(
                              onPressed: () => _changeStatus(
                                user: item,
                                setState: setState,
                              ),
                              tooltip: "Activate",
                              icon: const Icon(Icons.person),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: _createUser,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  void _changePassword(RefUserModel item) {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    String? password;
    String? confirmPassword;
    generalDialog(
      context: context,
      title: const Text("Change Password"),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                hintText: "Password",
              ),
              validator: const Password.dirty().validator,
              onChanged: (value) => password = value,
              obscureText: true,
            ),
            const Gap(10),
            TextFormField(
              decoration: const InputDecoration(
                hintText: "Confirm Password",
              ),
              validator: const Password.dirty().validator,
              onChanged: (value) => confirmPassword = value,
              obscureText: true,
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
            if (password != confirmPassword) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Password doesn't matched"),
                ),
              );
              return;
            }
            context.read<HudProvider>().showProgress();
            final response = await locator<ApiClient>().resetPassword(
              mobileNumber: item.mobileNumber!,
              password: password!,
            );
            if (mounted && response.isSuccess) {
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Password changed"),
                ),
              );
            } else if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Something went wrong"),
                ),
              );
            }
            context.read<HudProvider>().hideProgress();
          },
          child: const Text("Change Password"),
        ),
      ],
    );
  }

  void _changeStatus({
    required RefUserModel user,
    required StateSetter setState,
  }) async {
    context.read<HudProvider>().showProgress();
    final status = user.status == 1 ? 0 : 1;
    final response = await locator<ApiClient>().changeStatus(
      status: status,
      mobileNumber: user.mobileNumber!,
    );
    if (!mounted) {
      return;
    }
    if (response.isSuccess) {
      user.status = status;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.message,
          ),
        ),
      );
    }
    context.read<HudProvider>().hideProgress();
  }

  void _createUser() async {
    await generalDialog(
      context: context,
      title: const Text("Create User"),
      content: const CreateUserForm(),
    );
    setState(() {});
  }
}
