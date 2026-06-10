import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../profile/profile_providers.dart';
import '../supabase_service.dart';
import 'message_service.dart';
import 'messaging_service.dart';

final messageServiceProvider = Provider<MessageService?>((ref) {
  if (!AppConfig.hasSupabase) return null;
  return MessageService(SupabaseService.client);
});

final messagingServiceProvider = Provider<MessagingService?>((ref) {
  final messageService = ref.watch(messageServiceProvider);
  final profileService = ref.watch(profileServiceProvider);
  if (messageService == null || profileService == null) return null;
  return MessagingService(
    SupabaseService.client,
    messageService: messageService,
    profileService: profileService,
  );
});
