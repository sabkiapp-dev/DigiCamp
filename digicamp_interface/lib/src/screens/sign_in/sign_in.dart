import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:digicamp_interface/src/config/app_constants.dart';
import 'package:digicamp_interface/src/providers/providers.dart';
import 'package:digicamp_interface/src/utils/extensions/size_extension.dart';
import 'package:digicamp_interface/src/utils/palette.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> _isVisible = ValueNotifier(false);
  late AuthProvider _authProvider;

  @override
  void initState() {
    _authProvider = context.read<AuthProvider>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 32.0,
            ),
            constraints: BoxConstraints(maxWidth: context.sw(0.7)),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: const [
                BoxShadow(
                  color: Palette.shadowColor,
                  blurRadius: 20,
                )
              ],
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Sign In",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    const Gap(15),
                    TextFormField(
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "Phone number",
                      ),
                      onChanged: _authProvider.onMobileChange,
                      validator: _authProvider.mobile.validator,
                    ),
                    const Gap(20),
                    ValueListenableBuilder(
                      valueListenable: _isVisible,
                      builder: (context, obscureText, child) {
                        return TextFormField(
                          obscureText: !obscureText,
                          decoration: InputDecoration(
                            labelText: "Password",
                            suffixIcon: IconButton(
                              onPressed: () {
                                _isVisible.value = !_isVisible.value;
                              },
                              icon: obscureText
                                  ? const Icon(
                                      Icons.remove_red_eye_rounded,
                                      color: Palette.primaryColor,
                                    )
                                  : Icon(
                                      Icons.remove_red_eye_rounded,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground
                                          .withOpacity(0.3),
                                    ),
                            ),
                          ),
                          onChanged: _authProvider.onPasswordChanged,
                          onEditingComplete: _signIn,
                          validator: _authProvider.password.validator,
                        );
                      },
                    ),
                    const Gap(30),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Selector<AuthProvider, bool>(
                        selector: (context, provider) => provider.isLoading,
                        builder: (context, value, child) {
                          return ElevatedButton(
                            onPressed: value ? null : _signIn,
                            child: Visibility(
                              visible: !value,
                              replacement: const SizedBox(
                                height: 15,
                                width: 15,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              child: const Text("Sign In"),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _signIn() async {
    if (_formKey.currentState!.validate()) {
      final result = await _authProvider.signIn();

      if (mounted && result) {
        Router.neglect(context, () => context.go(AppRoutes.dashboard.path));
      } else {
        if (mounted) {
          QuickAlert.show(
            context: context,
            width: 200,
            type: QuickAlertType.error,
            title: _authProvider.message!,
          );
        }
      }
    } else {
      print("Invalid input");
    }
  }
}
