import 'package:flutter/material.dart';

class OptimisticListItemWidget extends StatelessWidget {
  final Widget child;
  final bool isOptimistic;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const OptimisticListItemWidget({
    super.key,
    required this.child,
    this.isOptimistic = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isOptimistic ? 0.7 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        decoration: isOptimistic
            ? BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                  width: 1,
                ),
              )
            : null,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                child,
                if (isOptimistic)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Processing...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OptimisticUserItemWidget extends StatelessWidget {
  final Map<String, dynamic> user;
  final bool isOptimistic;
  final Widget? trailing;
  final VoidCallback? onTap;

  const OptimisticUserItemWidget({
    super.key,
    required this.user,
    this.isOptimistic = false,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OptimisticListItemWidget(
      isOptimistic: isOptimistic,
      onTap: onTap,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user['profileImage'] != null
              ? NetworkImage(user['profileImage'])
              : null,
          child: user['profileImage'] == null
              ? const Icon(Icons.person)
              : null,
        ),
        title: Text(user['name'] ?? user['phoneNumber']),
        subtitle: Text(user['phoneNumber']),
        trailing: trailing,
      ),
    );
  }
}

class OptimisticRequestItemWidget extends StatelessWidget {
  final Map<String, dynamic> request;
  final Map<String, dynamic> user;
  final bool isOptimistic;
  final Widget? trailing;
  final VoidCallback? onTap;

  const OptimisticRequestItemWidget({
    super.key,
    required this.request,
    required this.user,
    this.isOptimistic = false,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OptimisticListItemWidget(
      isOptimistic: isOptimistic,
      onTap: onTap,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user['profileImage'] != null
              ? NetworkImage(user['profileImage'])
              : null,
          child: user['profileImage'] == null
              ? const Icon(Icons.person)
              : null,
        ),
        title: Text(user['name'] ?? user['phoneNumber']),
        subtitle: Text(user['phoneNumber']),
        trailing: trailing,
      ),
    );
  }
}
