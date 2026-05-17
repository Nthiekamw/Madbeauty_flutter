import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/user_role.dart';
import 'auth_notifier.dart';

/// Rôles serveur pour l’utilisateur connecté (table `user_roles`).
final myRolesProvider = FutureProvider<List<UserRole>>((ref) async {
  if (!ref.watch(authSupabaseEnabledProvider)) return const [];
  final auth = ref.watch(authNotifierProvider);
  final user = switch (auth) {
    AsyncData(:final value) => value,
    _ => null,
  };
  if (user == null) return const [];
  return ref.read(roleServiceProvider).getMyRoles();
});
