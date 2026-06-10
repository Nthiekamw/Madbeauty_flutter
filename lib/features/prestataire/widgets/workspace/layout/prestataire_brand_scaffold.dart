import 'package:flutter/material.dart';

import '../../../../../shared/widgets/discovery/discovery_brand_scaffold.dart';

/// Corps d'écran prestataire avec le fond brand (blobs crème / marron), aligné accueil client.
class PrestataireBrandScaffold extends StatelessWidget {
  const PrestataireBrandScaffold({
    super.key,
    required this.body,
    this.appBar,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    if (appBar == null) {
      return DiscoveryBrandScaffold(body: body);
    }

    return DiscoveryBrandScaffold(
      body: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        body: body,
      ),
    );
  }
}

/// AppBar translucide pour laisser voir le fond brand.
AppBar prestataireBrandAppBar({
  required BuildContext context,
  required Widget title,
  List<Widget>? actions,
  PreferredSizeWidget? bottom,
  Widget? leading,
  bool automaticallyImplyLeading = true,
}) {
  return AppBar(
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    scrolledUnderElevation: 0,
    elevation: 0,
    automaticallyImplyLeading: automaticallyImplyLeading,
    title: title,
    actions: actions,
    bottom: bottom,
    leading: leading,
  );
}
