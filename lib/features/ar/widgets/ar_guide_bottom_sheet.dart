import 'package:flutter/material.dart';

class ArGuideBottomSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.55,
          child: const _ArGuideContent(),
        );
      },
    );
  }
}

class _ArGuideContent extends StatelessWidget {
  const _ArGuideContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
                margin: const EdgeInsets.only(bottom: 16),
              ),
            ),

            const Center(
              child: Text(
                "Panduan Pengambilan Gambar",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.teal,
                ),
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.only(left: 15), 
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "1.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Posisikan tubuh sejajar dengan kamera",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const _GuideBox(
                          imagePath: 'assets/images/scan_right.png',
                          label: 'posisi yang benar',
                          color: Colors.teal,
                          checkIcon: Icons.check_circle_outline,
                        ),
                        const SizedBox(height: 12),
                        const _GuideBox(
                          imagePath: 'assets/images/scan_false.png',
                          label: 'posisi yang salah',
                          color: Color(0xFFBCAAA4),
                          checkIcon: Icons.cancel_outlined,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "2.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      "Abadikan foto anda sesuai pakaian adat yang anda pilih",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _GuideBox extends StatelessWidget {
  final String imagePath;
  final String label;
  final Color color;
  final IconData checkIcon;

  const _GuideBox({
    required this.imagePath,
    required this.label,
    required this.color,
    required this.checkIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            imagePath,
            width: 28,
            height: 28,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Icon(checkIcon, color: Colors.white, size: 22),
        ],
      ),
    );
  }
}
