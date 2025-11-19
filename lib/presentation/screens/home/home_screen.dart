// ignore_for_file: deprecated_member_use, unused_element

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import '../../bloc/notes/notes_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../notes/rich_note_editor_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/note_model.dart';
import 'archived_notes_screen.dart';

// Helper function to extract plain text from Quill JSON
String _extractPlainText(String content) {
  if (content.isEmpty) return '';

  try {
    // Try to parse as Quill JSON
    final json = jsonDecode(content);
    if (json is List) {
      final buffer = StringBuffer();
      for (final op in json) {
        if (op is Map && op.containsKey('insert')) {
          buffer.write(op['insert']);
        }
      }
      return buffer.toString().trim();
    }
    // If it's a map with ops
    if (json is Map && json.containsKey('ops')) {
      final buffer = StringBuffer();
      for (final op in json['ops']) {
        if (op is Map && op.containsKey('insert')) {
          buffer.write(op['insert']);
        }
      }
      return buffer.toString().trim();
    }
  } catch (e) {
    // If parsing fails, return as-is (old plain text format)
    return content;
  }

  return content;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabController;
  bool _isGridView = false;
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<NotesBloc>().add(NotesLoadRequested());
    
    // Only start realtime sync for authenticated (non-guest) users
    final authState = context.read<AuthBloc>().state;
    final isGuest = authState is AuthAuthenticated && authState.isGuest;
    if (!isGuest) {
      context.read<NotesBloc>().add(NotesStartRealtimeSync());
    }
    
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isGuest = authState is AuthAuthenticated && authState.isGuest;
        final userName = authState is AuthAuthenticated
            ? authState.user.displayName.split(' ')[0]
            : 'User';

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildModernAppBar(context, isGuest, userName),
              if (_isSearching) _buildSearchBar(),
              if (isGuest) _buildGuestBanner(context),
              // _buildQuickStats(),
              _buildNotesList(),
            ],
          ),
          floatingActionButton: _buildModernFAB(context),
        );
      },
    );
  }

  SliverAppBar _buildModernAppBar(
    BuildContext context,
    bool isGuest,
    String userName,
  ) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.primaryColor,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $userName! 👋',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'My Notes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        titlePadding: EdgeInsets.zero,
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isSearching ? Iconsax.close_circle : Iconsax.search_normal_1,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchQuery = '';
                _searchController.clear();
              }
            });
          },
        ),
        IconButton(
          icon: Icon(
            _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _isGridView = !_isGridView;
            });
          },
        ),
        if (!isGuest)
          IconButton(
            icon: const Icon(Icons.sync_rounded, color: Colors.white),
            onPressed: () {
              context.read<NotesBloc>().add(NotesSyncRequested());
              _showSnackBar(context, 'Syncing notes...', AppTheme.primaryColor);
            },
          ),
        PopupMenuButton(
          icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
          offset: const Offset(0, 50),
          itemBuilder: (context) => [
            if (isGuest)
              PopupMenuItem(
                value: 'signin',
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.cloud_upload_rounded,
                        size: 18,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Sign in to Sync',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            PopupMenuItem(
              value: 'archived',
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Iconsax.archive,
                      size: 18,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Archived Notes',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.settings_rounded,
                      size: 18,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Settings',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'logout',
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      size: 18,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'logout') {
              _showLogoutDialog(context);
            } else if (value == 'signin') {
              context.read<AuthBloc>().add(AuthSignInWithGoogleRequested());
            } else if (value == 'archived') {
              _showArchivedNotes(context);
            } else if (value == 'settings') {
              _showSnackBar(
                context,
                'Settings coming soon!',
                AppTheme.primaryColor,
              );
            }
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildQuickStats() {
    return BlocBuilder<NotesBloc, NotesState>(
      builder: (context, state) {
        if (state is! NotesLoaded)
          return const SliverToBoxAdapter(child: SizedBox());

        final totalNotes = state.notes.length;
        final today = state.notes.where((n) {
          final diff = DateTime.now().difference(n.updatedAt);
          return diff.inHours < 24;
        }).length;

        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    totalNotes.toString(),
                    Iconsax.note_1,
                    AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Today',
                    today.toString(),
                    Iconsax.calendar_1,
                    AppTheme.successColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildGuestBanner(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.warningColor.withOpacity(0.1),
              AppTheme.warningColor.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.warningColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.info_outline_rounded,
                color: AppTheme.warningColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Guest Mode',
                    style: AppTheme.titleLarge.copyWith(
                      color: AppTheme.warningColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sign in to sync your notes across devices',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                context.read<AuthBloc>().add(AuthSignInWithGoogleRequested());
              },
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.warningColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesList() {
    return BlocBuilder<NotesBloc, NotesState>(
      builder: (context, state) {
        
        if (state is NotesInitial || state is NotesLoading) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is NotesError) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.danger, size: 64, color: AppTheme.errorColor),
                  const SizedBox(height: 16),
                  Text(
                    'Oops! Something went wrong',
                    style: AppTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is NotesLoaded) {
          // Filter out archived notes
          var filteredNotes = state.notes.where((n) => !n.isArchived).toList();

          // Apply search filter
          if (_searchQuery.isNotEmpty) {
            filteredNotes = filteredNotes.where((note) {
              final titleMatch = note.title.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              );
              final contentMatch = _extractPlainText(
                note.content,
              ).toLowerCase().contains(_searchQuery.toLowerCase());
              final tagsMatch = note.tags.any(
                (tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()),
              );
              return titleMatch || contentMatch || tagsMatch;
            }).toList();
          }

          // Sort: pinned first, then by date
          final sortedNotes = List.from(filteredNotes)
            ..sort((a, b) {
              // Pinned notes first
              if (a.isPinned != b.isPinned) {
                return a.isPinned ? -1 : 1;
              }
              // Then by most recently updated
              return b.updatedAt.compareTo(a.updatedAt);
            });

          if (sortedNotes.isEmpty) {
            return SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient.scale(0.1),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.2),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Iconsax.note_add,
                        size: 80,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'No notes yet',
                      style: AppTheme.headlineLarge.copyWith(
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: Text(
                        'Start capturing your ideas and thoughts.\nTap the + button to create your first note',
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (_isGridView) {
            return SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final note = sortedNotes[index];
                  return _buildGridNoteCard(context, note, index);
                }, childCount: sortedNotes.length),
              ),
            );
          }

          return SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final note = sortedNotes[index];
                return _buildNoteCard(context, note, index);
              }, childCount: sortedNotes.length),
            ),
          );
        }

        return const SliverFillRemaining(child: SizedBox());
      },
    );
  }

  Widget _buildNoteCard(BuildContext context, note, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: note.color != null
            ? Border.all(color: Color(int.parse(note.color!)), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final notesBloc = context.read<NotesBloc>();
            final authBloc = context.read<AuthBloc>();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: notesBloc),
                    BlocProvider.value(value: authBloc),
                  ],
                  child: RichNoteEditorScreen(note: note),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and actions row
                Row(
                  children: [
                    if (note.isPinned)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.push_pin,
                          size: 16,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    Expanded(
                      child: Text(
                        note.title.isEmpty ? 'Untitled' : note.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (note.isFavorite)
                      Icon(
                        Iconsax.star_15,
                        size: 18,
                        color: AppTheme.warningColor,
                      ),
                    IconButton(
                      icon: Icon(
                        Iconsax.more,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _showNoteOptions(context, note),
                    ),
                  ],
                ),
                // Tags
                if (note.tags.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: note.tags.take(3).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                // Content preview
                if (note.content.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    _extractPlainText(note.content),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                // Footer
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      _formatDate(note.updatedAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    const Spacer(),
                    if (note.isSyncEnabled) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Iconsax.cloud,
                              size: 12,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Cloud',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Iconsax.mobile,
                              size: 12,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Local',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (note.syncStatus == 'pending') ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.warningColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.sync_rounded,
                              size: 12,
                              color: AppTheme.warningColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Syncing',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.warningColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }

  Widget _buildModernFAB(BuildContext context) {
    return Container(
      height: 64,
      width: 64,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final notesBloc = context.read<NotesBloc>();
            final authBloc = context.read<AuthBloc>();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: notesBloc),
                    BlocProvider.value(value: authBloc),
                  ],
                  child: const RichNoteEditorScreen(),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: const Center(
            child: Icon(Iconsax.edit, size: 28, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildGridNoteCard(BuildContext context, note, int index) {
    Color cardColor = Colors.white;
    if (note.color != null) {
      cardColor = Color(int.parse(note.color!)).withOpacity(0.1);
    }

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: note.color != null
              ? Color(int.parse(note.color!)).withOpacity(0.3)
              : Colors.grey[200]!,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: note.color != null
                ? Color(int.parse(note.color!)).withOpacity(0.1)
                : Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final notesBloc = context.read<NotesBloc>();
            final authBloc = context.read<AuthBloc>();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: notesBloc),
                    BlocProvider.value(value: authBloc),
                  ],
                  child: RichNoteEditorScreen(note: note),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    if (note.isPinned)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Icon(
                          Icons.push_pin,
                          size: 14,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    Expanded(
                      child: Text(
                        note.title.isEmpty ? 'Untitled' : note.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (note.isFavorite)
                      Icon(
                        Iconsax.star_15,
                        size: 14,
                        color: AppTheme.warningColor,
                      ),
                  ],
                ),
                // Tags
                if (note.tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: note.tags.take(2).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                // Content
                if (note.content.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      _extractPlainText(note.content),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                const Spacer(),
                // Footer
                const SizedBox(height: 8),
                Text(
                  _formatDate(note.updatedAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  void _showDeleteDialog(BuildContext context, String noteId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<NotesBloc>().add(
                NotesDeleteRequested(noteId: noteId),
              );
              Navigator.pop(dialogContext);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(AuthSignOutRequested());
              Navigator.pop(dialogContext);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistPreview(List<Map<String, dynamic>> items) {
    final completedCount = items
        .where((item) => item['isChecked'] == true)
        .length;
    final totalCount = items.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Iconsax.task_square, size: 16, color: Colors.black54),
            const SizedBox(width: 6),
            Text(
              '$completedCount/$totalCount completed',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ...items.take(2).map((item) {
          final isChecked = item['isChecked'] as bool;
          final text = item['text'] as String;
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(
                  isChecked ? Icons.check_box : Icons.check_box_outline_blank,
                  size: 16,
                  color: isChecked ? AppTheme.primaryColor : Colors.black45,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    text.isEmpty ? 'List item' : text,
                    style: TextStyle(
                      fontSize: 13,
                      color: isChecked ? Colors.black45 : Colors.black54,
                      decoration: isChecked ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }),
        if (items.length > 2)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '+${items.length - 2} more',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black45,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(
              Iconsax.search_normal_1,
              color: Colors.grey[400],
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search notes, tags...',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                style: const TextStyle(fontSize: 15),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            if (_searchQuery.isNotEmpty)
              IconButton(
                icon: Icon(Icons.clear, size: 20, color: Colors.grey[600]),
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }

  void _showNoteOptions(BuildContext context, NoteModel note) {
    final notesBloc = context.read<NotesBloc>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => BlocProvider.value(
        value: notesBloc,
        child: _NoteOptionsSheet(note: note),
      ),
    );
  }

  void _showArchivedNotes(BuildContext context) {
    final notesBloc = context.read<NotesBloc>();
    final authBloc = context.read<AuthBloc>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: notesBloc),
            BlocProvider.value(value: authBloc),
          ],
          child: const ArchivedNotesScreen(),
        ),
      ),
    );
  }
}

// Note Options Bottom Sheet
class _NoteOptionsSheet extends StatelessWidget {
  final NoteModel note;

  const _NoteOptionsSheet({required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          // Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Iconsax.setting_2,
                  size: 20,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Note Options',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Color Picker
          _buildColorPicker(context),
          const SizedBox(height: 20),
          // Tags
          _buildTagsSection(context),
          const SizedBox(height: 20),
          // Actions
          _buildActionButton(
            context,
            icon: note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
            label: note.isPinned ? 'Unpin Note' : 'Pin Note',
            onTap: () {
              context.read<NotesBloc>().add(
                NotesTogglePinRequested(noteId: note.id),
              );
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 10),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              final isAuthenticated = authState is AuthAuthenticated && !authState.isGuest;
              
              if (!isAuthenticated) {
                return const SizedBox.shrink();
              }
              
              return Column(
                children: [
                  _buildActionButton(
                    context,
                    icon: note.isSyncEnabled ? Iconsax.cloud_change : Iconsax.cloud_add,
                    label: note.isSyncEnabled ? 'Disable Cloud Sync' : 'Sync to Cloud',
                    onTap: () {
                      context.read<NotesBloc>().add(
                        NotesToggleSyncRequested(
                          noteId: note.id,
                          enableSync: !note.isSyncEnabled,
                        ),
                      );
                      Navigator.pop(context);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            note.isSyncEnabled 
                              ? 'Note will stay local only' 
                              : 'Note synced to cloud',
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              );
            },
          ),
          _buildActionButton(
            context,
            icon: note.isArchived ? Iconsax.archive_minus : Iconsax.archive_add,
            label: note.isArchived ? 'Unarchive' : 'Archive',
            onTap: () {
              context.read<NotesBloc>().add(
                NotesToggleArchiveRequested(noteId: note.id),
              );
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 10),
          _buildActionButton(
            context,
            icon: Iconsax.trash,
            label: 'Delete',
            isDestructive: true,
            onTap: () {
              Navigator.pop(context);
              _showDeleteDialog(context, note.id);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildColorPicker(BuildContext context) {
    final colors = [
      null, // No color
      '0xFFEF5350', // Red
      '0xFFEC407A', // Pink
      '0xFFAB47BC', // Purple
      '0xFF5C6BC0', // Indigo
      '0xFF42A5F5', // Blue
      '0xFF26A69A', // Teal
      '0xFF66BB6A', // Green
      '0xFFFFEE58', // Yellow
      '0xFFFF7043', // Orange
      '0xFF8D6E63', // Brown
      '0xFFBDBDBD', // Gray
      '0xFF9E9E9E', // Grey
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors.map((colorStr) {
            final isSelected = note.color == colorStr;
            return GestureDetector(
              onTap: () {
                context.read<NotesBloc>().add(
                  NotesUpdateColorRequested(noteId: note.id, color: colorStr),
                );
                // Close the sheet after a short delay to show selection
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorStr != null
                      ? Color(int.parse(colorStr))
                      : Colors.grey[200],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : Colors.grey[300]!,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: colorStr == null
                    ? Icon(
                        Iconsax.close_circle,
                        size: 20,
                        color: Colors.grey[600],
                      )
                    : isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTagsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tags',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            TextButton.icon(
              onPressed: () => _showAddTagDialog(context),
              icon: const Icon(Iconsax.add, size: 16),
              label: const Text('Add'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (note.tags.isEmpty)
          Text(
            'No tags yet',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: note.tags.map((tag) {
              return Chip(
                label: Text(tag),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  context.read<NotesBloc>().add(
                    NotesRemoveTagRequested(noteId: note.id, tag: tag),
                  );
                },
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
                labelStyle: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 12,
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withOpacity(0.08)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDestructive
                      ? Colors.red.withOpacity(0.15)
                      : AppTheme.primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: isDestructive ? Colors.red : AppTheme.primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDestructive ? Colors.red : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddTagDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Tag'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter tag name',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<NotesBloc>().add(
                  NotesAddTagRequested(
                    noteId: note.id,
                    tag: controller.text.trim(),
                  ),
                );
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String noteId) {
    final authState = context.read<AuthBloc>().state;
    final isAuthenticated = authState is AuthAuthenticated && !authState.isGuest;
    final notesBloc = context.read<NotesBloc>();
    final note = context.read<NotesBloc>().state is NotesLoaded
        ? (context.read<NotesBloc>().state as NotesLoaded)
            .notes
            .firstWhere((n) => n.id == noteId)
        : null;
    final isSynced = note?.isSyncEnabled ?? false;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Note?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose how you want to delete this note:',
            ),
            if (isAuthenticated && isSynced) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This note is synced to cloud',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          if (isAuthenticated && isSynced) ...[
            TextButton(
              onPressed: () {
                notesBloc.add(
                  NotesDeleteWithOptionsRequested(
                    noteId: noteId,
                    deleteFromCloud: false,
                  ),
                );
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Note deleted locally. Cloud copy remains.'),
                    backgroundColor: AppTheme.primaryColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              child: const Text('Local Only'),
            ),
            ElevatedButton(
              onPressed: () {
                notesBloc.add(
                  NotesDeleteWithOptionsRequested(
                    noteId: noteId,
                    deleteFromCloud: true,
                  ),
                );
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Note deleted from everywhere'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete Everywhere'),
            ),
          ] else
            ElevatedButton(
              onPressed: () {
                notesBloc.add(
                  NotesDeleteWithOptionsRequested(
                    noteId: noteId,
                    deleteFromCloud: false,
                  ),
                );
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
        ],
      ),
    );
  }
}
