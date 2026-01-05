import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:ui' as ui;
import '../../core/constants/app_constants.dart';
import '../../data/models/models.dart';
import '../blocs/blocs.dart';

/// Interactive map widget for displaying location and selecting points
class HeightMapView extends StatefulWidget {
  const HeightMapView({super.key});

  @override
  State<HeightMapView> createState() => _HeightMapViewState();
}

class _HeightMapViewState extends State<HeightMapView> {
  final MapController _mapController = MapController();
  bool _isFirstLocation = true;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LocationBloc, LocationState>(
          listener: (context, state) {
            debugPrint(
              '[HeightMapView] LocationBloc state: ${state.runtimeType}',
            );
            if (state is LocationLoaded) {
              debugPrint(
                '[HeightMapView] Location loaded: ${state.currentPosition.latitude}, ${state.currentPosition.longitude}',
              );
              // Update map bloc with new position
              context.read<MapBloc>().add(
                UpdateUserPosition(state.currentPosition),
              );

              // Center on first location
              if (_isFirstLocation) {
                _isFirstLocation = false;
                debugPrint('[HeightMapView] First location - centering map');
                _animateToPosition(state.currentPosition);
              }
            }
          },
        ),
        BlocListener<MapBloc, MapState>(
          listenWhen: (previous, current) {
            // Only listen when shouldCenterOnUser changes from false to true
            final prevCenter = previous is MapReady
                ? previous.shouldCenterOnUser
                : false;
            final currCenter = current is MapReady
                ? current.shouldCenterOnUser
                : false;
            debugPrint(
              '[HeightMapView] MapBloc listenWhen: prev=$prevCenter, curr=$currCenter',
            );
            return currCenter && !prevCenter;
          },
          listener: (context, state) {
            debugPrint(
              '[HeightMapView] MapBloc listener triggered: ${state.runtimeType}',
            );
            if (state is MapReady && state.userPosition != null) {
              debugPrint(
                '[HeightMapView] Centering on user: ${state.userPosition!.latitude}, ${state.userPosition!.longitude}',
              );
              _animateToPosition(state.userPosition!);
            } else {
              final userPos = state is MapReady ? state.userPosition : null;
              debugPrint(
                '[HeightMapView] Cannot center - state: $state, userPosition: $userPos',
              );
            }
          },
        ),
        BlocListener<MapBloc, MapState>(
          listenWhen: (previous, current) {
            // Listen for rotation changes
            final prevRotation = previous is MapReady ? previous.mapRotation : 0.0;
            final currRotation = current is MapReady ? current.mapRotation : 0.0;
            return prevRotation != currRotation;
          },
          listener: (context, state) {
            if (state is MapReady) {
              debugPrint('[HeightMapView] Rotating map to ${state.mapRotation} degrees');
              _mapController.rotate(state.mapRotation);
            }
          },
        ),
      ],
      child: BlocBuilder<MapBloc, MapState>(
        builder: (context, mapState) {
          return BlocBuilder<LocationBloc, LocationState>(
            builder: (context, locationState) {
              final userPosition = locationState is LocationLoaded
                  ? locationState.currentPosition
                  : null;

              Position? selectedPosition;
              RotationMode rotationMode = RotationMode.free;
              double mapRotation = 0.0;
              if (mapState is MapReady) {
                selectedPosition = mapState.selectedPosition;
                rotationMode = mapState.rotationMode;
                mapRotation = mapState.mapRotation;
              }

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: userPosition != null
                      ? LatLng(userPosition.latitude, userPosition.longitude)
                      : const LatLng(51.5074, -0.1278), // Default to London
                  initialZoom: AppConstants.defaultZoom,
                  minZoom: AppConstants.minZoom,
                  maxZoom: AppConstants.maxZoom,
                  initialRotation: mapRotation,
                  interactionOptions: InteractionOptions(
                    flags: rotationMode == RotationMode.locked
                        ? InteractiveFlag.all & ~InteractiveFlag.rotate
                        : InteractiveFlag.all,
                  ),
                  onTap: (tapPosition, point) {
                    context.read<MapBloc>().add(
                      MapTapped(
                        Position(
                          latitude: point.latitude,
                          longitude: point.longitude,
                        ),
                      ),
                    );
                  },
                  onPositionChanged: (position, hasGesture) {
                    if (hasGesture) {
                      context.read<MapBloc>().add(ZoomChanged(position.zoom));
                      // Track rotation changes from user gestures
                      if (position.rotation != null) {
                        context.read<MapBloc>().add(
                          MapRotationChanged(position.rotation!),
                        );
                      }
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.height_map',
                    maxZoom: 19,
                  ),
                  MarkerLayer(
                    markers: [
                      // User location marker
                      if (userPosition != null)
                        Marker(
                          point: LatLng(
                            userPosition.latitude,
                            userPosition.longitude,
                          ),
                          width: 40,
                          height: 40,
                          child: const _UserLocationMarker(),
                        ),
                      // Selected point marker
                      if (selectedPosition != null)
                        Marker(
                          point: LatLng(
                            selectedPosition.latitude,
                            selectedPosition.longitude,
                          ),
                          width: 40,
                          height: 50,
                          child: const _SelectedPointMarker(),
                        ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _animateToPosition(Position position) {
    _mapController.move(
      LatLng(position.latitude, position.longitude),
      _mapController.camera.zoom,
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}

class _UserLocationMarker extends StatelessWidget {
  const _UserLocationMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
      ),
      child: Center(
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedPointMarker extends StatelessWidget {
  const _SelectedPointMarker();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.terrain, color: Colors.white, size: 20),
        ),
        CustomPaint(
          size: const Size(10, 10),
          painter: _TrianglePainter(color: Colors.red),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = ui.Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
