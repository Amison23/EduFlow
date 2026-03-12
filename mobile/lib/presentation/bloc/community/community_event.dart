part of 'community_bloc.dart';

abstract class CommunityEvent extends Equatable {
  const CommunityEvent();

  @override
  List<Object?> get props => [];
}

class LoadStudyGroups extends CommunityEvent {
  final String? subject;

  const LoadStudyGroups({this.subject});

  @override
  List<Object?> get props => [subject];
}

class CreateStudyGroup extends CommunityEvent {
  final String name;
  final String subject;
  final int? maxMembers;
  final bool isPublic;

  const CreateStudyGroup({
    required this.name,
    required this.subject,
    this.maxMembers,
    this.isPublic = true,
  });

  @override
  List<Object?> get props => [name, subject, maxMembers, isPublic];
}

class JoinStudyGroup extends CommunityEvent {
  final String groupId;

  const JoinStudyGroup(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class FindPeers extends CommunityEvent {}
