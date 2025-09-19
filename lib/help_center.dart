import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  final supabase = Supabase.instance.client;
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool isLoading = false;
  int selectedTab = 0; 

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // FAQ Data
  final List<Map<String, String>> faqItems = [
    {
      'question': 'How do I place an order?',
      'answer': 'To place an order, browse our collection, select the books you want, add them to your cart, and proceed to checkout. You\'ll need to create an account or sign in to complete your purchase.',
    },
    {
      'question': 'What payment methods do you accept?',
      'answer': 'We accept all major credit cards (Visa, MasterCard, American Express), PayPal, and bank transfers. All payments are processed securely.',
    },
    {
      'question': 'How long does shipping take?',
      'answer': 'Standard shipping typically takes 3-5 business days. Express shipping (1-2 business days) is also available for an additional fee. You\'ll receive a tracking number once your order ships.',
    },
    {
      'question': 'Can I return a book?',
      'answer': 'Yes, we offer a 30-day return policy for books in original condition. Contact our support team to initiate a return. Digital books cannot be returned once downloaded.',
    },
    {
      'question': 'How do I track my order?',
      'answer': 'Once your order ships, you\'ll receive an email with tracking information. You can also check your order status in the "Order History" section of your profile.',
    },
    {
      'question': 'Do you offer digital books?',
      'answer': 'Yes, we have a wide selection of digital books available for immediate download. Digital books appear in your library once purchased.',
    },
    {
      'question': 'How do I add books to my wishlist?',
      'answer': 'Click the heart icon on any book to add it to your wishlist. You can view all your saved books in the "Wishlist" section.',
    },
    {
      'question': 'Is my personal information secure?',
      'answer': 'Yes, we use industry-standard encryption to protect your personal and payment information. We never share your data with third parties without your consent.',
    },
  ];

  Future<void> _submitSupportRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final user = supabase.auth.currentUser;
  
      await Future.delayed(const Duration(seconds: 2));

      _messageController.clear();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your support request has been submitted! We\'ll get back to you within 24 hours.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Help Center',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: selectedTab == 0 ? _buildFAQTab() : _buildContactTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedTab = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selectedTab == 0 ? const Color(0xFF6B46C1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'FAQ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selectedTab == 0 ? Colors.white : Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedTab = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selectedTab == 1 ? const Color(0xFF6B46C1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Contact Support',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selectedTab == 1 ? Colors.white : Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: faqItems.length,
      itemBuilder: (context, index) {
        return _buildFAQItem(faqItems[index]);
      },
    );
  }

  Widget _buildFAQItem(Map<String, String> faqItem) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          faqItem['question']!,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              faqItem['answer']!,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContactInfo(),
          const SizedBox(height: 24),
          _buildContactForm(),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Get in Touch',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We\'re here to help! Reach out to us through any of the following methods:',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 20),
        _buildContactMethod(
          Icons.email_outlined,
          'Email',
          'support@bookstore.com',
          'We typically respond within 24 hours',
        ),
        const SizedBox(height: 16),
        _buildContactMethod(
          Icons.phone_outlined,
          'Phone',
          '+1 (555) 123-4567',
          'Mon-Fri, 9:00 AM - 6:00 PM EST',
        ),
        const SizedBox(height: 16),
        _buildContactMethod(
          Icons.chat_outlined,
          'Live Chat',
          'Available on our website',
          'Mon-Fri, 9:00 AM - 6:00 PM EST',
        ),
      ],
    );
  }

  Widget _buildContactMethod(IconData icon, String title, String contact, String hours) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6B46C1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF6B46C1),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  contact,
                  style: const TextStyle(
                    color: Color(0xFF6B46C1),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hours,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Send us a Message',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Fill out the form below and we\'ll get back to you as soon as possible.',
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 20),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _messageController,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: 'How can we help you?',
                  hintText: 'Describe your issue or question...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF6B46C1), width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your message';
                  }
                  if (value.trim().length < 10) {
                    return 'Please provide more details (at least 10 characters)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submitSupportRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B46C1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Send Message',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}