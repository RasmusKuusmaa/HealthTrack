import 'core/flavor.dart';
import 'main.dart';

void main() {
  bootstrap(
    const AppConfig(
      flavor: AppFlavor.production,
      apiBaseUrl: 'https://api.healthtrack.internal',
    ),
  );
}
