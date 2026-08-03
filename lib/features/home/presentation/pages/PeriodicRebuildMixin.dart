import 'dart:async';
import 'package:flutter/material.dart';

/// Mix into any State that needs to periodically rebuild so time-based
/// getters (like business.isOpen) stay live instead of freezing at
/// whatever was true on last build.
mixin PeriodicRebuildMixin<T extends StatefulWidget> on State<T> {
  Timer? _periodicRebuildTimer;

  /// Override to change the interval (default 30s).
  Duration get periodicRebuildInterval => const Duration(seconds: 30);

  void startPeriodicRebuild() {
    _periodicRebuildTimer = Timer.periodic(periodicRebuildInterval, (_) {
      if (mounted) setState(() {});
    });
  }

  void stopPeriodicRebuild() {
    _periodicRebuildTimer?.cancel();
  }
}