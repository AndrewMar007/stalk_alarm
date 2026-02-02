import 'package:flutter/material.dart';
import 'package:stalc_alarm/core/network/internet_guard.dart';

Future<void> showNoInternetDialog(BuildContext context) async {
  if (!context.mounted) return;

  // ✅ щоб не показувати 10 діалогів при частих тапах
  if (ModalRoute.of(context)?.isCurrent == false) return;

  // return showDialog<void>(
  //   context: context,
  //   builder: (ctx) => AlertDialog(
  //     title: const Text("Немає з’єднання"),
  //     content: const Text("Немає інтернет зʼєднання.\nПеревірте мережу і спробуйте ще раз."),
  //     actions: [
  //       TextButton(
  //         onPressed: () => Navigator.of(ctx).pop(),
  //         child: const Text("Ок"),
  //       ),
  //     ],
  //   ),
  // );
}

Future<void> runIfOnline(
  BuildContext context, {
  required InternetGuard net,
  required Future<void> Function() action,
}) async {
  final ok = await net.checkNow();
  if (!context.mounted) return;

  if (!ok) {
    await showNoInternetDialog(context);
    return;
  }

  await action();
}
