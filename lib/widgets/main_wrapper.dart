import 'package:flutter/material.dart';
import 'package:flutter_mastery/screen/cart_screen.dart';
import '../screen/home_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  _MainWrapperState createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 2; // Default Selected: Home (Pets Icon)

  final List<Widget> _screens = [
    const Center(child: Text("Search Screen")),
    const Center(child: Text("Favorites Screen")),
    HomeScreen(),
    const CartScreen(),
    const Center(child: Text("Profile Screen")),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFFFF8C42); // Pet Orange
    final Color secondaryColor = const Color(0xFF2A52BE); // Trust Blue

    return Scaffold(
      body: _screens[_selectedIndex],

      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () => _onItemTapped(2),
        backgroundColor: _selectedIndex == 2
            ? primaryColor
            : const Color(0xFF2D3436),
        elevation: 4,
        child: const Icon(
          Icons.storefront_outlined,
          color: Colors.white,
          size: 28,
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.symmetric(vertical: 0),
        height: 55,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        clipBehavior: Clip.antiAlias,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(
                Icons.grid_view_rounded,
                size: 24,
                color: _selectedIndex == 0 ? secondaryColor : Colors.grey[400],
              ),
              onPressed: () => _onItemTapped(0),
            ),

            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(
                Icons.favorite_rounded,
                size: 24,
                color: _selectedIndex == 1 ? secondaryColor : Colors.grey[400],
              ),
              onPressed: () => _onItemTapped(1),
            ),
            const SizedBox(width: 45),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(
                Icons.shopping_basket_rounded, // Cart icon update
                size: 24,
                color: _selectedIndex == 3 ? secondaryColor : Colors.grey[400],
              ),
              onPressed: () => _onItemTapped(3),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(
                Icons.person_rounded,
                size: 24,
                color: _selectedIndex == 4 ? secondaryColor : Colors.grey[400],
              ),
              onPressed: () => _onItemTapped(4),
            ),
          ],
        ),
      ),
    );
  }
}
