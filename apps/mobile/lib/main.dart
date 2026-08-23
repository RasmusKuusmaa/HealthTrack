import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/flavor.dart';
import 'core/router.dart';
import 'ui/theme/app_theme.dart';

void main() {
  bootstrap(
    const AppConfig(flavor: AppFlavor.dev, apiBaseUrl: 'http://10.0.2.2:8001'),
  );
}

void bootstrap(AppConfig config) {
  AppConfig.instance = config;
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'HealthTrack',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
