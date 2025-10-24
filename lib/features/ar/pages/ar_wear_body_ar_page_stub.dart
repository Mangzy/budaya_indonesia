import 'package:flutter/material.dart';

class ArWearBodyArPage extends StatelessWidget {
  final String title;
  final String? iosSrcUrl;
  const ArWearBodyArPage({super.key, required this.title, this.iosSrcUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Body Tracking AR (try-on 3D) saat ini hanya tersedia di iOS.\n' 
            'Di Android, ARCore tidak menyediakan body tracking bawaan.\n' 
            'Gunakan viewer AR biasa atau fitur 2D Try-On. ',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
