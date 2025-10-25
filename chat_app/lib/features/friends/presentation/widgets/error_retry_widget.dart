import 'package:flutter/material.dart';

class ErrorRetryWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final String? retryText;
  final bool showRetryButton;

  const ErrorRetryWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
    this.retryText,
    this.showRetryButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: Colors.red.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (showRetryButton && onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryText ?? 'Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? customMessage;

  const NetworkErrorWidget({
    super.key,
    this.onRetry,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorRetryWidget(
      message: customMessage ?? 
          'Please check your internet connection and try again.',
      onRetry: onRetry,
      icon: Icons.wifi_off,
      retryText: 'Retry',
    );
  }
}

class TimeoutErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? customMessage;

  const TimeoutErrorWidget({
    super.key,
    this.onRetry,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorRetryWidget(
      message: customMessage ?? 
          'The request is taking longer than expected. Please try again.',
      onRetry: onRetry,
      icon: Icons.timer_off,
      retryText: 'Try Again',
    );
  }
}
