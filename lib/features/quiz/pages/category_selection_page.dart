import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz_model.dart';
import '../providers/quiz_provider.dart';
import 'quiz_page.dart';

class CategorySelectionPage extends StatelessWidget {
  const CategorySelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1),
      appBar: AppBar(
        title: const Text(
          'Pilih Kategori Quiz',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Quiz
              const Icon(Icons.quiz, size: 100, color: Color(0xFF4DB6AC)),
              const SizedBox(height: 20),

              // Title
              const Text(
                'Quiz Budaya Indonesia',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // Subtitle
              const Text(
                'Pilih kategori quiz yang ingin kamu ikuti',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),

              // Category Cards
              _buildCategoryCard(
                context: context,
                title: 'Pakaian Daerah',
                subtitle: 'Quiz tentang pakaian tradisional Indonesia',
                icon: Icons.checkroom,
                color: const Color(0xFF4DB6AC), // Green Tosca
                category: QuizCategory.pakaian,
              ),
              const SizedBox(height: 20),

              _buildCategoryCard(
                context: context,
                title: 'Lagu Daerah',
                subtitle: 'Quiz tentang lagu tradisional Indonesia',
                icon: Icons.music_note,
                color: const Color(0xFFFFA726), // Orange
                category: QuizCategory.lagu,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required QuizCategory category,
  }) {
    return InkWell(
      onTap: () async {
        // Load questions
        final provider = context.read<QuizProvider>();
        provider.loadQuestions(category);

        // Navigate to quiz page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QuizPage()),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 3),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, size: 50, color: color),
            ),
            const SizedBox(width: 20),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(Icons.arrow_forward_ios, color: color, size: 30),
          ],
        ),
      ),
    );
  }
}
