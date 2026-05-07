import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(AppStrings.screenBooking)),
    );
  }
}
