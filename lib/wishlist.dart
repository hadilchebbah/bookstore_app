import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'book_details.dart';
class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<Map<String, dynamic>> wishlistBooks = [];
  bool isLoading = true;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    try {
      setState(() {
        isLoading = true;
      });

      final user = supabase.auth.currentUser;
      if (user == null) return;
      final response = await supabase
          .from('wishlists')
          .select('''
            id,
            book_id,
            created_at,
            books (
              id,
              title,
              price,
              cover_image_url,
              description,
              rating,
              authors (name),
              vendors (name)
            )
          ''')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      setState(() {
        wishlistBooks = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading wishlist: $e')),
        );
      }
    }
  }

  Future<void> _removeFromWishlist(String bookId, String wishlistId) async {
    try {
      await supabase
          .from('wishlists')
          .delete()
          .eq('id', wishlistId);

      setState(() {
        wishlistBooks.removeWhere((item) => item['id'] == wishlistId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from wishlist'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing from wishlist: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'My Wishlist',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          if (wishlistBooks.isNotEmpty)
            TextButton(
              onPressed: _clearAllWishlist,
              child: Text(
                'Clear All',
                style: TextStyle(
                  color: Colors.red[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadWishlist,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : wishlistBooks.isEmpty
                ? _buildEmptyWishlist()
                : _buildWishlistContent(),
      ),
    );
  }

  Widget _buildEmptyWishlist() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Your wishlist is empty',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding books you love!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate back to home or books page
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B46C1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Browse Books',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistContent() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: wishlistBooks.length,
      itemBuilder: (context, index) {
        final wishlistItem = wishlistBooks[index];
        final book = wishlistItem['books'];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () {
              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookDetailsPage(book: book),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  
                  Container(
                    width: 80,
                    height: 110,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: book['cover_image_url'] != null && 
                             book['cover_image_url'].toString().trim().isNotEmpty
                          ? Image.network(
                              book['cover_image_url'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholderCover(book['title']);
                              },
                            )
                          : _buildPlaceholderCover(book['title']),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book['title'] ?? 'Unknown Title',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (book['authors'] != null)
                          Text(
                            'by ${book['authors']['name']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        const SizedBox(height: 8),
                       
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              book['rating']?.toString() ?? '4.0',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${book['price']}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6B46C1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          _removeFromWishlist(book['id'], wishlistItem['id']);
                        },
                        icon: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                      
                          _addToCart(book);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B46C1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(0, 32),
                        ),
                        child: const Text(
                          'Add to Cart',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderCover(String? title) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade300,
            Colors.purple.shade300,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.book,
              size: 24,
              color: Colors.white,
            ),
            const SizedBox(height: 4),
            Text(
              title?.split(' ').take(2).join(' ') ?? 'Book',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _clearAllWishlist() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Wishlist'),
        content: const Text('Are you sure you want to remove all items from your wishlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Clear All',
              style: TextStyle(color: Colors.red[600]),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final user = supabase.auth.currentUser;
        if (user != null) {
          await supabase
              .from('wishlists')
              .delete()
              .eq('user_id', user.id);
          
          setState(() {
            wishlistBooks.clear();
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Wishlist cleared'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error clearing wishlist: $e')),
          );
        }
      }
    }
  }

  Future<void> _addToCart(Map<String, dynamic> book) async {
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${book['title']} added to cart!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}


class WishlistService {
  static final supabase = Supabase.instance.client;

  static Future<bool> isBookInWishlist(String bookId) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return false;

      final response = await supabase
          .from('wishlists')
          .select('id')
          .eq('user_id', user.id)
          .eq('book_id', bookId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> toggleWishlist(String bookId) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final isInWishlist = await isBookInWishlist(bookId);

      if (isInWishlist) {
        
        await supabase
            .from('wishlists')
            .delete()
            .eq('user_id', user.id)
            .eq('book_id', bookId);
        return false;
      } else {
        
        await supabase
            .from('wishlists')
            .insert({
          'user_id': user.id,
          'book_id': bookId,
        });
        return true;
      }
    } catch (e) {
      throw Exception('Error toggling wishlist: $e');
    }
  }

  static Future<int> getWishlistCount() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return 0;

      final response = await supabase
          .from('wishlists')
          .select('id')
          .eq('user_id', user.id);

      return response.length;
    } catch (e) {
      return 0;
    }
  }
}