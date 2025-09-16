# Rental

Rental app for landlords

## Overview

This Flutter application demonstrates a rental management dashboard that uses the GetX
package to expose a global theme controller and manage remote data workflows.

Key features include:

- Global light/dark theming handled through a shared GetX `ThemeController`.
- Property update form backed by GetX that uploads data to `jsonplaceholder.typicode.com`.
- Download of remote updates with live refresh feedback.

## Getting started

1. Install [Flutter](https://flutter.dev/docs/get-started/install) (version 3.10 or newer is recommended).
2. Fetch the project dependencies:

   ```bash
   flutter pub get
   ```

3. Run the application on a simulator, emulator, or connected device:

   ```bash
   flutter run
   ```

The home screen contains a form for posting updates and a list of downloaded entries. Use the
toggle in the app bar to switch between light and dark themes at runtime.
