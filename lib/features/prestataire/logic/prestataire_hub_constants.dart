import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/default_avatar_urls.dart';
import '../widgets/profile/hub/prestataire_hub_layout.dart';

abstract final class PrestataireHubConstants {
  PrestataireHubConstants._();

  static const galleryMaxPhotos = 10;
  static const galleryMaxVideos = 3;
  static const wizardStepCount = 7;
  static const optionalFromStep = 4;

  static const defaultAvatarUrls = DefaultAvatarUrls.urls;
}

const List<PrestataireHubStepMeta> kPrestataireHubSteps = [
  PrestataireHubStepMeta(
    title: DiscPrestaForm.stepBasics,
    icon: Icons.storefront_outlined,
  ),
  PrestataireHubStepMeta(
    title: DiscPrestaForm.stepLocation,
    icon: Icons.location_on_outlined,
  ),
  PrestataireHubStepMeta(
    title: DiscPrestaForm.stepServices,
    icon: Icons.content_cut_rounded,
  ),
  PrestataireHubStepMeta(
    title: DiscPrestaForm.stepHoraires,
    icon: Icons.schedule_rounded,
  ),
  PrestataireHubStepMeta(
    title: DiscPrestaForm.stepGallery,
    icon: Icons.photo_camera_outlined,
  ),
  PrestataireHubStepMeta(
    title: DiscPrestaForm.stepComfort,
    icon: Icons.favorite_rounded,
  ),
  PrestataireHubStepMeta(
    title: DiscPrestaForm.stepSubscription,
    icon: Icons.card_membership_outlined,
  ),
];
