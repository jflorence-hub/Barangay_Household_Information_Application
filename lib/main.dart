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
part 'views/announcements_view.dart';

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
        textTheme: Typography.material2021().black.apply(
              bodyColor: const Color(0xff0f172a),
              displayColor: const Color(0xff0f172a),
            ),
        appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xffffffff),
            foregroundColor: Color(0xff0f172a),
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: false),
        cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: Color(0xffe8edf5)))),
        navigationBarTheme: NavigationBarThemeData(
          height: 70,
          backgroundColor: Colors.white,
          elevation: 0,
          indicatorColor: const Color(0xffdbeafe),
          labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
                fontSize: 11,
                fontWeight: states.contains(WidgetState.selected)
                    ? FontWeight.w700
                    : FontWeight.w500,
              )),
        ),
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
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xff2563eb),
            side: const BorderSide(color: Color(0xffbfdbfe)),
            minimumSize: const Size(44, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const LoginPage());
}

// â”€â”€â”€ Constants shared with login â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

const _blue = Color(0xff2563eb);
const _ink = Color(0xff0f172a);
const _muted = Color(0xff64748b);
const _canvas = Color(0xfff6f8fc);

class _PageIntro extends StatelessWidget {
  const _PageIntro({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.eyebrow,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? eyebrow;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xffe8edf5)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xffeff6ff),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: _blue, size: 23),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (eyebrow != null) ...[
                    Text(
                      eyebrow!.toUpperCase(),
                      style: const TextStyle(
                        color: _blue,
                        fontSize: 10,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                  ],
                  Text(
                    title,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

// â”€â”€â”€ Family App logo â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
