import 'package:budaya_indonesia/features/music/widgets/timezone_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:budaya_indonesia/features/music/models/time_zone_model.dart';

class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Lagu Tradisional',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: GoogleFonts.roboto().fontFamily,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: indonesianTimeZones.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final zone = indonesianTimeZones[index];
          return TimeZoneCard(
            zone: zone,
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/music/detail',
                arguments: {'zone': zone.code},
              );
            },
          );
        },
      ),
    );
  }
}
