import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../dashboard.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isSignIn = true;
  bool isLoading = false;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _nameController;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _googleSignIn.disconnect();
    super.dispose();
  }

  // --- CORRECTED LOGIN LOGIC ---
  Future<bool> login() async {
    try {
      final GoogleSignInAccount? user = await _googleSignIn.signIn();

      if (user == null) {
        debugPrint("Google Sign-In cancelled by user");
        return false;
      }

      final GoogleSignInAuthentication userAuth = await user.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: userAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      return FirebaseAuth.instance.currentUser != null;
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
      return false;
    }
  }

  void _navigateToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // --- TOGGLE BUTTONS ---
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isSignIn = false),
                        child: _buildTab("Sign Up", !isSignIn),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isSignIn = true),
                        child: _buildTab("Sign In", isSignIn),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- FORM FIELDS ---
              if (!isSignIn) ...[
                const Text(
                  "Full Name",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: "Enter your full name",
                  ),
                ),
                const SizedBox(height: 20),
              ],
              const Text(
                "Email",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(hintText: "name@example.com"),
              ),
              const SizedBox(height: 20),
              const Text(
                "Password",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: "Enter your password",
                ),
              ),

              const SizedBox(height: 30),

              // --- MAIN ACTION BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // Add your email/password authentication logic here
                    _navigateToDashboard();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B65EC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isSignIn ? "Sign In" : "Create Account",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // --- GOOGLE BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() => isLoading = true);
                          bool isLogged = await login();
                          setState(() => isLoading = false);

                          if (isLogged && mounted) {
                            _navigateToDashboard();
                          } else if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Google sign-in failed."),
                              ),
                            );
                          }
                        },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          "Continue with Google",
                          style: TextStyle(color: Colors.black87, fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? Border.all(color: Colors.grey[300]!) : null,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.black : Colors.grey,
        ),
      ),
    );
  }
}
