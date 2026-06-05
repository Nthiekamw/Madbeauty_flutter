import 'dart:io';

import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/errors/supabase_service_exception.dart';

/// Erreurs métier explicites lors de la création d'une réservation.
sealed class BookingCreateFailure extends AppFailure {
  const BookingCreateFailure(super.message, {super.cause});
}

final class BookingSlotTakenFailure extends BookingCreateFailure {
  const BookingSlotTakenFailure()
      : super(DiscBk.errSlotTaken);
}

final class BookingClientProfileMissingFailure extends BookingCreateFailure {
  const BookingClientProfileMissingFailure()
      : super(DiscBk.errNeedClientProfile);
}

final class BookingNotAuthenticatedFailure extends BookingCreateFailure {
  const BookingNotAuthenticatedFailure()
      : super(DiscBk.errNeedLogin);
}

final class BookingCannotReserveOwnServiceFailure extends BookingCreateFailure {
  const BookingCannotReserveOwnServiceFailure()
      : super(DiscBk.cannotBookOwnShort);
}

/// Liste de réservations demandée avec un clientId différent du compte connecté.
final class BookingForbiddenLookupFailure extends AppFailure {
  const BookingForbiddenLookupFailure()
      : super(DiscBk.errForbiddenBookingsLookup);
}

String bookingCreateFailureMessage(Object error) {
  if (error is BookingCreateFailure) return error.message;
  if (error is BookingForbiddenLookupFailure) return error.message;
  if (error is AppFailure) return error.message;
  if (error is SupabaseServiceException) {
    return _fromSupabase(error);
  }
  if (error is SocketException) {
    return DiscBk.errOffline;
  }
  final text = error.toString().toLowerCase();
  if (text.contains('socket') ||
      text.contains('network') ||
      text.contains('connection') ||
      text.contains('host lookup') ||
      text.contains('failed to connect')) {
    return DiscBk.errOffline;
  }
  return DiscBk.errGenericSave;
}

String _fromSupabase(SupabaseServiceException error) {
  final code = error.code?.trim();
  final message = error.message.toLowerCase();
  if (code == '42501' || message.contains('permission')) {
    return DiscBk.errNeedLogin;
  }
  if (code == '23505' ||
      message.contains('duplicate') ||
      message.contains('unique') ||
      message.contains('conflict')) {
    return DiscBk.errSlotTaken;
  }
  if (message.contains('referral_discount_not_available') ||
      message.contains('referral_discount_amount_mismatch')) {
    return DiscBk.errReferralDiscountExpired;
  }
  if (message.contains('network') ||
      message.contains('connection') ||
      message.contains('timeout')) {
    return DiscBk.errOffline;
  }
  final trimmed = error.message.trim();
  if (trimmed.isNotEmpty) return trimmed;
  return DiscBk.errGenericSave;
}

