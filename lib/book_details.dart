import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookDetailsPage extends StatefulWidget {
  final Map<String, dynamic> book;

  const BookDetailsPage({super.key, required this.book});

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  bool isWishlisted = false;
  int quantity = 1;
  bool isLoadingWishlist = false;
  Map<String, dynamic>? fullBookData;
  bool isLoadingBookData = true;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadFullBookData();
    _checkWishlistStatus();
  }

  Future<void> _loadFullBookData() async {
    try {
      final response = await supabase
          .from('books')
          .select('''
            *,
            authors(id, name, bio, photo_url),
            categories(id, name),
            vendors(id, name, logo_url, rating)
          ''')
          .eq('id', widget.book['id'])
          .single();
      
      setState(() {
        fullBookData = response;
        isLoadingBookData = false;
      });
    } catch (e) {
      debugPrint('Error loading full book data: $e');
      setState(() {
        fullBookData = widget.book;
        isLoadingBookData = false;
      });
    }
  }

  Future<void> _checkWishlistStatus() async {
    try {
      final isInWishlist = await WishlistService.isBookInWishlist(widget.book['id']);
      setState(() {
        isWishlisted = isInWishlist;
      });
    } catch (e) {
      
    }
  }

  Future<void> _toggleWishlist() async {
    if (isLoadingWishlist) return;

    setState(() {
      isLoadingWishlist = true;
    });

    try {
      final newStatus = await WishlistService.toggleWishlist(widget.book['id']);
      setState(() {
        isWishlisted = newStatus;
        isLoadingWishlist = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus 
                  ? 'Added to wishlist' 
                  : 'Removed from wishlist'
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoadingWishlist = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookData = fullBookData ?? widget.book;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: isLoadingBookData 
          ? _buildLoadingState() 
          : _buildContent(bookData),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black),
            onPressed: () {
              // TODO: Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share feature coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B46C1)),
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> bookData) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroSection(bookData),
          _buildBookInfo(bookData),
          _buildActionButtons(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeroSection(Map<String, dynamic> bookData) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          
          Center(
            child: Hero(
              tag: 'book-${bookData['id']}',
              child: Container(
                height: 320,
                width: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6B46C1).withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      bookData['cover_image_url'] != null && 
                             bookData['cover_image_url'].toString().trim().isNotEmpty
                          ? Image.network(
                              bookData['cover_image_url'],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholderCover(bookData);
                              },
                            )
                          : _buildPlaceholderCover(bookData),
                      
                      
                      Positioned(
                        top: 12,
                        left: 12,
                        child: _buildVendorBadge(bookData),
                      ),
                      
                     
                      if (bookData['is_featured'] == true)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Text(
                              'Featured',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bookData['title'] ?? 'Unknown Title',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (bookData['authors'] != null)
                      Text(
                        'by ${bookData['authors']['name']}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildWishlistButton(),
            ],
          ),
          
          const SizedBox(height: 16),
          
          
          _buildRatingRow(bookData),
        ],
      ),
    );
  }

  Widget _buildVendorBadge(Map<String, dynamic> bookData) {
    final vendorName = bookData['vendors']?['name'] ?? 'GooDay';
    final vendorRating = bookData['vendors']?['rating']?.toString() ?? '4.1';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF6B46C1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.store,
              size: 12,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                vendorName,
                style: const TextStyle(
                  color: Color(0xFF6B46C1),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    size: 10,
                    color: Colors.amber[600],
                  ),
                  const SizedBox(width: 2),
                  Text(
                    vendorRating,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistButton() {
    return GestureDetector(
      onTap: _toggleWishlist,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: isLoadingWishlist
            ? const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                ),
              )
            : Icon(
                isWishlisted ? Icons.favorite : Icons.favorite_border,
                color: isWishlisted ? Colors.red : Colors.grey[400],
                size: 28,
              ),
      ),
    );
  }

  Widget _buildRatingRow(Map<String, dynamic> bookData) {
    final rating = double.tryParse(bookData['rating']?.toString() ?? '4.0') ?? 4.0;
    
    return Row(
      children: [
        ...List.generate(5, (index) {
          return Icon(
            index < rating.floor() ? Icons.star : Icons.star_border,
            color: Colors.amber[600],
            size: 20,
          );
        }),
        const SizedBox(width: 8),
        Text(
          '($rating)',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          '\$${bookData['price'] ?? '0.00'}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6B46C1),
          ),
        ),
      ],
    );
  }

  Widget _buildBookInfo(Map<String, dynamic> bookData) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About this book',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            bookData['description'] ?? 
            'A captivating story that will keep you engaged from beginning to end. This book offers unique insights and perspectives that will leave a lasting impression on readers.',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 16,
              height: 1.6,
            ),
          ),
          
          const SizedBox(height: 20),
          
          
          _buildBookDetails(bookData),
          
          const SizedBox(height: 20),
          
          
          _buildQuantitySelector(),
        ],
      ),
    );
  }

  Widget _buildBookDetails(Map<String, dynamic> bookData) {
    return Column(
      children: [
        _buildDetailRow('Category', bookData['categories']?['name'] ?? 'General'),
        _buildDetailRow('Author', bookData['authors']?['name'] ?? 'Unknown Author'),
        _buildDetailRow('Vendor', bookData['vendors']?['name'] ?? 'GooDay'),
        _buildDetailRow('Rating', '${bookData['rating'] ?? '4.0'} ⭐'),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        const Text(
          'Quantity',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: quantity > 1 ? () {
                  setState(() {
                    quantity--;
                  });
                } : null,
                icon: const Icon(Icons.remove, size: 20),
                color: quantity > 1 ? Colors.grey[700] : Colors.grey[400],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  quantity.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    quantity++;
                  });
                },
                icon: const Icon(Icons.add, size: 20),
                color: Colors.white,
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF6B46C1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added ${quantity} book(s) to cart!'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B46C1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Add to Cart',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6B46C1),
                    side: const BorderSide(color: Color(0xFF6B46C1)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Continue Shopping',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('View cart feature coming soon!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF6B46C1),
                    side: const BorderSide(color: Color(0xFF6B46C1)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'View Cart',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderCover(Map<String, dynamic> bookData) {
    final colors = [
      const Color(0xFF6B46C1),
      const Color(0xFF059669),
      const Color(0xFFDC2626),
      const Color(0xFF7C3AED),
      const Color(0xFF0891B2),
    ];
    final title = bookData['title'] ?? 'Book';
    final color = colors[title.length % colors.length];

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.8),
            color,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book,
              size: 48,
              color: Colors.white.withOpacity(0.9),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
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