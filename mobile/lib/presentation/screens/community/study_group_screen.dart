import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../bloc/community/community_bloc.dart';
import '../../../services/tflite_quiz_service.dart';

/// Screen for study groups / community
class StudyGroupScreen extends StatefulWidget {
  const StudyGroupScreen({super.key});

  @override
  State<StudyGroupScreen> createState() => _StudyGroupScreenState();
}

class _StudyGroupScreenState extends State<StudyGroupScreen> {
  final TextEditingController _nameController = TextEditingController();
  late final TfliteQuizService _quizService;
  String _selectedSubject = 'math';

  @override
  void initState() {
    super.initState();
    _quizService = context.read<TfliteQuizService>();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
      ),
      body: BlocConsumer<CommunityBloc, CommunityState>(
        listener: (context, state) {
          if (state is CommunityError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is GroupCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Study group created successfully!')),
            );
          } else if (state is JoinSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Joined group successfully!')),
            );
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<CommunityBloc>().add(const LoadStudyGroups());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // My Groups section
                  Text(
                    'Study Groups',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  if (state is CommunityLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (state is StudyGroupsLoaded)
                    if (state.groups.isEmpty)
                      _buildEmptyState('No study groups available yet.')
                    else
                      ...state.groups.map((group) => _buildGroupCard(
                        context,
                        group['name'] ?? 'Unnamed Group',
                        '${group['group_members_count'] ?? 0} members',
                        _getIconForSubject(group['subject']),
                        _getColorForSubject(group['subject']),
                        group['id'],
                      ))
                  else
                    _buildEmptyState('Something went wrong. Pull to refresh.'),
                  
                  const SizedBox(height: 24),
                  
                  // Find Groups
                  Text(
                    'Search Groups',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFindGroupCard(context),
                  const SizedBox(height: 24),
                  
                  // Peer matching
                  Text(
                    'Find Study Partners',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPeerCard(context, state),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateGroupDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Create Group'),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            const Icon(Icons.group_off, size: 48, color: AppTheme.textSecondary),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupCard(
    BuildContext context,
    String name,
    String members,
    IconData icon,
    Color color,
    String groupId,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(name),
        subtitle: Text(members),
        trailing: ElevatedButton(
          onPressed: () {
            context.read<CommunityBloc>().add(JoinStudyGroup(groupId));
          },
          child: const Text('Join'),
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildFindGroupCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.search, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter by Subject',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Find specialized study circles',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeerCard(BuildContext context, CommunityState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.person_search, color: AppTheme.secondaryColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Study Partners',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Connect with peers in your region',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.read<CommunityBloc>().add(FindPeers());
                  },
                  child: const Text('Discover'),
                ),
              ],
            ),
            if (state is PeersLoaded && state.peers.isNotEmpty) ...[
              const Divider(height: 24),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.peers.length > 3 ? 3 : state.peers.length,
                itemBuilder: (context, index) {
                  final peer = state.peers[index];
                  final insight = _quizService.getPeerCompatibilityInsight(peer);
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Row(
                      children: [
                        Text('Learner #${peer['id'].toString().substring(0, 4)}'),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppTheme.secondaryColor.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            insight,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text('Context: ${peer['context'] ?? 'Local'}'),
                    trailing: TextButton(
                      onPressed: () {},
                      child: const Text('Connect'),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    _nameController.clear();
    _selectedSubject = 'math';
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create Study Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                hintText: 'e.g., Math Beginners',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedSubject,
              decoration: const InputDecoration(labelText: 'Subject'),
              items: const [
                DropdownMenuItem(value: 'math', child: Text('Math')),
                DropdownMenuItem(value: 'english', child: Text('English')),
                DropdownMenuItem(value: 'swahili', child: Text('Swahili')),
                DropdownMenuItem(value: 'digital', child: Text('Digital Skills')),
              ],
              onChanged: (value) {
                if (value != null) _selectedSubject = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty) {
                context.read<CommunityBloc>().add(CreateStudyGroup(
                  name: _nameController.text,
                  subject: _selectedSubject,
                ));
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  IconData _getIconForSubject(String? subject) {
    switch (subject?.toLowerCase()) {
      case 'math': return Icons.calculate;
      case 'english': return Icons.menu_book;
      case 'swahili': return Icons.language;
      case 'digital': return Icons.computer;
      default: return Icons.group;
    }
  }

  Color _getColorForSubject(String? subject) {
    switch (subject?.toLowerCase()) {
      case 'math': return AppTheme.mathColor;
      case 'english': return AppTheme.englishColor;
      case 'swahili': return AppTheme.swahiliColor;
      case 'digital': return Colors.purple;
      default: return AppTheme.primaryColor;
    }
  }
}
