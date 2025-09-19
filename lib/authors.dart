import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthorsPage extends StatefulWidget {
  const AuthorsPage({super.key});

  @override
  State<AuthorsPage> createState() => _AuthorsPageState();
}

class _AuthorsPageState extends State<AuthorsPage>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;

  List<dynamic> authors = [];
  bool isLoading = true;

  late TabController _tabController;
  final List<String> categories = [
    'All',
    'Poets',
    'Playwrights',
    'Novelists',
    'Journalists'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
    _loadAuthors();
  }

  Future<void> _loadAuthors() async {
    try {
      final res = await supabase.from('authors').select();
      setState(() {
        authors = res;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading authors: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Authors",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          )
        ],
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
                      "Check the authors",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Authors",
                      style: TextStyle(
                        color: Color(0xFF6B46C1),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: const Color(0xFF6B46C1),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: const Color(0xFF6B46C1),
                    tabs:
                        categories.map((c) => Tab(text: c)).toList(),
                  ),
                  const SizedBox(height: 12),
                  Expanded(child: _buildAuthorsList()),
                ],
              ),
      ),
    );
  }

  Widget _buildAuthorsList() {
    return ListView.builder(
      itemCount: authors.length,
      itemBuilder: (context, index) {
        final author = authors[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(
                  author['photo_url'] ??
                      'https://via.placeholder.com/100x100?text=Author',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author['name'] ?? 'Author',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      author['bio'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
