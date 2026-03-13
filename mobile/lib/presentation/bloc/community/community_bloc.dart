import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/repositories/community_repository.dart';
import '../../../data/local/hive_boxes.dart';

part 'community_event.dart';
part 'community_state.dart';

/// BLoC for community features
class CommunityBloc extends Bloc<CommunityEvent, CommunityState> {
  final CommunityRepository _communityRepository;

  CommunityBloc({required CommunityRepository communityRepository})
      : _communityRepository = communityRepository,
        super(CommunityInitial()) {
    on<LoadStudyGroups>(_onLoadStudyGroups);
    on<CreateStudyGroup>(_onCreateStudyGroup);
    on<JoinStudyGroup>(_onJoinStudyGroup);
    on<FindPeers>(_onFindPeers);
  }

  Future<void> _onLoadStudyGroups(
    LoadStudyGroups event,
    Emitter<CommunityState> emit,
  ) async {
    // Prevent fetching if not authenticated (token missing)
    final token = HiveBoxes.getToken();
    if (token == null) {
      // Return empty list or silent error to avoid crashing/distracting user
      emit(const StudyGroupsLoaded([]));
      return;
    }

    emit(CommunityLoading());
    final result = await _communityRepository.getStudyGroups(subject: event.subject);
    if (result.success) {
      emit(StudyGroupsLoaded(result.groups ?? []));
    } else {
      emit(CommunityError(result.failure?.message ?? 'Failed to load study groups'));
    }
  }

  Future<void> _onCreateStudyGroup(
    CreateStudyGroup event,
    Emitter<CommunityState> emit,
  ) async {
    emit(CommunityLoading());
    final result = await _communityRepository.createStudyGroup(
      name: event.name,
      subject: event.subject,
      maxMembers: event.maxMembers,
      isPublic: event.isPublic,
    );
    if (result.success) {
      emit(GroupCreated(result.group!));
      // Refresh list
      add(const LoadStudyGroups());
    } else {
      emit(CommunityError(result.failure?.message ?? 'Failed to create study group'));
    }
  }

  Future<void> _onJoinStudyGroup(
    JoinStudyGroup event,
    Emitter<CommunityState> emit,
  ) async {
    emit(CommunityLoading());
    final success = await _communityRepository.joinStudyGroup(event.groupId);
    if (success) {
      emit(JoinSuccess(event.groupId));
      // Refresh list
      add(const LoadStudyGroups());
    } else {
      emit(const CommunityError('Failed to join study group'));
    }
  }

  Future<void> _onFindPeers(
    FindPeers event,
    Emitter<CommunityState> emit,
  ) async {
    emit(CommunityLoading());
    final result = await _communityRepository.findPeers();
    if (result.success) {
      emit(PeersLoaded(result.peers ?? []));
    } else {
      emit(CommunityError(result.failure?.message ?? 'Failed to find study peers'));
    }
  }
}
