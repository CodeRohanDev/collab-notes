import 'package:flutter/material.dart';
import '../../data/models/presence_model.dart';

/// Widget to display remote users' cursors
class RemoteCursorOverlay extends StatelessWidget {
  final List<PresenceModel> activeUsers;
  final String documentText;

  const RemoteCursorOverlay({
    super.key,
    required this.activeUsers,
    required this.documentText,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: activeUsers
          .where((user) => user.cursorPosition != null)
          .map((user) => _buildCursor(user))
          .toList(),
    );
  }

  Widget _buildCursor(PresenceModel user) {
    return Positioned(
      // Note: Actual positioning would require text layout calculations
      // This is a simplified version
      left: 20,
      top: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cursor line
          Container(
            width: 2,
            height: 20,
            color: _getUserColor(user.userId),
          ),
          // User label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _getUserColor(user.userId),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              user.userName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getUserColor(String userId) {
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
