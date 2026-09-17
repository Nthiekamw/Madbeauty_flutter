import 'package:flutter/material.dart';

/// Icônes Material **outlined / filled** (pas `_rounded`).
/// Évite le look template IA (home, search, chat bubble, person).
abstract final class AppIcons {
  AppIcons._();

  static const home = Icons.cottage_outlined;
  static const homeFilled = Icons.cottage;

  static const search = Icons.travel_explore_outlined;
  static const searchFilled = Icons.travel_explore;

  static const reels = Icons.slow_motion_video_outlined;
  static const reelsFilled = Icons.slow_motion_video;

  static const messages = Icons.forum_outlined;
  static const messagesFilled = Icons.forum;

  static const profile = Icons.badge_outlined;
  static const profileFilled = Icons.badge;

  static const dashboard = Icons.ssid_chart_outlined;
  static const dashboardFilled = Icons.ssid_chart;

  static const agenda = Icons.event_available_outlined;
  static const agendaFilled = Icons.event_available;

  static const clients = Icons.diversity_3_outlined;
  static const clientsFilled = Icons.diversity_3;

  static const storefront = Icons.storefront_outlined;
  static const boutique = Icons.local_mall_outlined;
  static const reviews = Icons.reviews_outlined;
  static const account = Icons.manage_accounts_outlined;
  static const mail = Icons.alternate_email;
  static const phone = Icons.phone_iphone_outlined;
  static const city = Icons.holiday_village_outlined;
  static const palette = Icons.tonality;
  static const prefs = Icons.tune;
  static const bookmark = Icons.bookmarks_outlined;
  static const reservations = Icons.event_seat_outlined;
  static const cart = Icons.shopping_basket_outlined;
  static const orders = Icons.receipt_long_outlined;
  static const history = Icons.history_edu_outlined;
  static const loyalty = Icons.workspace_premium_outlined;
  static const wishlist = Icons.favorite_border;
  static const referral = Icons.handshake_outlined;
  static const bug = Icons.pest_control_outlined;
  static const help = Icons.menu_book_outlined;
  static const support = Icons.headset_mic_outlined;
  static const signOut = Icons.logout;
  static const photo = Icons.add_a_photo_outlined;
  static const edit = Icons.draw_outlined;
  static const admin = Icons.policy_outlined;
  static const shield = Icons.verified_user_outlined;
  static const flag = Icons.outlined_flag;
  static const hub = Icons.grid_view_outlined;
  static const swapSpace = Icons.sync_alt;
  static const creditCard = Icons.account_balance_wallet_outlined;
  static const notifications = Icons.notifications_none_outlined;
  static const location = Icons.near_me_outlined;
  static const fingerprint = Icons.fingerprint;
  static const faceId = Icons.face_6_outlined;
  static const cloudOff = Icons.signal_wifi_statusbar_connected_no_internet_4;
}
