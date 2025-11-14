import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../data/models/note_model.dart';
import '../../bloc/notes/notes_bloc.dart';
import '../../../core/theme/app_theme.dart';

class ChecklistItem {
  final String text;
  final bool isChecked;

  ChecklistItem({required this.text, required this.isChecked});
}

class NoteEditorScreen extends StatefulWidget {
  final NoteModel? note;

  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late FocusNode _titleFocusNode;
  late FocusNode _contentFocusNode;
  bool _hasChanges = false;
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderline = false;
  final ImagePicker _imagePicker = ImagePicker();
  List<ChecklistItem> _checklistItems = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _titleFocusNode = FocusNode();
    _contentFocusNode = FocusNode();

    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
    
    // Add listeners to rebuild when focus changes
    _titleFocusNode.addListener(() => setState(() {}));
    _contentFocusNode.addListener(() => setState(() {}));
    
    // Load existing checklist items
    if (widget.note?.checklistItems != null) {
      _checklistItems = widget.note!.checklistItems
          .map((item) => ChecklistItem(
                text: item['text'] as String,
                isChecked: item['isChecked'] as bool,
              ))
          .toList();
    }
  }

  void _onTextChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_hasChanges) {
      _saveNote();
    }
    return true;
  }

  void _saveNote() {
    if (_titleController.text.isEmpty && _contentController.text.isEmpty && _checklistItems.isEmpty) {
      return;
    }

    final checklistData = _checklistItems
        .map((item) => {'text': item.text, 'isChecked': item.isChecked})
        .toList();

    if (widget.note == null) {
      context.read<NotesBloc>().add(
            NotesCreateRequested(
              title: _titleController.text,
              content: _contentController.text,
              checklistItems: checklistData,
            ),
          );
    } else {
      context.read<NotesBloc>().add(
            NotesUpdateRequested(
              noteId: widget.note!.id,
              title: _titleController.text,
              content: _contentController.text,
              checklistItems: checklistData,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Iconsax.arrow_left_2, color: Colors.black87),
            onPressed: () {
              if (_hasChanges) {
                _saveNote();
              }
              Navigator.pop(context);
            },
          ),
          title: Text(
            widget.note == null ? 'New Note' : 'Edit Note',
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            if (_hasChanges)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Iconsax.edit,
                      size: 14,
                      color: AppTheme.successColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Editing',
                      style: TextStyle(
                        color: AppTheme.successColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            IconButton(
              icon: Icon(
                Iconsax.more,
                color: Colors.black87,
              ),
              onPressed: () {
                _showOptionsMenu(context);
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Toolbar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: Row(
                children: [
                  _buildToolbarButton(
                    Iconsax.text_bold,
                    'Bold',
                    isActive: _isBold,
                    onPressed: _toggleBold,
                  ),
                  _buildToolbarButton(
                    Iconsax.text_italic,
                    'Italic',
                    isActive: _isItalic,
                    onPressed: _toggleItalic,
                  ),
                  _buildToolbarButton(
                    Iconsax.text_underline,
                    'Underline',
                    isActive: _isUnderline,
                    onPressed: _toggleUnderline,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 1,
                    height: 24,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(width: 8),
                  _buildToolbarButton(
                    Iconsax.task_square,
                    'Checklist',
                    onPressed: _insertChecklist,
                  ),
                  _buildToolbarButton(
                    Iconsax.image,
                    'Image',
                    onPressed: _pickImage,
                  ),
                  _buildToolbarButton(
                    Iconsax.microphone,
                    'Voice',
                    onPressed: _recordAudio,
                  ),
                  const Spacer(),
                  Text(
                    '${_contentController.text.length} chars',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  // If tapped outside title, focus on content
                  if (!_titleFocusNode.hasFocus) {
                    _contentFocusNode.requestFocus();
                  }
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Field
                      TextField(
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
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.transparent,
                            ),
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
                          _contentFocusNode.requestFocus();
                        },
                      ),
                      const SizedBox(height: 20),
                      // Checklist Items
                      if (_checklistItems.isNotEmpty) ...[
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _checklistItems.length,
                          itemBuilder: (context, index) {
                            return _buildChecklistItem(index);
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                      // Content Field
                      TextField(
                        controller: _contentController,
                        focusNode: _contentFocusNode,
                        decoration: InputDecoration(
                          hintText: _checklistItems.isEmpty ? 'Start typing...' : 'Add notes...',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.6,
                        ),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                      ),
                      // Add extra space at bottom for better scrolling
                      const SizedBox(height: 200),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _hasChanges
            ? Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Iconsax.close_circle),
                        label: const Text('Discard'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _saveNote();
                            Navigator.pop(context);
                          },
                          icon: const Icon(Iconsax.tick_circle, color: Colors.white),
                          label: const Text(
                            'Save Note',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildToolbarButton(IconData icon, String tooltip, {bool isActive = false, VoidCallback? onPressed}) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isActive ? AppTheme.primaryColor : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  void _toggleBold() {
    setState(() {
      _isBold = !_isBold;
    });
    _applyFormatting();
  }

  void _toggleItalic() {
    setState(() {
      _isItalic = !_isItalic;
    });
    _applyFormatting();
  }

  void _toggleUnderline() {
    setState(() {
      _isUnderline = !_isUnderline;
    });
    _applyFormatting();
  }

  void _applyFormatting() {
    final selection = _contentController.selection;
    
    if (!selection.isValid) {
      _showSnackBar('Please select text to format');
      return;
    }
    
    if (selection.isCollapsed) {
      _showSnackBar('Select text first, then apply formatting');
      return;
    }

    final text = _contentController.text;
    final selectedText = text.substring(selection.start, selection.end);
    
    // Apply markdown-style formatting for storage
    String formattedText = selectedText;
    
    if (_isBold && !selectedText.startsWith('**')) {
      formattedText = '**$formattedText**';
    } else if (!_isBold && selectedText.startsWith('**')) {
      formattedText = selectedText.replaceAll('**', '');
    }
    
    if (_isItalic && !selectedText.startsWith('*')) {
      formattedText = '*$formattedText*';
    } else if (!_isItalic && selectedText.startsWith('*') && !selectedText.startsWith('**')) {
      formattedText = selectedText.replaceAll('*', '');
    }
    
    if (_isUnderline && !selectedText.startsWith('__')) {
      formattedText = '__${formattedText}__';
    } else if (!_isUnderline && selectedText.startsWith('__')) {
      formattedText = selectedText.replaceAll('__', '');
    }

    // Replace selected text
    final newText = text.replaceRange(selection.start, selection.end, formattedText);
    _contentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: selection.start + formattedText.length),
    );
    
    // Reset formatting buttons
    setState(() {
      _isBold = false;
      _isItalic = false;
      _isUnderline = false;
    });
    
    _showSnackBar('Formatting applied!');
  }

  void _insertChecklist() {
    setState(() {
      _checklistItems.add(ChecklistItem(text: '', isChecked: false));
      _hasChanges = true;
    });
  }

  Widget _buildChecklistItem(int index) {
    final item = _checklistItems[index];
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Checkbox
          InkWell(
            onTap: () {
              setState(() {
                _checklistItems[index] = ChecklistItem(
                  text: item.text,
                  isChecked: !item.isChecked,
                );
                _hasChanges = true;
              });
            },
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: item.isChecked ? AppTheme.primaryColor : Colors.transparent,
                border: Border.all(
                  color: item.isChecked ? AppTheme.primaryColor : Colors.grey[400]!,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: item.isChecked
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          // Text field
          Expanded(
            child: TextField(
              controller: TextEditingController(text: item.text)
                ..selection = TextSelection.collapsed(offset: item.text.length),
              decoration: InputDecoration(
                hintText: 'List item',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(
                fontSize: 16,
                color: item.isChecked ? Colors.grey[500] : Colors.black87,
                decoration: item.isChecked ? TextDecoration.lineThrough : null,
                decorationColor: Colors.grey[500],
              ),
              onChanged: (value) {
                _checklistItems[index] = ChecklistItem(
                  text: value,
                  isChecked: item.isChecked,
                );
                _hasChanges = true;
              },
            ),
          ),
          // Delete button
          IconButton(
            icon: Icon(
              Iconsax.trash,
              size: 18,
              color: Colors.grey[400],
            ),
            onPressed: () {
              setState(() {
                _checklistItems.removeAt(index);
                _hasChanges = true;
              });
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      // On Android 13+ (API 33+), no permission needed for image picker
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final cursorPos = _contentController.selection.baseOffset;
        final text = _contentController.text;
        
        final newText = text.substring(0, cursorPos) + 
                        '\n📷 [Image: ${image.name}]\n' + 
                        text.substring(cursorPos);
        
        _contentController.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: cursorPos + newText.length - text.length),
        );
        
        _showSnackBar('Image added successfully!');
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e');
    }
  }

  Future<void> _recordAudio() async {
    try {
      // Request microphone permission
      final status = await Permission.microphone.request();
      
      if (status.isPermanentlyDenied) {
        // Show dialog to open settings
        if (!mounted) return;
        _showPermissionDialog(
          'Microphone Permission Required',
          'Please enable microphone access in your device settings to record audio.',
          () => openAppSettings(),
        );
        return;
      }
      
      if (!status.isGranted) {
        _showSnackBar('Microphone permission is required to record audio');
        return;
      }

      // Permission granted, show recording dialog
      if (!mounted) return;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Iconsax.microphone, color: Colors.red),
              ),
              const SizedBox(width: 12),
              const Text('Voice Recording'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Iconsax.microphone, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Recording...',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                'Full audio recording coming soon!',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _insertAudioPlaceholder();
              },
              icon: const Icon(Iconsax.stop_circle),
              label: const Text('Stop'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  void _showPermissionDialog(String title, String message, VoidCallback onOpenSettings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onOpenSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _insertAudioPlaceholder() {
    final cursorPos = _contentController.selection.baseOffset;
    final text = _contentController.text;
    
    final newText = text.substring(0, cursorPos) + 
                    '\n🎤 [Audio Recording]\n' + 
                    text.substring(cursorPos);
    
    _contentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursorPos + newText.length - text.length),
    );
    
    _showSnackBar('Audio placeholder added!');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            _buildOptionTile(
              Iconsax.share,
              'Share',
              'Share this note',
              () {},
            ),
            _buildOptionTile(
              Iconsax.copy,
              'Duplicate',
              'Make a copy',
              () {},
            ),
            _buildOptionTile(
              Iconsax.archive,
              'Archive',
              'Move to archive',
              () {},
            ),
            _buildOptionTile(
              Iconsax.trash,
              'Delete',
              'Delete this note',
              () {},
              isDestructive: true,
            ),
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
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withOpacity(0.1)
              : AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : AppTheme.primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDestructive ? Colors.red : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

}

