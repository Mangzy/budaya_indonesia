import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:budaya_indonesia/common/static/app_color.dart';

class OptionButton extends StatelessWidget {
  final String optionLetter;
  final String optionText;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isReviewMode;
  final bool? isCorrect;
  final bool showCorrect;
  final bool showWrong;

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
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    Widget? trailingIcon;

    if (showCorrect) {
      backgroundColor = Colors.green.shade50;
      borderColor = Colors.green;
      textColor = Colors.green.shade900;
      trailingIcon = const Icon(Icons.check_circle, color: Colors.green);
    } else if (showWrong) {
      backgroundColor = Colors.red.shade50;
      borderColor = Colors.red;
      textColor = Colors.red.shade900;
      trailingIcon = const Icon(Icons.cancel, color: Colors.red);
    } else if (isReviewMode && isCorrect != null) {
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
      backgroundColor = AppColors.primary;
      borderColor = AppColors.primary;
      textColor = Colors.white;
      trailingIcon = const Icon(Icons.check, color: Colors.white);
    } else {
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

              Expanded(
                child: Text(
                  optionText,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                    height: 1.3,
                  ),
                ),
              ),

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
