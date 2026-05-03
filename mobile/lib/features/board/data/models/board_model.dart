import '../../domain/entities/board_entity.dart';
import '../../domain/entities/column_entity.dart';
import '../../domain/entities/task_card_entity.dart';

/// JSON → [TaskCardEntity] mapping.
class TaskCardModel {
  static TaskCardEntity fromJson(Map<String, dynamic> json) => TaskCardEntity(
        id: json['id'] as String,
        columnId: json['columnId'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        assigneeId: json['assigneeId'] as String?,
        assigneeName: json['assigneeName'] as String?,
        priority: json['priority'] as String? ?? 'Medium',
        dueDate: json['dueDate'] != null
            ? DateTime.parse(json['dueDate'] as String)
            : null,
        order: json['order'] as int,
        commentCount: json['commentCount'] as int? ?? 0,
      );
}

/// JSON → [ColumnEntity] mapping.
class ColumnModel {
  static ColumnEntity fromJson(Map<String, dynamic> json) => ColumnEntity(
        id: json['id'] as String,
        boardId: json['boardId'] as String,
        title: json['title'] as String,
        order: json['order'] as int,
        cards: (json['cards'] as List<dynamic>? ?? [])
            .map((c) => TaskCardModel.fromJson(c as Map<String, dynamic>))
            .toList(),
      );
}

/// JSON → [BoardSummaryEntity] mapping.
class BoardSummaryModel {
  static BoardSummaryEntity fromJson(Map<String, dynamic> json) => BoardSummaryEntity(
        id: json['id'] as String,
        name: json['name'] as String,
        ownerId: json['ownerId'] as String,
        ownerName: json['ownerName'] as String,
        columnCount: json['columnCount'] as int,
        memberCount: json['memberCount'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

/// JSON → [BoardDetailEntity] mapping.
class BoardDetailModel {
  static BoardDetailEntity fromJson(Map<String, dynamic> json) => BoardDetailEntity(
        id: json['id'] as String,
        name: json['name'] as String,
        ownerId: json['ownerId'] as String,
        ownerName: json['ownerName'] as String,
        columns: (json['columns'] as List<dynamic>? ?? [])
            .map((c) => ColumnModel.fromJson(c as Map<String, dynamic>))
            .toList(),
      );
}
