import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/constants/app_constants.dart';
import '../../core/extensions/double_extensions.dart';
import '../../data/models/models.dart';

/// Widget displaying elevation comparison info
class ElevationInfoCard extends StatelessWidget {
  final ElevationComparison? comparison;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onClose;

  const ElevationInfoCard({
    super.key,
    this.comparison,
    this.isLoading = false,
    this.errorMessage,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: _buildContent(context),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return _buildLoadingContent(context);
    }

    if (errorMessage != null) {
      return _buildErrorContent(context);
    }

    if (comparison != null) {
      return _buildComparisonContent(context);
    }

    return const SizedBox.shrink();
  }

  Widget _buildLoadingContent(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            'elevation.fetchingData'.tr(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: onClose,
          iconSize: 20,
        ),
      ],
    );
  }

  Widget _buildErrorContent(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.error_outline,
          color: Theme.of(context).colorScheme.error,
          size: 24,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            errorMessage!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: onClose,
          iconSize: 20,
        ),
      ],
    );
  }

  Widget _buildComparisonContent(BuildContext context) {
    final difference = comparison!.difference;
    final isHigher = comparison!.isHigher;
    final selectedElevation = comparison!.selectedLocation.elevation;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'elevation.selectedPoint'.tr(),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: onClose,
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _ElevationTile(
                label: 'elevation.elevation'.tr(),
                value: selectedElevation.toMetersString(decimals: 0),
                icon: Icons.terrain,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ElevationTile(
                label: 'elevation.difference'.tr(),
                value: difference.toDifferenceString(decimals: 0),
                icon: isHigher ? Icons.arrow_upward : Icons.arrow_downward,
                color: isHigher ? Colors.orange : Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildComparisonBar(context, difference, isHigher),
      ],
    );
  }

  Widget _buildComparisonBar(
    BuildContext context,
    double difference,
    bool isHigher,
  ) {
    final absDifference = difference.abs();
    // Cap the visual at 1000m for display purposes
    final displayRatio = (absDifference / 1000).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isHigher
              ? 'elevation.higherThanPosition'.tr()
              : 'elevation.lowerThanPosition'.tr(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: displayRatio,
            child: Container(
              decoration: BoxDecoration(
                color: isHigher ? Colors.orange : Colors.blue,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ElevationTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ElevationTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
