import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

class DeepLinkHandler {
  static final DeepLinkHandler _instance = DeepLinkHandler._internal();
  factory DeepLinkHandler() => _instance;
  DeepLinkHandler._internal();

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  
  Function(String noteId)? _onNoteLink;

  // Initialize deep link handling
  Future<void> init({
    required Function(String noteId) onNoteLink,
  }) async {
    _onNoteLink = onNoteLink;

    // Handle initial link if app was opened from a deep link
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint('Failed to get initial link: $e');
    }

    // Listen for deep links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        _handleDeepLink(uri);
      },
      onError: (error) {
        debugPrint('Deep link error: $error');
      },
    );
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('Received deep link: $uri');
    
    // Parse the deep link
    // Expected formats:
    // - https://collabnotes.hostspica.com/note/{noteId}
    // - collabnotes://note/{noteId}
    
    final segments = uri.pathSegments;
    
    if (segments.length >= 2 && segments[0] == 'note') {
      final noteId = segments[1];
      debugPrint('Opening note: $noteId');
      _onNoteLink?.call(noteId);
    } else if (segments.length == 1 && segments[0].startsWith('note/')) {
      // Handle case where path is "note/{noteId}" as single segment
      final noteId = segments[0].substring(5);
      debugPrint('Opening note: $noteId');
      _onNoteLink?.call(noteId);
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
  }
}
