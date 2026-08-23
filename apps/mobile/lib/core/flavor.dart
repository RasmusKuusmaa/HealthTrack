enum AppFlavor { dev, staging, production }

class AppConfig {
  const AppConfig({required this.flavor, required this.apiBaseUrl});

  final AppFlavor flavor;
  final String apiBaseUrl;

  static late final AppConfig instance;
}
