import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../dashboard.dart';
import '../admin/admin_dashboard.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isSignIn = true;
  bool isLoading = false;
  bool rememberMe = false;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _nameController;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showMessage("Please enter your email first.");
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showMessage("Password reset link sent to your email.");
    } catch (e) {
      _showMessage("Failed to send reset email.");
    }
  }

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

  // --- GOOGLE LOGIN LOGIC ---
  Future<bool> login() async {
    try {
      final UserCredential userCredential;

      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        userCredential = await FirebaseAuth.instance.signInWithPopup(
          googleProvider,
        );
      } else {
        final GoogleSignInAccount? user = await _googleSignIn.signIn();

        if (user == null) {
          debugPrint("Google Sign-In cancelled by user");
          return false;
        }

        final GoogleSignInAuthentication userAuth = await user.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: userAuth.idToken,
          accessToken: userAuth.accessToken,
        );

        userCredential = await FirebaseAuth.instance.signInWithCredential(
          credential,
        );
      }

      if (userCredential.user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!userDoc.exists) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
                'name': userCredential.user!.displayName ?? 'No Name',
                'email': userCredential.user!.email,
                'role': 'user',
                'createdAt': FieldValue.serverTimestamp(),
              });
        }
      }

      return FirebaseAuth.instance.currentUser != null;
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
      return false;
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  // --- ROLE BASED ROUTING ---
  Future<void> _checkRoleAndNavigate(String uid) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!mounted) return;

      if (userDoc.exists) {
        final data = userDoc.data();
        final String role = data?['role'] ?? 'user';

        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminDashboard()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MainDashboardScreen(),
            ),
          );
        }
      } else {
        await FirebaseAuth.instance.signOut();
        _showMessage("User data not found in database.");
      }
    } catch (e) {
      _showMessage("Error checking user role.");
    }
  }

  // --- EMAIL/PASSWORD SIGN UP ---
  Future<void> _signUpWithEmailPassword() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showMessage("Please enter name, email and password.");
      return;
    }

    try {
      final UserCredential credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = credential.user;
      if (user == null) {
        _showMessage("Unable to create user. Please try again.");
        return;
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': name,
        'email': email,
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        _checkRoleAndNavigate(user.uid);
      }
    } on FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        'email-already-in-use' => 'This email is already in use.',
        'invalid-email' => 'The email address is not valid.',
        'weak-password' => 'The password is too weak.',
        _ => 'Signup failed: ${e.message ?? e.code}',
      };
      _showMessage(message);
    } catch (e) {
      _showMessage('Signup failed. Please try again.');
    }
  }

  // --- EMAIL/PASSWORD SIGN IN ---
  Future<void> _signInWithEmailPassword() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage("Please enter email and password.");
      return;
    }

    try {
      final UserCredential credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final user = credential.user;
      if (user == null) {
        _showMessage("Unable to sign in. Please try again.");
        return;
      }

      if (mounted) {
        _checkRoleAndNavigate(user.uid);
      }
    } on FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        'user-disabled' => 'This user has been disabled.',
        'user-not-found' => 'No user found for that email.',
        'wrong-password' => 'Incorrect password.',
        'invalid-email' => 'The email address is not valid.',
        _ => 'Sign-in failed: ${e.message ?? e.code}',
      };
      _showMessage(message);
    } catch (e) {
      _showMessage('Sign-in failed. Please try again.');
    }
  }

  Future<void> _handleMainAction() async {
    FocusScope.of(context).unfocus();

    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      if (isSignIn) {
        await _signInWithEmailPassword();
      } else {
        await _signUpWithEmailPassword();
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _handleGoogleSignInResult(bool isLogged) {
    if (isLogged) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        _checkRoleAndNavigate(currentUser.uid);
      }
      return;
    }
    _showMessage("Google sign-in failed.");
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
              const SizedBox(height: 20),

              // --- Remember Me + Forgot Password ---
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 5,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: rememberMe,
                        onChanged: (value) {
                          setState(() {
                            rememberMe = value ?? false;
                          });
                        },
                      ),
                      const Text("Remember Me"),
                    ],
                  ),
                  TextButton(
                    onPressed: _resetPassword,
                    child: const Text("Forgot Password?"),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // --- MAIN ACTION BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleMainAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B65EC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
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
                          final bool isLogged = await login();

                          if (!mounted) return;
                          setState(() => isLoading = false);
                          _handleGoogleSignInResult(isLogged);
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
