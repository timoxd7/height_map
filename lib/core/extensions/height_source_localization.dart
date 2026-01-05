import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../data/models/models.dart';

/// Extension to provide localized names for HeightSource
extension HeightSourceLocalization on HeightSource {
  /// Get the localized display name for this source
  String localizedName(BuildContext context) {
    switch (this) {
      case HeightSource.gps:
        return 'sensors.gps.name'.tr();
      case HeightSource.barometer:
        return 'sensors.barometer.name'.tr();
      case HeightSource.api:
        return 'sensors.api.name'.tr();
      case HeightSource.unknown:
        return 'sensors.unknownSource.name'.tr();
    }
  }

  /// Get the localized description for this source
  String localizedDescription(BuildContext context) {
    switch (this) {
      case HeightSource.gps:
        return 'sensors.gps.description'.tr();
      case HeightSource.barometer:
        return 'sensors.barometer.description'.tr();
      case HeightSource.api:
        return 'sensors.api.description'.tr();
      case HeightSource.unknown:
        return 'sensors.unknownSource.description'.tr();
    }
  }
}
