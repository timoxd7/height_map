import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_constants.dart';
import '../../core/extensions/double_extensions.dart';
import '../../data/models/models.dart';

/// Card widget displaying a single sensor reading
class SensorCard extends StatelessWidget {
  final HeightMeasurement? measurement;
  final HeightSource source;
  final bool isAvailable;
  final bool isExpanded;
  final VoidCallback? onTap;

  const SensorCard({
    super.key,
    this.measurement,
    required this.source,
    required this.isAvailable,
    this.isExpanded = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.animationDuration,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(
            color: measurement != null && measurement!.isReliable
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            _buildContent(context),
            if (isExpanded && measurement != null) ...[
              const SizedBox(height: 12),
              _buildDetails(context),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getSourceColor(context).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          ),
          child: Icon(
            _getSourceIcon(),
            size: 24,
            color: _getSourceColor(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                source.displayName,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                _getSourceDescription(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        _buildStatusIndicator(context),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    if (!isAvailable) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        ),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 20,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            Text(
              'Sensor not available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      );
    }

    if (measurement == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Waiting for data...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          measurement!.heightMeters.toStringAsFixed(1),
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: _getSourceColor(context),
          ),
        ),
        const SizedBox(width: 4),
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            'm',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        const Spacer(),
        Text(
          measurement!.heightMeters.toFeetString(decimals: 0),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildDetails(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            context,
            'Accuracy',
            measurement!.accuracy != null
                ? '±${measurement!.accuracy!.toStringAsFixed(1)} m'
                : 'Unknown',
          ),
          const Divider(height: 16),
          _buildDetailRow(
            context,
            'Last Update',
            _formatTime(measurement!.timestamp),
          ),
          const Divider(height: 16),
          _buildDetailRow(
            context,
            'Reliability',
            measurement!.isReliable ? 'High' : 'Low',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(BuildContext context) {
    if (!isAvailable) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Unavailable',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.error,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    if (measurement == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Loading',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.orange,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        measurement!.isReliable ? 'Active' : 'Low Quality',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: measurement!.isReliable ? Colors.green : Colors.orange,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  IconData _getSourceIcon() {
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

  Color _getSourceColor(BuildContext context) {
    switch (source) {
      case HeightSource.gps:
        return Colors.blue;
      case HeightSource.barometer:
        return Colors.purple;
      case HeightSource.api:
        return Colors.green;
      case HeightSource.unknown:
        return Colors.grey;
    }
  }

  String _getSourceDescription() {
    switch (source) {
      case HeightSource.gps:
        return 'Satellite-based altitude';
      case HeightSource.barometer:
        return 'Atmospheric pressure sensor';
      case HeightSource.api:
        return 'Terrain elevation data';
      case HeightSource.unknown:
        return 'Unknown source';
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 10) {
      return 'Just now';
    } else if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s ago';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else {
      return '${diff.inHours}h ago';
    }
  }
}
