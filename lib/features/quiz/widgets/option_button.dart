import 'package:flutter/material.dart';

class OptionButton extends StatelessWidget {
  final String optionLetter; // A, B, C, D
  final String optionText;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isReviewMode;
  final bool? isCorrect; // For review mode
  final bool showCorrect; // For live feedback (correct answer highlight)
  final bool showWrong; // For live feedback (wrong answer highlight)

  const OptionButton({
    super.key,
    required this.optionLetter,
    required this.optionText,
    required this.isSelected,
    required this.onTap,
    this.isReviewMode = false,
    this.isCorrect,
    this.showCorrect = false,
    this.showWrong = false,
  });

  @override
  Widget build(BuildContext context) {
    // Determine colors based on state
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    Widget? trailingIcon;

    // Priority: showCorrect/showWrong > isReviewMode > isSelected > default
    if (showCorrect) {
      // Live feedback - correct answer
      backgroundColor = Colors.green.shade50;
      borderColor = Colors.green;
      textColor = Colors.green.shade900;
      trailingIcon = const Icon(Icons.check_circle, color: Colors.green);
    } else if (showWrong) {
      // Live feedback - wrong answer
      backgroundColor = Colors.red.shade50;
      borderColor = Colors.red;
      textColor = Colors.red.shade900;
      trailingIcon = const Icon(Icons.cancel, color: Colors.red);
    } else if (isReviewMode && isCorrect != null) {
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
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: (isReviewMode || showCorrect || showWrong || onTap == null)
            ? null
            : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            children: [
              // Letter circle (A, B, C, D)
              Container(
                width: 32,
                height: 32,
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
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : borderColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Option text
              Expanded(
                child: Text(
                  optionText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                    height: 1.3,
                  ),
                ),
              ),

              // Trailing icon (checkmark or status)
              if (trailingIcon != null) ...[
                const SizedBox(width: 6),
                SizedBox(width: 20, height: 20, child: trailingIcon),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
