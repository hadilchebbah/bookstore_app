import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'book_details.dart';
import 'vendors.dart';
import 'authors.dart';
import 'catecory.dart';
import 'bottom_nav_bar.dart'; 
import 'wishlist.dart';
import 'profile.dart';
import 'books_page.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;

  List<dynamic> topWeekBooks = [];
  List<dynamic> vendors = [];
  List<dynamic> authors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final booksRes = await supabase
          .from('books')
          .select()
          .eq('is_featured', true)
          .limit(5);

      final vendorsRes = await supabase.from('vendors').select().limit(5);
      final authorsRes = await supabase.from('authors').select().limit(5);

      setState(() {
        topWeekBooks = booksRes;
        vendors = vendorsRes;
        authors = authorsRes;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      setState(() => isLoading = false);
    }
  }

  void _onItemTapped(int index, BuildContext context) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CategoryPage()),
      );
    } else if (index == 2) {  
       Navigator.push(
        context, MaterialPageRoute(builder: (context) => WishlistPage())
        );
    } else if (index == 3) {
      
       Navigator.push(
        context, MaterialPageRoute(builder: (context) => ProfilePage())
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 0,
        onTap: (index) => _onItemTapped(index, context),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildSpecialOffer(),
                    _buildSectionTitle(
                          "Top of Week",
                     onSeeAll: () {
                       Navigator.push(
                        context,
                      MaterialPageRoute(builder: (_) => const BooksPage()),
                      );
                      },
                      ),
                    _buildBookList(),
                    _buildSectionTitle(
                      "Best Vendors",
                      onSeeAll: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const VendorsPage()),
                        );
                      },
                    ),
                    _buildVendorList(),
                    _buildSectionTitle(
                      "Authors",
                      onSeeAll: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AuthorsPage()),
                        );
                      },
                    ),
                    _buildAuthorList(),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Bookstore",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              IconButton(
                  onPressed: () {}, icon: const Icon(Icons.search, color: Colors.black)),
              IconButton(
                  onPressed: () {}, icon: const Icon(Icons.notifications_none, color: Colors.black)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialOffer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6B46C1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Special Offer",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Discount 25% on all bestsellers",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF6B46C1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {},
                  child: const Text("Order Now"),
                )
              ],
            ),
          ),
          const SizedBox(width: 16),
          Image.network(
            'https://images-na.ssl-images-amazon.com/images/I/81A-mvlo+QL.jpg',
            height: 100,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: onSeeAll,
            child: const Text(
              "See all",
              style: TextStyle(color: Color(0xFF6B46C1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookList() {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: topWeekBooks.length,
        itemBuilder: (context, index) {
          final book = topWeekBooks[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => BookDetailsPage(book: book)));
            },
            child: Container(
              width: 140,
              margin: const EdgeInsets.only(left: 16),
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
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      book['cover_image_url'] ?? 'https://via.placeholder.com/150x200?text=Book',
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(book['title'],
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVendorList() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: vendors.length,
        itemBuilder: (context, index) {
          final vendor = vendors[index];
          return Container(
            width: 90,
            margin: const EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))
              ],
            ),
            child: Center(
              child: Image.network(
                vendor['logo_url'] ?? 'https://via.placeholder.com/80x80?text=Vendor',
                height: 50,
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAuthorList() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: authors.length,
        itemBuilder: (context, index) {
          final author = authors[index];
          return Container(
            width: 90,
            margin: const EdgeInsets.only(left: 16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                      author['photo_url'] ?? 'https://via.placeholder.com/100x100?text=Author'),
                ),
                const SizedBox(height: 6),
                Text(author['name'],
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          );
        },
      ),
    );
  }
}