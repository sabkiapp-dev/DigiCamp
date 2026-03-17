import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:digicamp_interface/src/commons/responsive_layout_builder.dart';
import 'package:digicamp_interface/src/config/app_constants.dart';
import 'package:digicamp_interface/src/providers/providers.dart';
import 'package:digicamp_interface/src/screens/navigation/navigation.dart';
import 'package:digicamp_interface/src/utils/extensions/size_extension.dart';

class NavigationView extends StatefulWidget {
  const NavigationView({
    super.key,
    required this.child,
  });
  final Widget child;

  @override
  State<NavigationView> createState() => _NavigationViewState();
}

class _NavigationViewState extends State<NavigationView> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: SizedBox(
        width: context.sw(0.8),
        child: Navigation(scaffoldKey: _scaffoldKey),
      ),
      body: SafeArea(
        child: Column(
          children: [
            ResponsiveLayoutBuilder(
              small: (context, constraints, child) {
                return AppBar(
                  title: _buildTitle(),
                );
              },
              large: (context, constraints, child) {
                return const SizedBox();
              },
            ),
            Expanded(
              child: ResponsiveLayoutBuilder(
                large: (context, constraints, child) {
                  return Row(
                    children: [
                      Navigation(scaffoldKey: _scaffoldKey),
                      Expanded(
                        child: widget.child,
                      ),
                    ],
                  );
                },
                small: (context, constraints, child) {
                  return widget.child;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    if (GoRouterState.of(context).uri.path == AppRoutes.dashboard.path) {
      return Text(
        context.read<AuthProvider>().userName != null
            ? "${context.read<AuthProvider>().userName}'s dashboard."
            : "Dashboard",
      );
    } else {
      return const SizedBox();
    }
  }
}
