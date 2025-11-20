import 'package:flutter/material.dart';
import '../../data/models/presence_model.dart';

/// Widget to display active collaborators' avatars
class PresenceAvatars extends StatelessWidget {
  final List<PresenceModel> activeUsers;
  final int maxVisible;

  const PresenceAvatars({
    super.key,
    required this.activeUsers,
    this.maxVisible = 3,
  });

  @override
  Widget build(BuildContext context) {
    if (activeUsers.isEmpty) {
      return const SizedBox.shrink();
    }

    final visibleUsers = activeUsers.take(maxVisible).toList();
    final remainingCount = activeUsers.length - maxVisible;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Active users avatars
        ...visibleUsers.asMap().entries.map((entry) {
          final index = entry.key;
          final user = entry.value;
          
          return Padding(
            padding: EdgeInsets.only(left: index > 0 ? 4 : 0),
            child: _buildAvatar(user),
          );
        }),
        
        // Remaining count
        if (remainingCount > 0)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: _buildRemainingCount(remainingCount),
          ),
      ],
    );
  }

  Widget _buildAvatar(PresenceModel user) {
    return Tooltip(
      message: '${user.userName} is editing',
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CircleAvatar(
          backgroundColor: _getUserColor(user.userId),
          backgroundImage: user.userPhotoUrl != null
              ? NetworkImage(user.userPhotoUrl!)
              : null,
          child: user.userPhotoUrl == null
              ? Text(
                  _getInitials(user.userName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildRemainingCount(int count) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[300],
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          '+$count',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Color _getUserColor(String userId) {
    // Generate consistent color based on userId
    final hash = userId.hashCode;
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
      Colors.red,
    ];
    return colors[hash.abs() % colors.length];
  }
}
