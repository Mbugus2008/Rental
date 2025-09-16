# Rental Manager

Rental Manager is a Flutter application designed to help landlords organize properties, track tenants, and stay ahead of payment schedules. The project ships with realistic demo data so you can explore the experience immediately after running the app.

## Key features

- **Portfolio dashboard** with occupancy, income, upcoming and overdue payment summaries.
- **Property management** flows to add properties and units with essential details such as rent amounts, bedrooms, and bathrooms.
- **In-memory leasing** that lets you assign tenants, define lease dates, capture deposits, and automatically build payment schedules.
- **Payment tracking** with quick actions to record new charges or mark existing ones as paid.
- **Tenant directory** aggregating contact information, property context, and payment status for every active lease.

## Getting started

1. Ensure the [Flutter SDK](https://docs.flutter.dev/get-started/install) is installed and available in your `PATH`.
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application on an available emulator or device:
   ```bash
   flutter run
   ```

The seeded sample data appears on first launch. You can add new properties, units, tenants, and payments without any backend configuration—the application stores state in memory for demonstration purposes.

## Project structure

```
lib/
├── app.dart                  # Root widget with navigation setup
├── main.dart                 # Entry point
├── models/                   # Data models for properties, units, leases, tenants, and payments
├── providers/                # ChangeNotifier providing rental domain state
├── screens/                  # UI screens (dashboard, properties, units, tenants)
├── utils/                    # Shared formatting helpers
└── widgets/                  # Reusable forms and UI components
```

### Adding real persistence

The current implementation focuses on demonstrating UI flows and state management. To connect the app to a real backend or local database you can:

- Replace the in-memory `RentalProvider` with API or database calls.
- Store identifiers returned from the backend instead of generated IDs.
- Swap the demo `seedDemoData` method with remote fetch logic or on-device storage such as `sqflite` or `hive`.

## License

This project is provided as-is for demonstration and can be adapted for your production needs.
