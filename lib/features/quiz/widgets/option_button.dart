import 'package:flutter/material.dart';

class OptionButton extends StatelessWidget {
  final String optionLetter; // A, B, C, D
  final String optionText;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isReviewMode;
  final bool? isCorrect; // For review mode

  const OptionButton({
    super.key,
    required this.optionLetter,
    required this.optionText,
    required this.isSelected,
    required this.onTap,
    this.isReviewMode = false,
    this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    // Determine colors based on state
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    Widget? trailingIcon;

    if (isReviewMode && isCorrect != null) {
      // Review mode - show correct/wrong
      if (isCorrect!) {
        backgroundColor = Colors.green.shade50;
        borderColor = Colors.green;
        textColor = Colors.green.shade900;
        trailingIcon = const Icon(Icons.check_circle, color: Colors.green);
      } else {
        backgroundColor = Colors.red.shade50;
        borderColor = Colors.red;
        textColor = Colors.red.shade900;
        trailingIcon = const Icon(Icons.cancel, color: Colors.red);
      }
    } else if (isSelected) {
      // Selected state
      backgroundColor = const Color(0xFF4DB6AC); // Green tosca
      borderColor = const Color(0xFF4DB6AC);
      textColor = Colors.white;
      trailingIcon = const Icon(Icons.check, color: Colors.white);
    } else {
      // Default state
      backgroundColor = Colors.white;
      borderColor = Colors.black;
      textColor = Colors.black87;
      trailingIcon = null;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isReviewMode ? null : onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            children: [
              // Letter circle (A, B, C, D)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.3)
                      : borderColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.white : borderColor,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    optionLetter,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : borderColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Option text
              Expanded(
                child: Text(
                  optionText,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),

              // Trailing icon (checkmark or status)
              if (trailingIcon != null) ...[
                const SizedBox(width: 8),
                trailingIcon,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
