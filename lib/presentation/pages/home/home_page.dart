import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../blocs/blocs.dart';
import '../../widgets/widgets.dart';

/// Main home page with map and height indicator
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Start tracking and monitoring when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationBloc>().add(const StartLocationTracking());
      context.read<HeightBloc>().add(const StartHeightMonitoring());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map takes the full screen
          const HeightMapView(),

          // Height indicator in top-right corner
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: HeightIndicator(
              onTap: () => context.push('/height-details'),
            ),
          ),

          // Elevation info card at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BlocBuilder<MapBloc, MapState>(
              builder: (context, state) {
                if (state is MapReady && state.hasSelectedPoint) {
                  return SafeArea(
                    child: ElevationInfoCard(
                      comparison: state.elevationComparison,
                      isLoading: state.isLoadingElevation,
                      errorMessage: state.errorMessage,
                      onClose: () => context.read<MapBloc>().add(
                        const ClearSelectedPoint(),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),

          // FAB for centering on user
          Positioned(
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom + 100,
            child: BlocBuilder<MapBloc, MapState>(
              builder: (context, state) {
                // Hide FAB when elevation card is shown
                if (state is MapReady && state.hasSelectedPoint) {
                  return const SizedBox.shrink();
                }
                return FloatingActionButton(
                  heroTag: 'center_on_user',
                  onPressed: () {
                    debugPrint('[HomePage] Center on user FAB pressed');
                    final mapBloc = context.read<MapBloc>();
                    final currentState = mapBloc.state;
                    debugPrint(
                      '[HomePage] Current MapBloc state: ${currentState.runtimeType}',
                    );
                    if (currentState is MapReady) {
                      debugPrint(
                        '[HomePage] User position in state: ${currentState.userPosition}',
                      );
                    }
                    mapBloc.add(const CenterOnUser());
                  },
                  child: const Icon(Icons.my_location),
                );
              },
            ),
          ),

          // Error overlay for location issues
          BlocBuilder<LocationBloc, LocationState>(
            builder: (context, state) {
              if (state is LocationPermissionDenied) {
                return _buildPermissionDeniedOverlay(context, state);
              }
              if (state is LocationServiceDisabled) {
                return _buildServiceDisabledOverlay(context);
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionDeniedOverlay(
    BuildContext context,
    LocationPermissionDenied state,
  ) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'permission.locationRequired'.tr(),
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                state.message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  context.read<LocationBloc>().add(
                    const OpenLocationSettings(),
                  );
                },
                child: Text(
                  state.isPermanent
                      ? 'permission.openSettings'.tr()
                      : 'permission.grantPermission'.tr(),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  context.read<LocationBloc>().add(
                    const StartLocationTracking(),
                  );
                },
                child: Text('permission.retry'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceDisabledOverlay(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_disabled,
                size: 48,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              Text(
                'permission.serviceDisabled'.tr(),
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'permission.enableLocation'.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  context.read<LocationBloc>().add(
                    const OpenLocationSettings(),
                  );
                },
                child: Text('permission.openSettings'.tr()),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  context.read<LocationBloc>().add(
                    const StartLocationTracking(),
                  );
                },
                child: Text('permission.retry'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
