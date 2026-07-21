import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend_app/core/constants.dart';


class AppTileLayer extends StatelessWidget {
  const AppTileLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return TileLayer(
      urlTemplate:
      'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}.png?api_key=${AppConstants.stadiaMapsApiKey}',
      userAgentPackageName: 'com.yourapp.frontend_app',
      maxNativeZoom: 18,
    );
  }
}