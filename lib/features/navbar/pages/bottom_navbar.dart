import 'package:budaya_indonesia/features/ar/pages/ar_page.dart';
import 'package:budaya_indonesia/features/home/pages/home_page.dart';
import 'package:budaya_indonesia/features/music/pages/music_page.dart';
import 'package:budaya_indonesia/features/navbar/providers/navbar_provider.dart';
import 'package:budaya_indonesia/features/profile/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// using Material icons for the bottom navigation
/// Bottom navigation bar using Material icons with 5 pages.
class BottomNavbar extends StatefulWidget {
  final int? currentIndex;
  final ValueChanged<int>? onTap;

  const BottomNavbar({super.key, this.currentIndex, this.onTap});

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  late int _selectedIndex;

  // Use plain IconData for the bottom navigation
  final List<IconData> _tabIcons = [
    Icons.home,
    Icons.audiotrack,
    Icons.camera_alt,
    Icons.photo_album,
    Icons.person,
  ];

  final List<Widget> _pages = [
    // Home
    HomePage(),
    MusicPage(),
    Scaffold(
      appBar: AppBar(title: const Text('')),
      body: const Center(child: Text('Quiz page')),
    ),
    Scaffold(
      appBar: AppBar(title: const Text('')),
      body: const Center(child: Text('Clothes page')),
    ),
    ProfilePage(),
  ];
  void _onItemTapped(int index) {
    if (index == 2) {
      // Navigasi ke halaman AR dan hilangkan navbar
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ArPage(), // buka ARPage di route baru
        ),
      );
      return;
    }
    setState(() => _selectedIndex = index);
    if (widget.onTap != null) {
      widget.onTap!(index);
    } else {
      final prov = context.read<NavbarProvider?>();
      prov?.setIndex(index);
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<NavbarProvider?>(context);
    final displayIndex = prov?.index ?? _selectedIndex;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    // Fixed visual height for the custom nav; keep in sync with SizedBox below
    const navHeight = 84.0;
    // Reserve space so page content isn't hidden behind the floating navbar
    // Add a small extra buffer to account for elevation/shadow and device variations
    final reservedBottom =
        navHeight + 20 /*buffer*/ + 12 /*outer bottom pad*/ + bottomInset;

    return Scaffold(
      extendBody: true, // let page background flow under nav shape
      body: Padding(
        padding: EdgeInsets.only(bottom: reservedBottom),
        child: IndexedStack(index: displayIndex, children: _pages),
      ),
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: SizedBox(
            height: navHeight,
            child: Material(
              elevation: 8,
              // use app theme primary so navbar follows ThemeData in main.dart
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: Row(
                  children: List.generate(_tabIcons.length, (i) {
                    final isActive = i == displayIndex;

                    return Expanded(
                      child: InkWell(
                        onTap: () => _onItemTapped(i),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _tabIcons[i],
                                size: isActive ? 30 : 24,
                                color: isActive
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(
                                        context,
                                        // ignore: deprecated_member_use
                                      ).colorScheme.onPrimary.withOpacity(0.85),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _labelForIndex(i),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isActive
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(
                                          context,
                                          // ignore: deprecated_member_use
                                        ).colorScheme.onPrimary.withOpacity(
                                          0.85,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _labelForIndex(int i) {
    switch (i) {
      case 0:
        return 'Home';
      case 1:
        return 'Audio';
      case 2:
        return 'AR';
      case 3:
        return 'Clothes';
      case 4:
        return 'Profile';
      default:
        return '';
    }
  }
}
