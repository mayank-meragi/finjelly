import 'package:flutter/material.dart';

class MetadataBadge extends StatelessWidget {
  const MetadataBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 4,
      right: 4,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.9),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(Icons.info, size: 16, color: Colors.white),
      ),
    );
  }
}
