import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../blocs/map/map_state.dart';

/// A button that cycles through rotation lock modes with appropriate icons
class RotationLockButton extends StatelessWidget {
  final RotationMode rotationMode;
  final double mapRotation;
  final VoidCallback onPressed;

  const RotationLockButton({
    super.key,
    required this.rotationMode,
    required this.mapRotation,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'rotation_lock',
      onPressed: onPressed,
      child: _buildIcon(),
    );
  }

  Widget _buildIcon() {
    switch (rotationMode) {
      case RotationMode.free:
        // Show compass needle rotating with the map
        return Transform.rotate(
          angle: mapRotation * math.pi / 180,
          child: const Icon(Icons.navigation),
        );
      case RotationMode.northOriented:
        // Show compass needle pointing north
        return const Icon(Icons.navigation);
      case RotationMode.locked:
        // Show lock icon
        return const Icon(Icons.lock);
    }
  }
}
