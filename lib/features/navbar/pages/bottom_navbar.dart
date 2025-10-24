import 'package:budaya_indonesia/clothes/pages/pakaian_daerah_page.dart';
import 'package:budaya_indonesia/features/ar/pages/ar_page.dart';
import 'package:budaya_indonesia/features/home/pages/home_page.dart';
import 'package:budaya_indonesia/features/music/pages/music_page.dart';
import 'package:budaya_indonesia/features/navbar/providers/navbar_provider.dart';
import 'package:budaya_indonesia/features/profile/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Bottom navigation bar with 5 main pages.
class BottomNavbar extends StatefulWidget {
  final int? currentIndex;
  final ValueChanged<int>? onTap;

  const BottomNavbar({super.key, this.currentIndex, this.onTap});

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  late int _selectedIndex;

  final List<IconData> _tabIcons = [
    Icons.home,
    Icons.audiotrack,
    Icons.camera_alt,
    Icons.photo_album,
    Icons.person,
  ];

  final List<Widget> _pages = [
    const HomePage(),
    const MusicPage(),
    const SizedBox.shrink(), // placeholder for AR button
    const PakaianDaerahPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex ?? 0;
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      // Navigate to AR page on tap
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ArPage()),
      );
      return;
    }

    setState(() => _selectedIndex = index);
    if (widget.onTap != null) {
      widget.onTap!(index);
    } else {
      context.read<NavbarProvider?>()?.setIndex(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<NavbarProvider?>();
    final displayIndex = prov?.index ?? _selectedIndex;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    const navHeight = 84.0;
    final reservedBottom = navHeight + 20 + 12 + bottomInset;

    return Scaffold(
      extendBody: true,
      body: Padding(
        padding: EdgeInsets.only(bottom: reservedBottom),
        child: IndexedStack(
          index: displayIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: SizedBox(
            height: navHeight,
            child: Material(
              elevation: 8,
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: Row(
                  children: List.generate(_tabIcons.length, (i) {
                    final isActive = i == displayIndex;
                    final colorScheme = Theme.of(context).colorScheme;

                    return Expanded(
                      child: InkWell(
                        onTap: () => _onItemTapped(i),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _tabIcons[i],
                                size: isActive ? 30 : 24,
                                color: isActive
                                    ? colorScheme.onPrimary
                                    : colorScheme.onPrimary.withOpacity(0.85),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _labelForIndex(i),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isActive
                                      ? colorScheme.onPrimary
                                      : colorScheme.onPrimary.withOpacity(0.85),
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
