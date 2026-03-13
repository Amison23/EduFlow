import '../remote/community_remote.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/connectivity_service.dart';
import '../local/database.dart';
import '../local/daos/community_dao.dart';

/// Repository for community-related operations
class CommunityRepository {
  final CommunityRemote _communityRemote;
  final AppDatabase _localDatabase;
  final ConnectivityService _connectivityService = ConnectivityService();

  CommunityRepository({
    required CommunityRemote communityRemote,
    required AppDatabase localDatabase,
  })  : _communityRemote = communityRemote,
        _localDatabase = localDatabase;

  /// Get study groups with optional subject filter
  Future<CommunityResult> getStudyGroups({String? subject}) async {
    final communityDao = CommunityDao(_localDatabase);
    
    // 1. Try local first
    final localGroups = await communityDao.getGroups(subject: subject);
    
    // 2. If online, fetch from server and update cache
    if (_connectivityService.isOnline) {
      try {
        final groups = await _communityRemote.getStudyGroups(subject: subject);
        
        // Update cache
        for (final group in groups) {
          await communityDao.upsertGroup(group);
        }
        
        return CommunityResult(groups: groups);
      } catch (e) {
        // If server fails, use local if available
        if (localGroups.isNotEmpty) {
          return CommunityResult(groups: localGroups);
        }
        return CommunityResult(failure: e is AppException ? e : ServerException(e.toString()));
      }
    }
    
    // 3. If offline, return local
    if (localGroups.isNotEmpty) {
      return CommunityResult(groups: localGroups);
    }
    
    return CommunityResult(failure: NetworkException('Offline and no cached groups'));
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
      
      // Cache the new group
      await CommunityDao(_localDatabase).upsertGroup(group);
      
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
