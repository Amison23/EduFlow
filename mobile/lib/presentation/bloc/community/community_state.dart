part of 'community_bloc.dart';

abstract class CommunityState extends Equatable {
  const CommunityState();

  @override
  List<Object?> get props => [];
}

class CommunityInitial extends CommunityState {}

class CommunityLoading extends CommunityState {}

class StudyGroupsLoaded extends CommunityState {
  final List<Map<String, dynamic>> groups;

  const StudyGroupsLoaded(this.groups);

  @override
  List<Object?> get props => [groups];
}

class PeersLoaded extends CommunityState {
  final List<Map<String, dynamic>> peers;

  const PeersLoaded(this.peers);

  @override
  List<Object?> get props => [peers];
}

class GroupCreated extends CommunityState {
  final Map<String, dynamic> group;

  const GroupCreated(this.group);

  @override
  List<Object?> get props => [group];
}

class JoinSuccess extends CommunityState {
  final String groupId;

  const JoinSuccess(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class CommunityError extends CommunityState {
  final String message;

  const CommunityError(this.message);

  @override
  List<Object?> get props => [message];
}
