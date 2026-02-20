import 'package:flutter/material.dart';
import '../../../core/widgets/custom_button.dart';
import '../../admin/screens/admin_dashboard.dart';
import '../../owner/screens/user_dashboard.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? selectedRole; // "admin" or "user"
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const dashboardGreen = Color.fromARGB(255, 0, 150, 136);

    bool roleSelected = selectedRole != null;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 50),
              Text(
                'PetGuard Pro',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              const Text(
                'Login to continue',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 32),

              // ROLE SELECTION
              const Text(
                "Select Role",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedRole = selectedRole == "admin" ? null : "admin";
                        });
                      },
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: selectedRole == "admin" ? dashboardGreen : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            "Admin",
                            style: TextStyle(
                              color: selectedRole == "admin" ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedRole = selectedRole == "user" ? null : "user";
                        });
                      },
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: selectedRole == "user" ? dashboardGreen : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            "User",
                            style: TextStyle(
                              color: selectedRole == "user" ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // EMAIL FIELD
              TextField(
                controller: emailController,
                enabled: roleSelected,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: const OutlineInputBorder(),
                  fillColor: roleSelected ? null : Colors.grey[200],
                  filled: !roleSelected,
                ),
              ),
              const SizedBox(height: 16),

              // PASSWORD FIELD
              TextField(
                controller: passwordController,
                enabled: roleSelected,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  fillColor: roleSelected ? null : Colors.grey[200],
                  filled: !roleSelected,
                ),
              ),
              const SizedBox(height: 32),

              // LOGIN BUTTON
              CustomButton(
                text: 'Login',
                color: dashboardGreen,
                onTap: roleSelected
                    ? () {
                        if (selectedRole == "admin") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                          );
                        } else if (selectedRole == "user") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const UserDashboardScreen()),
                          );
                        }
                      }
                    : () {}, // do nothing if no role selected
              ),
              const SizedBox(height: 16),

              // SIGNUP BUTTON
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignupScreen()),
                  );
                },
                child: const Text("Create new account"),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}