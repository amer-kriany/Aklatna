class OnboardingItem {
  final String title;
  final String description;
  final String imagePath; // or Network URL / Lottie animation

  const OnboardingItem({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}