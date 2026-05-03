import 'package:equatable/equatable.dart';

class OnlineUserEntity extends Equatable {
  const OnlineUserEntity({required this.userId, required this.userName});

  final String userId;
  final String userName;

  @override
  List<Object?> get props => [userId, userName];
}
