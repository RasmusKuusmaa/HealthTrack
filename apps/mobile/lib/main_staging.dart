import 'core/flavor.dart';
import 'main.dart';

void main() {
  bootstrap(
    const AppConfig(
      flavor: AppFlavor.staging,
      apiBaseUrl: 'https://staging-api.healthtrack.internal',
    ),
  );
}
