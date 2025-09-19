import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'book_details.dart';

class CategorySearchPage extends StatefulWidget {
  const CategorySearchPage({super.key});

  @override
  State<CategorySearchPage> createState() => _CategorySearchPageState();
}

class _CategorySearchPageState extends State<CategorySearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _recentSearches = ['The Good Sister', 'Carrie Fisher'];
  List<dynamic> _searchResults = [];
  bool _isSearching = false;

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
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            _performSearch(value);
          },
        ),
      ),
      body: _isSearching
          ? _buildSearchResults()
          : _buildRecentSearches(),
    );
  }

  Widget _buildRecentSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Recent Searches',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _recentSearches.length,
            itemBuilder: (context, index) {
              final search = _recentSearches[index];
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(search),
                onTap: () {
                  _searchController.text = search;
                  _performSearch(search);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    return _searchResults.isEmpty
        ? const Center(
            child: Text(
              'No results found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
        : ListView.builder(
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final book = _searchResults[index];
              return ListTile(
                leading: Image.network(
                  book['cover_image_url'] ?? 'https://via.placeholder.com/50x70?text=Book',
                  width: 40,
                  height: 60,
                  fit: BoxFit.cover,
                ),
                title: Text(book['title']),
                subtitle: Text(book['author_id'] ?? 'Unknown Author'),
                trailing: Text('\$${book['price']?.toStringAsFixed(2) ?? '0.00'}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => BookDetailsPage(book: book)),
                  );
                },
              );
            },
          );
  }

  void _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults.clear();
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final results = await supabase
          .from('books')
          .select()
          .ilike('title', '%$query%');

      setState(() {
        _searchResults = results;
      
        if (!_recentSearches.contains(query)) {
          _recentSearches.insert(0, query);
          
          if (_recentSearches.length > 5) {
            _recentSearches.removeLast();
          }
        }
      });
    } catch (e) {
      debugPrint('Error searching: $e');
      setState(() {
        _searchResults = [];
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}