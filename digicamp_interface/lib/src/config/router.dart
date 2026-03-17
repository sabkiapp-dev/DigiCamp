import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:digicamp_interface/src/config/app_constants.dart';
import 'package:digicamp_interface/src/providers/providers.dart';
import 'package:digicamp_interface/src/screens/api_list/api_list.dart';
import 'package:digicamp_interface/src/screens/audios/audios.dart';
import 'package:digicamp_interface/src/screens/campaigns/campaigns.dart';
import 'package:digicamp_interface/src/screens/dashboard/dashboard.dart';
import 'package:digicamp_interface/src/screens/miss_call/miss_call.dart';
import 'package:digicamp_interface/src/screens/navigation/navigation.dart';
import 'package:digicamp_interface/src/screens/sign_in/sign_in.dart';
import 'package:digicamp_interface/src/screens/sms/sms.dart';
import 'package:digicamp_interface/src/screens/user_hosts/user_hosts.dart';
import 'package:digicamp_interface/src/screens/users/users.dart';
import 'package:digicamp_interface/src/screens/view_contacts/view_contacts.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final router = GoRouter(
    redirect: _handleRedirect,
    routes: [
      GoRoute(
        path: "/",
        parentNavigatorKey: rootNavigatorKey,
        redirect: (context, state) {
          return AppRoutes.signIn.path;
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        name: AppRoutes.signIn.name,
        path: AppRoutes.signIn.path,
        builder: (context, state) => const SignInPage(),
      ),
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        routes: [
          GoRoute(
            parentNavigatorKey: shellNavigatorKey,
            name: AppRoutes.dashboard.name,
            path: AppRoutes.dashboard.path,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: const DashboardView(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              );
            },
          ),

          // Campaigns
          GoRoute(
            parentNavigatorKey: shellNavigatorKey,
            name: AppRoutes.addCampaign.name,
            path: AppRoutes.addCampaign.path,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: const AddCampaign(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            parentNavigatorKey: shellNavigatorKey,
            name: AppRoutes.viewCampaigns.name,
            path: AppRoutes.viewCampaigns.path,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: const ViewCampaigns(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            parentNavigatorKey: shellNavigatorKey,
            name: AppRoutes.selectCampaign.name,
            path: AppRoutes.selectCampaign.path,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: const ViewCampaigns(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            parentNavigatorKey: shellNavigatorKey,
            name: AppRoutes.updateCampaign.name,
            path: AppRoutes.updateCampaign.path,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: const AddCampaign(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            parentNavigatorKey: shellNavigatorKey,
            name: AppRoutes.dialPlan.name,
            path: AppRoutes.dialPlan.path,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: DialPlanPage(
                  id: int.parse(state.pathParameters['campaignId']!),
                ),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            parentNavigatorKey: shellNavigatorKey,
            name: AppRoutes.campaignReport.name,
            path: AppRoutes.campaignReport.path,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: CampaignReportPage(
                  campaignId: int.parse(state.pathParameters['campaignId']!),
                ),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            parentNavigatorKey: shellNavigatorKey,
            name: AppRoutes.campaignSummary.name,
            path: AppRoutes.campaignSummary.path,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: CampaignSummaryPage(
                  campaignId: int.parse(state.pathParameters['campaignId']!),
                ),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              );
            },
          ),

          // Contacts
          GoRoute(
            parentNavigatorKey: shellNavigatorKey,
            name: AppRoutes.addContacts.name,
            path: AppRoutes.addContacts.path,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: const AddContacts(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            parentNavigatorKey: shellNavigatorKey,
            name: AppRoutes.viewContacts.name,
            path: AppRoutes.viewContacts.path,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: const ViewContacts(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              );
            },
          ),

          // Users
          GoRoute(
            parentNavigatorKey: shellNavigatorKey,
            name: AppRoutes.users.name,
            path: AppRoutes.users.path,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: const UsersPage(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            parentNavigatorKey: shellNavigatorKey,
            name: AppRoutes.userHosts.name,
            path: AppRoutes.userHosts.path,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: UserHostsPage(
                  userId: int.parse(state.pathParameters['userId']!),
                ),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              );
            },
          ),

          // Audios
          GoRoute(
            parentNavigatorKey: shellNavigatorKey,
            name: AppRoutes.addAudio.name,
            path: AppRoutes.addAudio.path,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: const AddAudioPage(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            parentNavigatorKey: shellNavigatorKey,
            name: AppRoutes.viewAudios.name,
            path: AppRoutes.viewAudios.path,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: const ViewAudiosPage(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            parentNavigatorKey: shellNavigatorKey,
            name: AppRoutes.selectAudio.name,
            path: AppRoutes.selectAudio.path,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: const ViewAudiosPage(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              );
            },
          ),

          // Sms
          GoRoute(
            parentNavigatorKey: shellNavigatorKey,
            name: AppRoutes.addSms.name,
            path: AppRoutes.addSms.path,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: const AddSmsPage(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            parentNavigatorKey: shellNavigatorKey,
            name: AppRoutes.editSms.name,
            path: AppRoutes.editSms.path,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: const AddSmsPage(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            parentNavigatorKey: shellNavigatorKey,
            name: AppRoutes.viewSms.name,
            path: AppRoutes.viewSms.path,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: const ViewSmsPage(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            parentNavigatorKey: shellNavigatorKey,
            name: AppRoutes.selectSms.name,
            path: AppRoutes.selectSms.path,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: const ViewSmsPage(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            parentNavigatorKey: shellNavigatorKey,
            name: AppRoutes.addBulkSms.name,
            path: AppRoutes.addBulkSms.path,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: const AddBulkSmsPage(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            parentNavigatorKey: shellNavigatorKey,
            name: AppRoutes.updateBulkSms.name,
            path: AppRoutes.updateBulkSms.path,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: const AddBulkSmsPage(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            parentNavigatorKey: shellNavigatorKey,
            name: AppRoutes.viewBulkSms.name,
            path: AppRoutes.viewBulkSms.path,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: const ViewBulkSmsPage(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              );
            },
          ),

          // Miss Calls
          GoRoute(
            parentNavigatorKey: shellNavigatorKey,
            name: AppRoutes.addOperator.name,
            path: AppRoutes.addOperator.path,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: const AddOperator(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            parentNavigatorKey: shellNavigatorKey,
            name: AppRoutes.viewMissCall.name,
            path: AppRoutes.viewMissCall.path,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: const ViewMissCallPage(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            parentNavigatorKey: shellNavigatorKey,
            name: AppRoutes.allOperators.name,
            path: AppRoutes.allOperators.path,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: const AllOperators(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              );
            },
          ),

          GoRoute(
            parentNavigatorKey: shellNavigatorKey,
            name: AppRoutes.apiList.name,
            path: AppRoutes.apiList.path,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: const ApiListPage(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              );
            },
          ),
        ],
        builder: (context, state, child) {
          return NavigationView(child: child);
        },
      ),
    ],
    navigatorKey: rootNavigatorKey,
  );

  static FutureOr<String?> _handleRedirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final superUserRestrictions = [
      AppRoutes.dashboard.path,
      AppRoutes.addCampaign.path,
      AppRoutes.updateCampaign.path,
      AppRoutes.viewCampaigns.path,
      AppRoutes.addAudio.path,
      AppRoutes.viewAudios.path,
      AppRoutes.dialPlan.path,
      AppRoutes.campaignReport.path,
      AppRoutes.addContacts.path,
      AppRoutes.viewContacts.path,
      AppRoutes.addSms.path,
      AppRoutes.viewSms.path,
      AppRoutes.allOperators.path,
      AppRoutes.addOperator.path,
      AppRoutes.viewMissCall.path,
    ];
    final userRestrictions = [
      AppRoutes.users.path,
      AppRoutes.userHosts.path,
    ];
    if (context.read<AuthProvider>().isAuthenticated) {
      if (context.read<AuthProvider>().isSuperuser &&
          superUserRestrictions.contains(state.uri.path)) {
        return AppRoutes.users.path;
      }
      if (!context.read<AuthProvider>().isSuperuser &&
          userRestrictions.contains(state.uri.path)) {
        return AppRoutes.dashboard.path;
      }
      if (state.uri.path == AppRoutes.signIn.path) {
        if (context.read<AuthProvider>().isSuperuser) {
          return AppRoutes.users.path;
        }
        return AppRoutes.dashboard.path;
      } else {
        return null;
      }
    } else {
      return AppRoutes.signIn.path;
    }
  }
}
