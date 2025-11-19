import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:iconsax/iconsax.dart';
import '../../../data/models/note_model.dart';
import '../../bloc/notes/notes_bloc.dart';
import '../../../core/theme/app_theme.dart';
import 'share_note_dialog.dart';

class RichNoteEditorScreen extends StatefulWidget {
  final NoteModel? note;

  const RichNoteEditorScreen({super.key, this.note});

  @override
  State<RichNoteEditorScreen> createState() => _RichNoteEditorScreenState();
}

class _RichNoteEditorScreenState extends State<RichNoteEditorScreen> {
  late TextEditingController _titleController;
  late quill.QuillController _quillController;
  late FocusNode _titleFocusNode;
  late FocusNode _editorFocusNode;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _titleFocusNode = FocusNode();
    _editorFocusNode = FocusNode();

    // Initialize Quill controller with existing content or empty
    if (widget.note?.content != null && widget.note!.content.isNotEmpty) {
      try {
        final doc = quill.Document.fromJson(jsonDecode(widget.note!.content));
        _quillController = quill.QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        // If content is not JSON (old format), create plain text document
        _quillController = quill.QuillController.basic();
        _quillController.document.insert(0, widget.note!.content);
      }
    } else {
      _quillController = quill.QuillController.basic();
    }

    _titleController.addListener(_onTextChanged);
    _quillController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      if (!_hasChanges) {
        _hasChanges = true;
      }
    });
  }

  String _getWordCount() {
    final text = _quillController.document.toPlainText();
    final words = text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    final chars = text.length;
    return '$words words · $chars chars';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    _titleFocusNode.dispose();
    _editorFocusNode.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (_titleController.text.isEmpty && _quillController.document.isEmpty()) {
      return;
    }

    // Convert Quill document to JSON for storage
    final content = jsonEncode(_quillController.document.toDelta().toJson());

    if (widget.note == null) {
      context.read<NotesBloc>().add(
            NotesCreateRequested(
              title: _titleController.text,
              content: content,
            ),
          );
    } else {
      context.read<NotesBloc>().add(
            NotesUpdateRequested(
              noteId: widget.note!.id,
              title: _titleController.text,
              content: content,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && _hasChanges) {
          _saveNote();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor.withValues(alpha: 0.05),
                  AppTheme.secondaryColor.withValues(alpha: 0.03),
                ],
              ),
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Iconsax.arrow_left_2,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                onPressed: () {
                  if (_hasChanges) {
                    _saveNote();
                    setState(() {
                      _hasChanges = false; // Prevent double save
                    });
                  }
                  Navigator.pop(context);
                },
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.note == null ? 'New Note' : 'Edit Note',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_hasChanges)
                    Text(
                      'Unsaved changes',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                ],
              ),
              actions: [
                if (widget.note != null)
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Iconsax.share,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                    onPressed: () => _showShareDialog(),
                  ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Iconsax.more,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                  onPressed: () => _showOptionsMenu(context),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            // Title Field
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: TextField(
                controller: _titleController,
                focusNode: _titleFocusNode,
                decoration: InputDecoration(
                  hintText: 'Title',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  border: InputBorder.none,
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.only(bottom: 8),
                ),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: null,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) {
                  _editorFocusNode.requestFocus();
                },
              ),
            ),
            // Quill Toolbar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // History buttons
                    _buildToolbarSection([
                      quill.QuillToolbarHistoryButton(
                        controller: _quillController,
                        isUndo: true,
                      ),
                      quill.QuillToolbarHistoryButton(
                        controller: _quillController,
                        isUndo: false,
                      ),
                    ]),
                    _buildDivider(),
                    // Text formatting
                    _buildToolbarSection([
                      quill.QuillToolbarToggleStyleButton(
                        attribute: quill.Attribute.bold,
                        controller: _quillController,
                      ),
                      quill.QuillToolbarToggleStyleButton(
                        attribute: quill.Attribute.italic,
                        controller: _quillController,
                      ),
                      quill.QuillToolbarToggleStyleButton(
                        attribute: quill.Attribute.underline,
                        controller: _quillController,
                      ),
                      quill.QuillToolbarToggleStyleButton(
                        attribute: quill.Attribute.strikeThrough,
                        controller: _quillController,
                      ),
                    ]),
                    _buildDivider(),
                    // Lists
                    _buildToolbarSection([
                      quill.QuillToolbarToggleStyleButton(
                        attribute: quill.Attribute.ul,
                        controller: _quillController,
                      ),
                      quill.QuillToolbarToggleStyleButton(
                        attribute: quill.Attribute.ol,
                        controller: _quillController,
                      ),
                      quill.QuillToolbarToggleStyleButton(
                        attribute: quill.Attribute.unchecked,
                        controller: _quillController,
                      ),
                    ]),
                    _buildDivider(),
                    // Code & Link
                    _buildToolbarSection([
                      quill.QuillToolbarToggleStyleButton(
                        attribute: quill.Attribute.inlineCode,
                        controller: _quillController,
                      ),
                      quill.QuillToolbarToggleStyleButton(
                        attribute: quill.Attribute.codeBlock,
                        controller: _quillController,
                      ),
                      quill.QuillToolbarLinkStyleButton(
                        controller: _quillController,
                      ),
                    ]),
                  ],
                ),
              ),
            ),
            // Quill Editor
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  _editorFocusNode.requestFocus();
                },
                child: Container(
                  color: Colors.white,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
                        child: quill.QuillEditor.basic(
                          controller: _quillController,
                          focusNode: _editorFocusNode,
                        ),
                      ),
                    // Word count indicator
                    Positioned(
                      bottom: 16,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Iconsax.document_text,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _getWordCount(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: _hasChanges ? 80 : 0,
          child: _hasChanges
              ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, -4),
                      ),
                    ],
                    border: Border(
                      top: BorderSide(color: Colors.grey[200]!, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _hasChanges = false; // Prevent save on discard
                            });
                            Navigator.pop(context);
                          },
                          icon: const Icon(Iconsax.close_circle, size: 20),
                          label: const Text('Discard'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey[700],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _saveNote();
                              setState(() {
                                _hasChanges = false; // Prevent double save
                              });
                              Navigator.pop(context);
                            },
                            icon: const Icon(Iconsax.tick_circle, color: Colors.white, size: 20),
                            label: const Text(
                              'Save Note',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }

  void _showShareDialog() {
    if (widget.note == null) return;
    
    showDialog(
      context: context,
      builder: (context) => ShareNoteDialog(note: widget.note!),
    );
  }

  void _duplicateNote() {
    Navigator.pop(context); // Close options menu
    
    if (widget.note == null) return;
    
    // Create a copy with new ID
    final content = jsonEncode(_quillController.document.toDelta().toJson());
    
    context.read<NotesBloc>().add(
          NotesCreateRequested(
            title: '${_titleController.text} (Copy)',
            content: content,
          ),
        );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Note duplicated successfully!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    
    Navigator.pop(context); // Go back to home
  }

  void _archiveNote() {
    Navigator.pop(context); // Close options menu
    
    if (widget.note == null) return;
    
    context.read<NotesBloc>().add(
          NotesToggleArchiveRequested(noteId: widget.note!.id),
        );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.note!.isArchived ? 'Note unarchived' : 'Note archived',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    
    Navigator.pop(context); // Go back to home
  }

  void _deleteNote() {
    Navigator.pop(context); // Close options menu
    
    if (widget.note == null) return;
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Delete Note?'),
        content: const Text(
          'This note will be permanently deleted. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<NotesBloc>().add(
                    NotesDeleteRequested(noteId: widget.note!.id),
                  );
              Navigator.pop(dialogContext); // Close dialog
              Navigator.pop(context); // Go back to home
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Note deleted'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
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

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            // Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Iconsax.setting_2,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Note Options',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Options
            if (widget.note != null) ...[
              _buildOptionTile(
                widget.note!.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                widget.note!.isPinned ? 'Unpin Note' : 'Pin Note',
                widget.note!.isPinned ? 'Remove from top' : 'Keep at top',
                () {
                  context.read<NotesBloc>().add(
                        NotesTogglePinRequested(noteId: widget.note!.id),
                      );
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
            ],
            _buildOptionTile(
              Iconsax.share,
              'Share',
              'Share this note with others',
              () => _showShareDialog(),
            ),
            const SizedBox(height: 8),
            if (widget.note != null) ...[
              _buildOptionTile(
                Iconsax.copy,
                'Duplicate',
                'Make a copy of this note',
                () => _duplicateNote(),
              ),
              const SizedBox(height: 8),
              _buildOptionTile(
                widget.note!.isArchived ? Iconsax.archive_minus : Iconsax.archive_add,
                widget.note!.isArchived ? 'Unarchive' : 'Archive',
                widget.note!.isArchived ? 'Restore from archive' : 'Move to archive',
                () => _archiveNote(),
              ),
              const SizedBox(height: 8),
              _buildOptionTile(
                Iconsax.trash,
                'Delete',
                'Delete this note permanently',
                () => _deleteNote(),
                isDestructive: true,
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withValues(alpha: 0.05)
                : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDestructive
                  ? Colors.red.withValues(alpha: 0.2)
                  : Colors.grey[200]!,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDestructive
                      ? Colors.red.withValues(alpha: 0.1)
                      : AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isDestructive ? Colors.red : AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: isDestructive ? Colors.red : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Iconsax.arrow_right_3,
                size: 18,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolbarSection(List<Widget> buttons) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: buttons.map((button) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: button,
        );
      }).toList(),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(0.5),
      ),
    );
  }
}
