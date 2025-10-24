import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:budaya_indonesia/common/static/app_color.dart';

class ScoreBar extends StatefulWidget {
  final int currentScore;
  final int maxScore;

  const ScoreBar({
    super.key,
    required this.currentScore,
    required this.maxScore,
  });

  @override
  State<ScoreBar> createState() => _ScoreBarState();
}

class _ScoreBarState extends State<ScoreBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _scoreController;
  late Animation<int> _scoreAnimation;
  int _previousScore = 0;

  @override
  void initState() {
    super.initState();
    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _previousScore = widget.currentScore;
    _scoreAnimation = IntTween(
      begin: widget.currentScore,
      end: widget.currentScore,
    ).animate(_scoreController);
  }

  @override
  void didUpdateWidget(ScoreBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentScore != widget.currentScore) {
      _scoreAnimation =
          IntTween(begin: _previousScore, end: widget.currentScore).animate(
            CurvedAnimation(
              parent: _scoreController,
              curve: Curves.easeOutCubic,
            ),
          );
      _scoreController.forward(from: 0);
      _previousScore = widget.currentScore;
    }
  }

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.maxScore > 0
        ? widget.currentScore / widget.maxScore
        : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        tween: Tween<double>(begin: 0, end: progress),
        builder: (context, value, _) {
          return AnimatedBuilder(
            animation: _scoreAnimation,
            builder: (context, child) {
              return Container(
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: LinearProgressIndicator(
                        value: value,
                        minHeight: 32,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.accent,
                        ),
                      ),
                    ),

                    Center(
                      child: Text(
                        'Skor : ${_scoreAnimation.value}/${widget.maxScore}',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
