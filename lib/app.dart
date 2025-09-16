import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/rental_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/properties_screen.dart';
import 'screens/property_detail_screen.dart';
import 'screens/tenant_directory_screen.dart';
import 'screens/unit_detail_screen.dart';

class RentalApp extends StatelessWidget {
  const RentalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RentalProvider()..seedDemoData(),
      child: MaterialApp(
        title: 'Rental Manager',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
        ),
        initialRoute: DashboardScreen.routeName,
        routes: {
          DashboardScreen.routeName: (context) => const DashboardScreen(),
          PropertiesScreen.routeName: (context) => const PropertiesScreen(),
          TenantDirectoryScreen.routeName: (context) => const TenantDirectoryScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == PropertyDetailScreen.routeName) {
            final propertyId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) {
                final provider =
                    Provider.of<RentalProvider>(context, listen: false);
                final property = provider.findPropertyById(propertyId);
                return PropertyDetailScreen(property: property);
              },
            );
          }
          if (settings.name == UnitDetailScreen.routeName) {
            final args = settings.arguments as UnitDetailArguments;
            return MaterialPageRoute(
              builder: (context) => UnitDetailScreen(
                propertyId: args.propertyId,
                unitId: args.unitId,
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}
