import 'dart:async';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';
import 'controllers/auth_controller.dart';

part 'views/auth_views.dart';
part 'views/home_view.dart';
part 'views/records_view.dart';
part 'views/upcoming_view.dart';
part 'views/profile_view.dart';
part 'views/messages_view.dart';
part 'views/qr_view.dart';

String reliefQuantitySummary(Map<String, dynamic> d) {
  final mainQuantity = d['quantity'] ?? '—';
  final additional = (d['additional_resource'] ??
      d['additionalResource'] ??
      d['additional_resource_item']) as Map?;
  final lines = <String>['Quantity: $mainQuantity'];
  final additionalName = additional?['name']?.toString();
  final additionalQuantity = d['additional_quantity'];
  if (additionalName != null &&
      additionalName.isNotEmpty &&
      additionalQuantity != null) {
    lines.add(
        'Additional relief: $additionalName • Quantity: $additionalQuantity');
  }
  return lines.join('\n');
}

String distributionReliefName(Map<String, dynamic> d) {
  final resourceSet = (d['resource_set'] ?? d['resourceSet']) as Map?;
  final resource = d['resource'] as Map?;
  return resourceSet?['name']?.toString() ??
      resource?['name']?.toString() ??
      'Relief not assigned';
}

void main() => runApp(const FamilyApp());

class FamilyApp extends StatelessWidget {
  const FamilyApp({super.key});

  @override
  Widget build(BuildContext c) => MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Barangay Household Portal',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff2563eb)),
        scaffoldBackgroundColor: const Color(0xfff6f8fc),
        appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xffffffff),
            foregroundColor: Color(0xff0f172a),
            elevation: 0),
        cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: Color(0xffe8edf5)))),
        inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xffdbe3ef))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xffdbe3ef))),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13)),
        filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xff2563eb),
                foregroundColor: Colors.white,
                minimumSize: const Size(44, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)))),
      ),
      home: const LoginPage());
}

// â”€â”€â”€ Constants shared with login â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

const _blue = Color(0xff2563eb);
const _ink = Color(0xff0f172a);
const _muted = Color(0xff64748b);
const _canvas = Color(0xfff6f8fc);

// â”€â”€â”€ Family App logo â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
