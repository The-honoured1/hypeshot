import 'package:device_apps/device_apps.dart';

class GameService {
  static Future<List<Application>> getInstalledGames() async {
    // In a real scenario, we might want to filter by category
    // For this MVP, we provide all launchable user apps
    List<Application> apps = await DeviceApps.getInstalledApplications(
      onlyAppsWithLaunchIntent: true,
      includeSystemApps: false,
      includeAppIcons: false,
    );

    // Filter by game category
    apps.retainWhere((app) => app.category == ApplicationCategory.game);

    // Sort alphabetically
    apps.sort((a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));
    
    return apps;
  }

  static Future<void> launchGame(String packageName) async {
    await DeviceApps.openApp(packageName);
  }
}
