import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.backgroundColor,
    this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: textColor ?? Colors.grey.shade800),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor ?? Colors.grey.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor ?? Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
