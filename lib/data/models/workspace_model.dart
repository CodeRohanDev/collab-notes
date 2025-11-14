import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'workspace_model.g.dart';

@HiveType(typeId: 2)
class WorkspaceModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String ownerId;

  @HiveField(4)
  final List<String> members;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime updatedAt;

  @HiveField(7)
  final String? color;

  @HiveField(8)
  final String? icon;

  const WorkspaceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.members,
    required this.createdAt,
    required this.updatedAt,
    this.color,
    this.icon,
  });

  WorkspaceModel copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    List<String>? members,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? color,
    String? icon,
  }) {
    return WorkspaceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      members: members ?? this.members,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'members': members,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'color': color,
      'icon': icon,
    };
  }

  factory WorkspaceModel.fromJson(Map<String, dynamic> json) {
    return WorkspaceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      ownerId: json['ownerId'] as String,
      members: List<String>.from(json['members'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      color: json['color'] as String?,
      icon: json['icon'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        ownerId,
        members,
        createdAt,
        updatedAt,
        color,
        icon,
      ];
}
