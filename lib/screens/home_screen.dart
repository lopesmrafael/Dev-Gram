import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_theme.dart';
import '../widgets/add_photo_dialog.dart';
import 'feed_screen.dart';
import 'gallery_screen.dart';
import 'liked_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static const _titles = ['DevGram', 'Minhas Fotos', 'Curtidas'];
  static const _screens = [FeedScreen(), GalleryScreen(), LikedScreen()];

  void _showAddPhotoDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const AddPhotoDialog(),
    );
  }

  Widget _navIcon(IconData icon, int index) {
    final selected = _currentIndex == index;
    return AnimatedScale(
      scale: selected ? 1.18 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Icon(icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(_titles[_currentIndex], style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: AppTheme.accentGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accent.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _showAddPhotoDialog(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: AppTheme.navBarColor,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.accentAlt,
        unselectedItemColor: AppTheme.textSecondary.withOpacity(0.6),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: _navIcon(Icons.home_outlined, 0),
            activeIcon: _navIcon(Icons.home, 0),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: _navIcon(Icons.grid_view_outlined, 1),
            activeIcon: _navIcon(Icons.grid_view, 1),
            label: 'Minhas Fotos',
          ),
          BottomNavigationBarItem(
            icon: _navIcon(Icons.favorite_border, 2),
            activeIcon: _navIcon(Icons.favorite, 2),
            label: 'Curtidas',
          ),
        ],
      ),
    );
  }
}
