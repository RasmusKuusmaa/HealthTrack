import 'core/flavor.dart';
import 'main.dart';

void main() {
  bootstrap(
    const AppConfig(flavor: AppFlavor.dev, apiBaseUrl: 'http://10.0.2.2:8001'),
  );
}
