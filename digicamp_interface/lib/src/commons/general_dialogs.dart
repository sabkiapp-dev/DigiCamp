import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:digicamp_interface/src/utils/extensions/size_extension.dart';
import 'package:digicamp_interface/src/utils/palette.dart';

Future<T?> generalDialog<T>({
  required BuildContext context,
  Widget? title,
  required Widget content,
  List<Widget>? actions,
  bool useRootNavigator = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor:
              Theme.of(context).brightness == Brightness.dark
                  ? const Color.fromRGBO(113, 113, 113, 1)
                  : const Color.fromRGBO(15, 15, 15, 1),
        ),
        child: AlertDialog(
          clipBehavior: Clip.hardEdge,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          titlePadding: title != null
              ? const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0)
              : EdgeInsets.zero,
          title: title != null
              ? SizedBox(
                  child: DefaultTextStyle(
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                    child: title,
                  ),
                )
              : null,
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: context.sh(0.5),
            ),
            child: content,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 16.0,
          ),
          actionsPadding: actions != null && actions.isNotEmpty
              ? const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0)
              : EdgeInsets.zero,
          actions: actions,
        ),
      );
    },
  );
}

Future<T?> generalSheet<T>({
  required BuildContext context,
  Widget? child,
  String? title,
}) {
  return showModalBottomSheet<T>(
    useRootNavigator: true,
    isScrollControlled: true,
    elevation: 2,
    context: context,
    shape: const RoundedRectangleBorder(),
    backgroundColor: Colors.transparent,
    builder: (context) {
      final statusHeight = MediaQuery.of(context).padding.top;
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: context.sh() - statusHeight - 80,
          ),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.background,
              boxShadow: const [
                BoxShadow(
                  color: Palette.shadowColor,
                  blurRadius: 7,
                ),
              ],
            ),
            child: Material(
              clipBehavior: Clip.hardEdge,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 4,
                    width: 40,
                    margin: const EdgeInsets.only(top: 10.0, bottom: 7.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2.0),
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withOpacity(0.33),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 10,
                      left: 10,
                      right: 10,
                    ),
                    child: Text(
                      title!,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Divider(height: 1),
                  Flexible(
                    child: SingleChildScrollView(
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
