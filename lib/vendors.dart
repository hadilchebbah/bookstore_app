import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VendorsPage extends StatefulWidget {
  const VendorsPage({super.key});

  @override
  State<VendorsPage> createState() => _VendorsPageState();
}

class _VendorsPageState extends State<VendorsPage>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;

  List<dynamic> vendors = [];
  bool isLoading = true;

  late TabController _tabController;
  final List<String> categories = [
    'All',
    'Books',
    'Poems',
    'Special for you',
    'Stationery'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
    _loadVendors();
  }

  Future<void> _loadVendors() async {
    try {
      final res = await supabase.from('vendors').select();
      setState(() {
        vendors = res;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading vendors: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Vendords",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Our Vendors",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: const Color(0xFF6B46C1),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: const Color(0xFF6B46C1),
                    tabs: categories
                        .map((c) => Tab(text: c))
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  Expanded(child: _buildVendorsGrid()),
                ],
              ),
      ),
    );
  }

  Widget _buildVendorsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: vendors.length,
      itemBuilder: (context, index) {
        final vendor = vendors[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  vendor['logo_url'] ?? 'https://via.placeholder.com/80x80?text=Vendor',
                  height: 50,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stack) =>
                      const Icon(Icons.store, size: 40),
                ),
                const SizedBox(height: 6),
                Text(
                  vendor['name'] ?? 'Vendor',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (star) => Icon(
                      star < (vendor['rating'] ?? 0).round()
                          ? Icons.star
                          : Icons.star_border,
                      size: 14,
                      color: Colors.amber,
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
