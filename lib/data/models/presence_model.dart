import 'package:equatable/equatable.dart';

/// Model representing a user's presence in a note
class PresenceModel extends Equatable {
  final String userId;
  final String userName;
  final String userEmail;
  final String? userPhotoUrl;
  final DateTime lastSeen;
  final bool isActive;
  final int? cursorPosition;
  final int? selectionStart;
  final int? selectionEnd;

  const PresenceModel({
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userPhotoUrl,
    required this.lastSeen,
    required this.isActive,
    this.cursorPosition,
    this.selectionStart,
    this.selectionEnd,
  });

  factory PresenceModel.fromJson(Map<String, dynamic> json) {
    return PresenceModel(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userEmail: json['userEmail'] as String,
      userPhotoUrl: json['userPhotoUrl'] as String?,
      lastSeen: DateTime.parse(json['lastSeen'] as String),
      isActive: json['isActive'] as bool? ?? false,
      cursorPosition: json['cursorPosition'] as int?,
      selectionStart: json['selectionStart'] as int?,
      selectionEnd: json['selectionEnd'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhotoUrl': userPhotoUrl,
      'lastSeen': lastSeen.toIso8601String(),
      'isActive': isActive,
      'cursorPosition': cursorPosition,
      'selectionStart': selectionStart,
      'selectionEnd': selectionEnd,
    };
  }

  PresenceModel copyWith({
    String? userId,
    String? userName,
    String? userEmail,
    String? userPhotoUrl,
    DateTime? lastSeen,
    bool? isActive,
    int? cursorPosition,
    int? selectionStart,
    int? selectionEnd,
  }) {
    return PresenceModel(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      lastSeen: lastSeen ?? this.lastSeen,
      isActive: isActive ?? this.isActive,
      cursorPosition: cursorPosition ?? this.cursorPosition,
      selectionStart: selectionStart ?? this.selectionStart,
      selectionEnd: selectionEnd ?? this.selectionEnd,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        userName,
        userEmail,
        userPhotoUrl,
        lastSeen,
        isActive,
        cursorPosition,
        selectionStart,
        selectionEnd,
      ];
}
