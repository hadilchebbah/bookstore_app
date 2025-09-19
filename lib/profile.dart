import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'bottom_nav_bar.dart';
import 'account.dart';
import 'wishlist.dart';
import 'help_center.dart';
import 'catecory.dart';
import 'wishlist.dart';
import 'home.dart';
import 'login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;
  User? currentUser;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() {
    setState(() {
      currentUser = supabase.auth.currentUser;
      isLoading = false;
    });
  }

  void _onItemTapped(int index, BuildContext context) {
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else if (index == 1) {
       Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CategoryPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WishlistPage()),
      );
    }
    
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _performLogout();
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout() async {
    try {
      await supabase.auth.signOut();
      if (mounted) {

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login', 
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 3,
        onTap: (index) => _onItemTapped(index, context),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildProfileInfo(),
                    const SizedBox(height: 24),
                    _buildMenuItems(),
                    const SizedBox(height: 32),
                    _buildLogoutButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.black),
          ),
          const Expanded(
            child: Text(
              "Profile",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 48), 
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFF6B46C1),
            child: Text(
              currentUser?.userMetadata?['name']?.toString().substring(0, 1).toUpperCase() ?? 
              currentUser?.email?.substring(0, 1).toUpperCase() ?? 'U',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            currentUser?.userMetadata?['name']?.toString() ?? 'User',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            currentUser?.email ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF6B46C1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems() {
    final menuItems = [
      {
        'icon': Icons.person_outline,
        'title': 'My Account',
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MyAccountPage()),
        ),
      },
      {
        'icon': Icons.location_on_outlined,
        'title': 'Address',
        
      },
      {
        'icon': Icons.local_offer_outlined,
        'title': 'Offers & Promos',
      

        
      },
      {
        'icon': Icons.favorite_outline,
        'title': 'Your Favorites',
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WishlistPage()),
        ),
      },
      {
        'icon': Icons.history,
        'title': 'Order History',
        
      },
      {
        'icon': Icons.help_outline,
        'title': 'Help Center',
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HelpCenterPage()),
        ),
      },
    ];

    return Column(
      children: menuItems.map((item) => _buildMenuItem(
        icon: item['icon'] as IconData,
        title: item['title'] as String,
       onTap: item['onTap'] as VoidCallback? ?? () {},
      )).toList(),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: const Color(0xFF6B46C1),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _handleLogout,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, size: 20),
              SizedBox(width: 8),
              Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}