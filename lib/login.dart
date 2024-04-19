// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kavir_face/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'register.dart';

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginForm(),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _email = "";
  String _password = "";
  // bool _isObscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
                onSaved: (String? value) {
                  _email = value!;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                onSaved: (String? value) {
                  _password = value!;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState != null &&
                      _formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    // Send login data to backend
                    var url = Uri.parse('http://192.168.1.68:5000/login');
                    var response = await http.post(
                      url,
                      body: {
                        'email': _email,
                        'password': _password,
                      },
                    );

                    if (response.statusCode == 200) {
                      // Login successful, navigate to dashboard or home screen
                      // For now, let's print a success message
                      print('Login successful_1');
                      final prefs = await SharedPreferences.getInstance();
                      final responseBody =
                          json.decode(response.body); // Parse response body

                      // Check if the response body is not null
                      if (responseBody != null) {
                        final userId = responseBody['user_id'];
                        final sessionId = responseBody[
                            'session_id']; // Extract user_id from the response body

                        // Check if the user_id is not null
                        if (userId != null && sessionId != null) {
                          // Store the user_id in SharedPreferences
                          prefs.setString('user_id', userId.toString());
                          prefs.setString('session_id', sessionId.toString());

                          // Retrieve the stored user_id from SharedPreferences
                          final storedUserId = prefs.getString('user_id');
                          final storedSessionId = prefs.getString('session_id');

                          // Print the stored user_id
                          print('Stored user_id: $storedUserId');
                          print('Stored session_id: $storedSessionId');

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MyHomePage()),
                          );
                        } else {
                          // Handle the case where 'user_id' is null
                          print('user_id is null');
                        }
                      } else {
                        // Handle the case where the response body is null
                        print('Response body is null');
                      }
                    } else {
                      // Login failed, show error message
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Login Error'),
                            content: const Text(
                              'Failed to login. Please check your credentials.',
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  }
                },
                child: const Text('Login'),
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () {
                    // Navigate to the registration page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterApp()),
                    );
                  },
                  child: const Text(
                    'Don\'t have an account? Register here',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
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

// class RegisterApp extends StatelessWidget {
//   const RegisterApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Register Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const RegisterForm(),
//     );
//   }
// }

// class RegisterForm extends StatefulWidget {
//   const RegisterForm({super.key});

//   @override
//   _RegisterFormState createState() => _RegisterFormState();
// }

// class _RegisterFormState extends State<RegisterForm> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   String _name = "";
//   String _email = "";
//   String _password = "";
//   // String _confirmPassword = "";

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Register'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: <Widget>[
//               TextFormField(
//                 decoration: const InputDecoration(labelText: 'Name'),
//                 validator: (String? value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your name';
//                   }
//                   return null;
//                 },
//                 onSaved: (String? value) {
//                   _name = value!;
//                 },
//               ),
//               const SizedBox(height: 20),
//               TextFormField(
//                 decoration: const InputDecoration(labelText: 'Email'),
//                 validator: (String? value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your email';
//                   }
//                   return null;
//                 },
//                 onSaved: (String? value) {
//                   _email = value!;
//                 },
//               ),
//               const SizedBox(height: 20),
//               TextFormField(
//                 decoration: const InputDecoration(
//                   labelText: 'Password',
//                   // suffixIcon: IconButton(
//                   //   icon: Icon(
//                   //     _isObscurePassword
//                   //         ? Icons.visibility
//                   //         : Icons.visibility_off,
//                   //   ),
//                   //   onPressed: () {
//                   //     setState(() {
//                   //       _isObscurePassword = !_isObscurePassword;
//                   //     });
//                   //   },
//                   // ),
//                 ),
//                 // obscureText: _isObscurePassword,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your password';
//                   }
//                   return null;
//                 },
//                 onSaved: (value) {
//                   _password = value!;
//                 },
//               ),
//               const SizedBox(height: 20),
//               TextFormField(
//                 decoration:
//                     const InputDecoration(labelText: 'Confirm Password'),
//                 obscureText: true,
//                 validator: (String? value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please confirm your password';
//                   }
//                   if (value != _password) {
//                     return 'Passwords do not match';
//                   }
//                   return null;
//                 },
//                 onSaved: (String? value) {
//                   _confirmPassword = value!;
//                 },
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   if (_formKey.currentState != null &&
//                       _formKey.currentState!.validate()) {
//                     _formKey.currentState!.save();
//                     // Perform registration logic here
//                   }
//                 },
//                 child: const Text('Register'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
