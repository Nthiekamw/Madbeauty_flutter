import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/domain/user/user_profile.dart';
import '../../../services/supabase/profile/profile_providers.dart';
import '../../auth/providers/auth_notifier.dart';

/// Profil `user_profiles` de l'utilisateur connecté.
final currentUserProfileProvider =
    FutureProvider.autoDispose<UserProfile?>((ref) async {
      final auth = ref.watch(authNotifierProvider);
      final user = switch (auth) {
        AsyncData(:final value) => value,
        _ => null,
      };
      if (user == null) return null;

      final service = ref.watch(profileServiceProvider);
      if (service == null) return null;
      return service.getByUserId(user.id);
    });
