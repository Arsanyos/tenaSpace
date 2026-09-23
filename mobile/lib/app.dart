import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/theme/tena_theme.dart';

class TenaSpaceApp extends ConsumerWidget {
  const TenaSpaceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'TenaSpace',
      debugShowCheckedModeBanner: false,
      theme: buildTenaTheme(),
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
