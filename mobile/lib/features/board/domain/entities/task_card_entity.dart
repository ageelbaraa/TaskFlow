import 'package:equatable/equatable.dart';

/// Immutable domain representation of a task card.
class TaskCardEntity extends Equatable {
  const TaskCardEntity({
    required this.id,
    required this.columnId,
    required this.title,
    this.description,
    this.assigneeId,
    this.assigneeName,
    required this.priority,
    this.dueDate,
    required this.order,
    required this.commentCount,
  });

  final String id;
  final String columnId;
  final String title;
  final String? description;
  final String? assigneeId;
  final String? assigneeName;
  final String priority;
  final DateTime? dueDate;
  final int order;
  final int commentCount;

  TaskCardEntity copyWith({
    String? columnId,
    String? title,
    String? description,
    String? assigneeId,
    String? assigneeName,
    String? priority,
    DateTime? dueDate,
    int? order,
    int? commentCount,
  }) =>
      TaskCardEntity(
        id: id,
        columnId: columnId ?? this.columnId,
        title: title ?? this.title,
        description: description ?? this.description,
        assigneeId: assigneeId ?? this.assigneeId,
        assigneeName: assigneeName ?? this.assigneeName,
        priority: priority ?? this.priority,
        dueDate: dueDate ?? this.dueDate,
        order: order ?? this.order,
        commentCount: commentCount ?? this.commentCount,
      );

  @override
  List<Object?> get props => [id, columnId, order];
}
