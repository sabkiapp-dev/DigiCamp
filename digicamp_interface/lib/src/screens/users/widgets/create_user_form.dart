import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:digicamp_interface/src/providers/providers.dart';

class CreateUserForm extends StatefulWidget {
  const CreateUserForm({super.key});

  @override
  State<CreateUserForm> createState() => _CreateUserFormState();
}

class _CreateUserFormState extends State<CreateUserForm> {
  late AuthProvider _authProvider;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _authProvider = context.read<AuthProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            decoration: const InputDecoration(
              hintText: "Name",
            ),
            onChanged: _authProvider.onNameChanged,
            validator: _authProvider.name.validator,
          ),
          const Gap(10),
          TextFormField(
            decoration: const InputDecoration(
              hintText: "Mobile Number",
            ),
            onChanged: _authProvider.onMobileChange,
            validator: _authProvider.mobile.validator,
            keyboardType: TextInputType.phone,
          ),
          const Gap(10),
          TextFormField(
            obscureText: true,
            decoration: const InputDecoration(
              hintText: "Password",
            ),
            onChanged: _authProvider.onPasswordChanged,
            validator: _authProvider.password.validator,
          ),
          const Gap(10),
          TextFormField(
            obscureText: true,
            decoration: const InputDecoration(
              hintText: "Confirm Password",
            ),
            onChanged: _authProvider.onConfirmPasswordChanged,
            validator: _authProvider.confirmPassword.validator,
          ),
          const Gap(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text("Cancel"),
              ),
              const Gap(10),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                  context.read<HudProvider>().showProgress();
                  final response =
                      await context.read<AuthProvider>().createUser();
                  if (mounted && response) {
                    context.pop();
                  }
                  if (mounted) {
                    context.read<HudProvider>().hideProgress();
                    QuickAlert.show(
                      context: context,
                      width: 200,
                      type: response
                          ? QuickAlertType.success
                          : QuickAlertType.error,
                      text: _authProvider.message,
                    );
                  }
                },
                child: const Text("Add"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
