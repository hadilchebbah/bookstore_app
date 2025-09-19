import 'package:final_pr_masterclass/home.dart';
import 'package:final_pr_masterclass/wishlist.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'book_details.dart';
import 'bottom_nav_bar.dart'; 
import 'search_cat.dart';
import 'profile.dart';
import 'home.dart';
class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final supabase = Supabase.instance.client;
  
  List<dynamic> categories = [];
  List<dynamic> books = [];
  String selectedCategory = 'All';
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  void _onItemTapped(int index, BuildContext context) {
    if (index == 0) {
     
      Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
    } else if (index == 2) {
     
       Navigator.push(context, MaterialPageRoute(builder: (context) => WishlistPage()));
    } else if (index == 3) {
      
     Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
    }
   
  }
  
  Future<void> _loadData() async {
    try {
      final categoriesRes = await supabase.from('categories').select();
      final booksRes = await supabase.from('books').select('''
        *, 
        categories(name)
      ''');
      
      setState(() {
        categories = categoriesRes;
        books = booksRes;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      
      setState(() {
        categories = [
          {'name': 'All'},
          {'name': 'Novels'},
          {'name': 'Self Love'},
          {'name': 'Science'},
          {'name': 'Romanti'},
        ];
        books = [];
        isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 1, 
        onTap: (index) => _onItemTapped(index, context),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildCategoryList(),
                  Expanded(
                    child: _buildBookGrid(),
                  ),
                ],
              ),
      ),
    );
  }
  
  // Le reste de votre CategoryPage reste inchangé...
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Category",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CategorySearchPage()),
              );
            }, 
            icon: const Icon(Icons.search, color: Colors.black)
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoryList() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category['name'];
          
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category['name'];
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: EdgeInsets.only(
                left: index == 0 ? 16 : 8,
                right: index == categories.length - 1 ? 16 : 0,
              ),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6B46C1) : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  category['name'],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildBookGrid() {
    
    List<dynamic> filteredBooks = books;
    if (selectedCategory != 'All') {
      filteredBooks = books.where((book) => 
        book['categories'] != null && 
        book['categories']['name'] == selectedCategory).toList();
    }
    
    return filteredBooks.isEmpty
        ? const Center(
            child: Text(
              'No books found in this category',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
        : GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            itemCount: filteredBooks.length,
            itemBuilder: (context, index) {
              final book = filteredBooks[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => BookDetailsPage(book: book)),
                  );
                },
                child: Container(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.network(
                          book['cover_image_url'] ?? 'https://via.placeholder.com/150x200?text=Book',
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book['title'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              book['author_id'] ?? 'Unknown Author',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${book['price']?.toStringAsFixed(2) ?? '0.00'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6B46C1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}

