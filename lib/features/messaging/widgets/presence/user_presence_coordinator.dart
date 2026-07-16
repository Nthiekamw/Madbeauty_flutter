import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/providers/auth_notifier.dart';
import '../../../../services/supabase/profile/profile_providers.dart';

/// Met à jour `last_seen_at` quand l'app est au premier plan.
class UserPresenceCoordinator extends ConsumerStatefulWidget {
  const UserPresenceCoordinator({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<UserPresenceCoordinator> createState() =>
      _UserPresenceCoordinatorState();
}

class _UserPresenceCoordinatorState extends ConsumerState<UserPresenceCoordinator>
    with WidgetsBindingObserver {
  Timer? _heartbeat;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _touch());
    _heartbeat = Timer.periodic(const Duration(seconds: 60), (_) => _touch());
  }

  @override
  void dispose() {
    _heartbeat?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _touch();
    }
  }

  Future<void> _touch() async {
    final user = switch (ref.read(authNotifierProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (user == null) return;
    final service = ref.read(profileServiceProvider);
    if (service == null) return;
    try {
      await service.touchLastSeen(userId: user.id);
    } on Object {
      // Best-effort : timeout / session expirée ne doivent pas planter l’UI.
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
