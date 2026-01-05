import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_constants.dart';
import '../../core/extensions/double_extensions.dart';
import '../../data/models/models.dart';
import '../blocs/blocs.dart';

/// Widget displaying the current height in a floating card
class HeightIndicator extends StatelessWidget {
  final VoidCallback onTap;

  const HeightIndicator({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HeightBloc, HeightState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _buildContent(context, state),
          ),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0);
      },
    );
  }

  Widget _buildContent(BuildContext context, HeightState state) {
    if (state is HeightLoading) {
      return const _LoadingContent();
    }

    if (state is HeightLoaded) {
      final bestHeight = state.bestHeight;
      final bestSource = state.bestSource;

      if (bestHeight != null) {
        return _HeightContent(height: bestHeight, source: bestSource!);
      }

      return const _NoDataContent();
    }

    return const _NoDataContent();
  }
}

class _LoadingContent extends StatelessWidget {
  const _LoadingContent();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Loading...',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

class _HeightContent extends StatelessWidget {
  final double height;
  final HeightSource source;

  const _HeightContent({required this.height, required this.source});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _getSourceIcon(source),
          size: 24,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              height.toMetersString(decimals: 0),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              source.displayName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.chevron_right,
          size: 20,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      ],
    );
  }

  IconData _getSourceIcon(HeightSource source) {
    switch (source) {
      case HeightSource.gps:
        return Icons.satellite_alt;
      case HeightSource.barometer:
        return Icons.speed;
      case HeightSource.api:
        return Icons.cloud;
      case HeightSource.unknown:
        return Icons.help_outline;
    }
  }
}

class _NoDataContent extends StatelessWidget {
  const _NoDataContent();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.terrain,
          size: 24,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 12),
        Text(
          'No altitude data',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.chevron_right,
          size: 20,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      ],
    );
  }
}
