// 🟢 Added: WhatsApp-style notification bubble widget
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

class NotificationBubble extends ConsumerStatefulWidget {
  final String title;
  final String message;
  final VoidCallback? onTap;
  final Duration duration;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const NotificationBubble({
    super.key,
    required this.title,
    required this.message,
    this.onTap,
    this.duration = const Duration(seconds: 4),
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  @override
  ConsumerState<NotificationBubble> createState() => _NotificationBubbleState();
}

class _NotificationBubbleState extends ConsumerState<NotificationBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Start animation
    _animationController.forward();

    // Auto dismiss after duration
    _timer = Timer(widget.duration, () {
      _dismiss();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _dismiss() {
    _animationController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (widget.backgroundColor ?? Colors.white).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.icon ?? Icons.notifications,
                      color: widget.textColor ?? Colors.blue[600],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: widget.textColor ?? Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.message,
                          style: TextStyle(
                            fontSize: 14,
                            color: widget.textColor ?? Colors.black54,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Close button
                  IconButton(
                    onPressed: _dismiss,
                    icon: Icon(
                      Icons.close,
                      color: widget.textColor ?? Colors.grey[600],
                      size: 20,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Notification service for showing bubbles
class NotificationBubbleService {
  static void showNotificationBubble({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 4),
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) => NotificationBubble(
        title: title,
        message: message,
        onTap: onTap,
        duration: duration,
        backgroundColor: backgroundColor,
        textColor: textColor,
        icon: icon,
      ),
    );
  }

  // Predefined notification types
  static void showSuccessNotification({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onTap,
  }) {
    showNotificationBubble(
      context: context,
      title: title,
      message: message,
      onTap: onTap,
      backgroundColor: Colors.green[50],
      textColor: Colors.green[800],
      icon: Icons.check_circle,
    );
  }

  static void showErrorNotification({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onTap,
  }) {
    showNotificationBubble(
      context: context,
      title: title,
      message: message,
      onTap: onTap,
      backgroundColor: Colors.red[50],
      textColor: Colors.red[800],
      icon: Icons.error,
    );
  }

  static void showInfoNotification({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onTap,
  }) {
    showNotificationBubble(
      context: context,
      title: title,
      message: message,
      onTap: onTap,
      backgroundColor: Colors.blue[50],
      textColor: Colors.blue[800],
      icon: Icons.info,
    );
  }

  static void showWarningNotification({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onTap,
  }) {
    showNotificationBubble(
      context: context,
      title: title,
      message: message,
      onTap: onTap,
      backgroundColor: Colors.orange[50],
      textColor: Colors.orange[800],
      icon: Icons.warning,
    );
  }
}
