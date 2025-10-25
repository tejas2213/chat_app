import 'dart:async';
import 'package:flutter/material.dart';

class DebouncedButtonWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Duration debounceDuration;
  final bool enabled;

  const DebouncedButtonWidget({
    super.key,
    required this.child,
    this.onPressed,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.enabled = true,
  });

  @override
  State<DebouncedButtonWidget> createState() => _DebouncedButtonWidgetState();
}

class _DebouncedButtonWidgetState extends State<DebouncedButtonWidget> {
  Timer? _debounceTimer;
  bool _isProcessing = false;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _handlePress() {
    if (!widget.enabled || _isProcessing || widget.onPressed == null) return;

    _debounceTimer?.cancel();

    setState(() {
      _isProcessing = true;
    });

    widget.onPressed!();

    _debounceTimer = Timer(widget.debounceDuration, () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: !widget.enabled || _isProcessing,
      child: Opacity(
        opacity: (widget.enabled && !_isProcessing) ? 1.0 : 0.6,
        child: GestureDetector(
          onTap: _handlePress,
          child: widget.child,
        ),
      ),
    );
  }
}

class DebouncedIconButtonWidget extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Duration debounceDuration;
  final Color? color;
  final double? size;
  final bool enabled;

  const DebouncedIconButtonWidget({
    super.key,
    required this.icon,
    this.onPressed,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.color,
    this.size,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return DebouncedButtonWidget(
      onPressed: onPressed,
      debounceDuration: debounceDuration,
      enabled: enabled,
      child: IconButton(
        icon: Icon(icon, color: color, size: size),
        onPressed: null, 
      ),
    );
  }
}
