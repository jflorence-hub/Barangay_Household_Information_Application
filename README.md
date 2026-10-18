# barangay_household_information_application

A Flutter household information application.

## API configuration

The app reads its backend URL from `API_BASE_URL` at build time.

- Android emulator (default):
  `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api`
- Physical device or ngrok tunnel:
  `flutter run --dart-define=API_BASE_URL=https://your-ngrok-domain/api`

If you are testing on a LAN-connected phone, replace the host with your machine's local IP address, for example:
`flutter run --dart-define=API_BASE_URL=http://192.168.1.12:8000/api`

## Getting Started

This project uses Flutter and the default app templates.

For Flutter setup and docs, see:
- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Flutter documentation](https://docs.flutter.dev/)
