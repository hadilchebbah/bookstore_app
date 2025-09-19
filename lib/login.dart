import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'sign_in.dart';
import 'home.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false; 
Future<void> _register() async {
  final name = nameController.text.trim();
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();

  if (name.isEmpty || email.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill all fields')),
    );
    return;
  }

  if (!email.contains('@') || !email.contains('.')) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter a valid email')),
    );
    return;
  }

  if (password.length < 8) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password must be at least 8 characters')),
    );
    return;
  }

  setState(() {
    _isLoading = true;
  });
try {
  final res = await Supabase.instance.client.auth.signUp(
    email: email,
    password: password,
    data: {'name': name},
  );

  if (!mounted) return;

  if (res.user != null) {
    // User created, but session may be null if email confirmation is on
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account created! Please check your email to confirm.'),
      ),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignIn()),
    );
  }
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Sign up failed: $e')),
  );
}


  setState(() {
    _isLoading = false;
  });
}



  @override
  void dispose() {
   
    nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0, 
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Sign Up',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create account and choose favorite menu',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 32),
            
            
            const Text(
              'Name',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              textCapitalization: TextCapitalization.words, // ✅ Added: Auto capitalize names
              decoration: InputDecoration(
                hintText: 'Your Name',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16), 
            
           
            const Text(
              'Email',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress, 
              decoration: InputDecoration(
                hintText: 'Your email',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),
            
            
            const Text(
              'Password',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                hintText: 'Your password (min 6 characters)',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 24), 

            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B46C1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white) // ✅ Added: Loading indicator
                    : const Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),         
            const SizedBox(height: 16),    
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Have an account? ",
                  style: TextStyle(
                    color: Color.fromARGB(255, 120, 119, 119),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignIn()),
                    );
                  },
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      color: Color(0xFF6B46C1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            
            
            Center(
              child: Text.rich(
                TextSpan(
                  text: 'By clicking Register, you agree to our\n',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 120, 119, 119),
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Terms, Data Policy.',
                      style: const TextStyle(
                        color: Color(0xFF6B46C1),
                        decoration: TextDecoration.underline, // ✅ Added: Underline for links
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 20), 
          ],
        ),
      ),
    );
  }
}


