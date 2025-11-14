class OnboardingData {
  final String title;
  final String description;
  final String icon;

  const OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
  });

  static const List<OnboardingData> pages = [
    OnboardingData(
      title: 'Create Notes Anywhere',
      description: 'Write, edit, and organize your thoughts offline or online',
      icon: '📝',
    ),
    OnboardingData(
      title: 'Works Offline',
      description: 'Your notes are always available, even without internet',
      icon: '📱',
    ),
    OnboardingData(
      title: 'Sync Across Devices',
      description: 'Sign in to sync your notes across all your devices',
      icon: '☁️',
    ),
    OnboardingData(
      title: 'Collaborate in Real-time',
      description: 'Share notes and work together with your team',
      icon: '👥',
    ),
  ];
}
