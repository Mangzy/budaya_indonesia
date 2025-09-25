import 'package:budaya_indonesia/features/home/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navbar_provider.dart';

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
    Icons.quiz,
    Icons.person,
  ];

  final List<Widget> _pages = [
    // Home
    HomeScreen(),
    // AR (placeholder)
    Scaffold(
      appBar: AppBar(title: const Text('Audio')),
      body: const Center(child: Text('Audio page')),
    ),
    // Quiz
    Scaffold(
      appBar: AppBar(title: const Text('AR')),
      body: const Center(child: Text('AR page (placeholder)')),
    ),
    Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: const Center(child: Text('Quiz page')),
    ),
    // Profile
    Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(child: Text('Profile page')),
    ),
  ];
  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    // if parent provided onTap use it, otherwise use provider
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

    return Scaffold(
      body: IndexedStack(index: displayIndex, children: _pages),
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Material(
            elevation: 8,
            // use app theme primary so navbar follows ThemeData in main.dart
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
                                      ).colorScheme.onPrimary.withOpacity(0.85),
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
        return 'Quiz';
      case 4:
        return 'Profile';
      default:
        return '';
    }
  }
}
