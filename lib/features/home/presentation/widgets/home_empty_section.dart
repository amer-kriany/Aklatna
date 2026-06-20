import 'package:flutter/material.dart';

class HomeEmptySection extends StatelessWidget {
  const HomeEmptySection({required this.height, super.key});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}
