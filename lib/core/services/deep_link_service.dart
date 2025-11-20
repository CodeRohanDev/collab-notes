import 'dart:async';
import 'package:share_plus/share_plus.dart';

class DeepLinkService {
  static const String baseUrl = 'https://collabnotes.hostspica.com';
  
  // Generate a shareable link for a note
  static String generateNoteShareLink(String noteId) {
    return '$baseUrl/note/$noteId';
  }

  // Share a note via system share sheet
  static Future<void> shareNote({
    required String noteId,
    required String noteTitle,
    String? noteContent,
  }) async {
    final link = generateNoteShareLink(noteId);

    final String shareText = noteContent != null && noteContent.isNotEmpty
        ? 'Collaborate with me on "$noteTitle" in CollabNotes!\n\n${_truncateContent(noteContent)}\n\nOpen: $link'
        : 'Collaborate with me on "$noteTitle" in CollabNotes!\n\nOpen: $link';

    await Share.share(
      shareText,
      subject: 'Collaborate on: $noteTitle',
    );
  }

  // Share with custom message
  static Future<void> shareNoteWithMessage({
    required String noteId,
    required String noteTitle,
    required String message,
  }) async {
    final link = generateNoteShareLink(noteId);
    final shareText = '$message\n\nOpen: $link';

    await Share.share(
      shareText,
      subject: 'Collaborate on: $noteTitle',
    );
  }

  static String _truncateContent(String content, {int maxLength = 150}) {
    if (content.length <= maxLength) return content;
    return '${content.substring(0, maxLength)}...';
  }

  // Get note share URL
  static String getNoteShareUrl(String noteId) {
    return '$baseUrl/note/$noteId';
  }

  // Parse deep link to extract note ID
  static String? parseNoteIdFromLink(String link) {
    try {
      final uri = Uri.parse(link);
      
      // Handle https://collabnotes.hostspica.com/note/{noteId}
      if (uri.host == 'collabnotes.hostspica.com' && 
          uri.pathSegments.length >= 2 && 
          uri.pathSegments[0] == 'note') {
        return uri.pathSegments[1];
      }
      
      // Handle collabnotes://note/{noteId}
      if (uri.scheme == 'collabnotes' && 
          uri.pathSegments.isNotEmpty && 
          uri.pathSegments[0] == 'note' &&
          uri.pathSegments.length >= 2) {
        return uri.pathSegments[1];
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
}
