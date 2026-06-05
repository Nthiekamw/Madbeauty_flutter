import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';

/// Statut affiché côté client (indépendant des libellés bruts en base).
enum ClientReservationUiStatus {
  pending,
  syncPending,
  confirmed,
  done,
  cancelled,
  unknown,
}

ClientReservationUiStatus clientReservationUiStatusFromStatut(String raw) {
  final s = raw.trim().toLowerCase();
  if (const {'sync_pending'}.contains(s)) {
    return ClientReservationUiStatus.syncPending;
  }
  if (const {'en_attente', 'pending'}.contains(s)) {
    return ClientReservationUiStatus.pending;
  }
  if (const {
    'confirmee',
    'confirmée',
    'confirmed',
    'validee',
    'validée',
  }.contains(s)) {
    return ClientReservationUiStatus.confirmed;
  }
  if (const {
    'done',
    'terminee',
    'terminée',
    'termine',
    'terminé',
    'completed',
    'realisee',
    'réalisée',
  }.contains(s)) {
    return ClientReservationUiStatus.done;
  }
  if (const {
    'annulee',
    'annulée',
    'cancelled',
    'canceled',
  }.contains(s)) {
    return ClientReservationUiStatus.cancelled;
  }
  return ClientReservationUiStatus.unknown;
}

String clientReservationStatusLabel(ClientReservationUiStatus status) =>
    switch (status) {
      ClientReservationUiStatus.syncPending => DiscBk.badgeSyncPending,
      ClientReservationUiStatus.pending => DiscBk.badgePending,
      ClientReservationUiStatus.confirmed =>
        DiscBk.badgeConfirmed,
      ClientReservationUiStatus.done => DiscBk.badgeDone,
      ClientReservationUiStatus.cancelled =>
        DiscBk.badgeCancelled,
      ClientReservationUiStatus.unknown =>
        DiscBk.badgeUnknown,
    };

bool clientReservationCanCancel(ClientReservationUiStatus status) {
  return status == ClientReservationUiStatus.pending ||
      status == ClientReservationUiStatus.syncPending ||
      status == ClientReservationUiStatus.confirmed;
}

ChipStyleReservationStatus chipColorsForReservationStatus(
  ColorScheme cs,
  ClientReservationUiStatus status,
) {
  return switch (status) {
    ClientReservationUiStatus.syncPending => ChipStyleReservationStatus(
        backgroundColor: cs.surfaceContainerHighest,
        foregroundColor: cs.onSurfaceVariant,
      ),
    ClientReservationUiStatus.pending => ChipStyleReservationStatus(
        backgroundColor: cs.tertiaryContainer,
        foregroundColor: cs.onTertiaryContainer,
      ),
    ClientReservationUiStatus.confirmed => ChipStyleReservationStatus(
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
      ),
    ClientReservationUiStatus.done => ChipStyleReservationStatus(
        backgroundColor: cs.secondaryContainer,
        foregroundColor: cs.onSecondaryContainer,
      ),
    ClientReservationUiStatus.cancelled => ChipStyleReservationStatus(
        backgroundColor: cs.errorContainer,
        foregroundColor: cs.onErrorContainer,
      ),
    ClientReservationUiStatus.unknown => ChipStyleReservationStatus(
        backgroundColor: cs.surfaceContainerHighest,
        foregroundColor: cs.onSurfaceVariant,
      ),
  };
}

class ChipStyleReservationStatus {
  const ChipStyleReservationStatus({
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final Color backgroundColor;
  final Color foregroundColor;
}

