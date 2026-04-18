import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthScreen(),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // This variable tracks if we are on the Sign In page or Sign Up page
  bool isSignIn = true;

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
                    // SIGN UP TAB
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isSignIn = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !isSignIn
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: !isSignIn
                                ? Border.all(color: Colors.grey[300]!)
                                : null,
                          ),
                          child: Text(
                            "Sign Up",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: !isSignIn
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: !isSignIn ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // SIGN IN TAB
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isSignIn = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSignIn ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: isSignIn
                                ? Border.all(color: Colors.grey[300]!)
                                : null,
                          ),
                          child: Text(
                            "Sign In",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: isSignIn
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSignIn ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),
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
                const TextField(
                  decoration: InputDecoration(hintText: "Enter your full name"),
                ),
                const SizedBox(height: 20),
              ],

              const Text(
                "Email",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const TextField(
                decoration: InputDecoration(hintText: "name@example.com"),
              ),
              const SizedBox(height: 20),

              const Text(
                "Password",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const TextField(
                obscureText: true,
                decoration: InputDecoration(hintText: "Enter your password"),
              ),

              if (isSignIn)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => print("Forgot Password Clicked"),
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(color: Color(0xFF2B65EC)),
                    ),
                  ),
                ),

              const SizedBox(height: 30),

              // --- MAIN ACTION BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    if (isSignIn) {
                      print("Logging in...");
                    } else {
                      print("Creating account...");
                    }
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
                  onPressed: () => print("Google Auth Started"),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Continue with Google",
                    style: TextStyle(color: Colors.black87, fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // --- FOOTER ---
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                      children: [
                        TextSpan(text: "By continuing, you agree to our "),
                        TextSpan(
                          text: "Terms of Service",
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        TextSpan(text: " and "),
                        TextSpan(
                          text: "Privacy Policy.",
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
