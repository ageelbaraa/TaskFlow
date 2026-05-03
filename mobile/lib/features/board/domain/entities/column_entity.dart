import 'package:equatable/equatable.dart';

import 'task_card_entity.dart';

/// Immutable domain representation of a board column.
class ColumnEntity extends Equatable {
  const ColumnEntity({
    required this.id,
    required this.boardId,
    required this.title,
    required this.order,
    required this.cards,
  });

  final String id;
  final String boardId;
  final String title;
  final int order;
  final List<TaskCardEntity> cards;

  ColumnEntity copyWith({
    String? title,
    int? order,
    List<TaskCardEntity>? cards,
  }) =>
      ColumnEntity(
        id: id,
        boardId: boardId,
        title: title ?? this.title,
        order: order ?? this.order,
        cards: cards ?? this.cards,
      );

  @override
  List<Object?> get props => [id, boardId, order];
}
