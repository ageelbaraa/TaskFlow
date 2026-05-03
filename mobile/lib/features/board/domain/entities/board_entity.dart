import 'package:equatable/equatable.dart';

import 'column_entity.dart';

/// Summary board used in list views.
class BoardSummaryEntity extends Equatable {
  const BoardSummaryEntity({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.ownerName,
    required this.columnCount,
    required this.memberCount,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String ownerId;
  final String ownerName;
  final int columnCount;
  final int memberCount;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id];
}

/// Full board with columns and cards, used in the Kanban detail view.
class BoardDetailEntity extends Equatable {
  const BoardDetailEntity({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.ownerName,
    required this.columns,
  });

  final String id;
  final String name;
  final String ownerId;
  final String ownerName;
  final List<ColumnEntity> columns;

  BoardDetailEntity copyWith({List<ColumnEntity>? columns}) => BoardDetailEntity(
        id: id,
        name: name,
        ownerId: ownerId,
        ownerName: ownerName,
        columns: columns ?? this.columns,
      );

  @override
  List<Object?> get props => [id];
}
