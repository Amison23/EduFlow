import '../remote/community_remote.dart';
import '../../core/errors/exceptions.dart';

/// Repository for community-related operations
class CommunityRepository {
  final CommunityRemote _communityRemote;

  CommunityRepository({required CommunityRemote communityRemote})
      : _communityRemote = communityRemote;

  /// Get study groups with optional subject filter
  Future<CommunityResult> getStudyGroups({String? subject}) async {
    try {
      final groups = await _communityRemote.getStudyGroups(subject: subject);
      return CommunityResult(groups: groups);
    } on AppException catch (e) {
      return CommunityResult(failure: e);
    }
  }

  /// Create a study group
  Future<CommunityResult> createStudyGroup({
    required String name,
    required String subject,
    int? maxMembers,
    bool isPublic = true,
  }) async {
    try {
      final group = await _communityRemote.createStudyGroup(
        name: name,
        subject: subject,
        maxMembers: maxMembers,
        isPublic: isPublic,
      );
      return CommunityResult(group: group);
    } on AppException catch (e) {
      return CommunityResult(failure: e);
    }
  }

  /// Join a study group
  Future<bool> joinStudyGroup(String groupId) async {
    try {
      return await _communityRemote.joinStudyGroup(groupId);
    } catch (_) {
      return false;
    }
  }

  /// Find study peers
  Future<CommunityResult> findPeers() async {
    try {
      final peers = await _communityRemote.findPeers();
      return CommunityResult(peers: peers);
    } on AppException catch (e) {
      return CommunityResult(failure: e);
    }
  }
}

/// Result wrapper for community operations
class CommunityResult {
  final List<Map<String, dynamic>>? groups;
  final List<Map<String, dynamic>>? peers;
  final Map<String, dynamic>? group;
  final AppException? failure;

  CommunityResult({
    this.groups,
    this.peers,
    this.group,
    this.failure,
  });

  bool get success => failure == null;
}
