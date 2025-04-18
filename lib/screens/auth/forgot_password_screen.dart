import 'package:flutter/material.dart';
import 'package:metaphora/controllers/auth_controller.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  String? _errorMessage;
  String? _successMessage;
  bool _isSubmitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = null;
        _successMessage = null;
        _isSubmitted = false;
      });

      final authController = Provider.of<AuthController>(context, listen: false);
      final result = await authController.sendPasswordResetEmail(
        _emailController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _isSubmitted = true;
        if (result.success) {
          _successMessage = result.message;
        } else {
          _errorMessage = result.message;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authController = Provider.of<AuthController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password"),
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // App Title
                  Text(
                    "Reset Password",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    "Enter your email to receive a password reset link",
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Error message if reset fails
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Success message if reset email is sent
                  if (_successMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _successMessage!,
                              style: const TextStyle(
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  if (_errorMessage != null || _successMessage != null)
                    const SizedBox(height: 24),
                  
                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      hintText: "Enter your registered email",
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your email";
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return "Please enter a valid email";
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Reset Password Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: authController.isLoading ? null : _resetPassword,
                      child: authController.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "Reset Password",
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Back to Login
                  if (_isSubmitted && _successMessage != null)
                    TextButton.icon(
                      icon: const Icon(Icons.arrow_back),
                      label: const Text("Back to Login"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
