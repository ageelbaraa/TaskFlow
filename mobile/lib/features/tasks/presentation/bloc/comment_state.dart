import 'package:equatable/equatable.dart';

import '../../domain/entities/comment_entity.dart';

sealed class CommentState extends Equatable {
  const CommentState();
}

final class CommentInitial extends CommentState {
  const CommentInitial();
  @override
  List<Object?> get props => [];
}

final class CommentLoading extends CommentState {
  const CommentLoading();
  @override
  List<Object?> get props => [];
}

final class CommentLoaded extends CommentState {
  const CommentLoaded(this.comments, {this.submitting = false});
  final List<CommentEntity> comments;
  final bool submitting;

  CommentLoaded copyWith({
    List<CommentEntity>? comments,
    bool? submitting,
  }) =>
      CommentLoaded(
        comments ?? this.comments,
        submitting: submitting ?? this.submitting,
      );

  @override
  List<Object?> get props => [comments, submitting];
}

final class CommentError extends CommentState {
  const CommentError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
