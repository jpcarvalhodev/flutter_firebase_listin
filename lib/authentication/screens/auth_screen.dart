import 'package:flutter/material.dart';
import 'package:flutter_firebase_listin/_core/my_colors.dart';
import 'package:flutter_firebase_listin/authentication/components/show_snackbar.dart';
import 'package:flutter_firebase_listin/authentication/services/auth_services.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool islogginIn = true;

  final _formKey = GlobalKey<FormState>();

  AuthServices authServices = AuthServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.network(
                      "https://cdn-icons-png.flaticon.com/512/3737/3737172.png",
                      height: 64,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        (islogginIn) ? "Welcome to Listin!" : "Shall we begin?",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      (islogginIn)
                          ? "Login to start creating your shopping list."
                          : "Sign up to start creating your shopping list.",
                      textAlign: TextAlign.center,
                    ),
                    Visibility(
                      visible: !islogginIn,
                      child: TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          label: Text("Name"),
                        ),
                        validator: (value) {
                          if (value == null || value.length < 3) {
                            return "Insert a name with more than 3 characters.";
                          }
                          return null;
                        },
                      ),
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(label: Text("E-mail")),
                      validator: (value) {
                        if (value == null || value == "") {
                          return "E-mail is required.";
                        }
                        if (!value.contains("@") ||
                            !value.contains(".") ||
                            value.length < 4) {
                          return "E-mail is invalid.";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration:
                          const InputDecoration(label: Text("Password")),
                      validator: (value) {
                        if (value == null || value.length < 4) {
                          return "Password is invalid.";
                        }
                        return null;
                      },
                    ),
                    Visibility(
                      visible: islogginIn,
                      child: TextButton(
                          onPressed: () {
                            forgotPassword();
                          },
                          child: const Text("Forgot your password?")),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Visibility(
                          visible: !islogginIn,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _confirmController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  label: Text("Confirm Password"),
                                ),
                                validator: (value) {
                                  if (value == null || value.length < 6) {
                                    return "Insert a password with more than 6 characters.";
                                  }
                                  if (value != _passwordController.text) {
                                    return "Passwords do not match.";
                                  }
                                  return null;
                                },
                              ),
                            ],
                          )),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        sendButton();
                      },
                      child: Text(
                        (islogginIn) ? "Login" : "Sign Up",
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          islogginIn = !islogginIn;
                        });
                      },
                      child: Text(
                        (islogginIn)
                            ? "Not signed up?\nClick here to sign in!"
                            : "Already have an account?\nClick here to login!",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: MyColors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  sendButton() {
    String name = _nameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    if (_formKey.currentState!.validate()) {
      if (islogginIn) {
        _loggedUser(email: email, password: password);
      } else {
        _signUpUser(name: name, email: email, password: password);
      }
    }
  }

  _loggedUser({required String email, required String password}) {
    authServices
        .loggedUser(email: email, password: password)
        .then((String? error) {
      if (error != null) {
        showSnackBar(context: context, message: error);
      }
    });
  }

  _signUpUser(
      {required String name, required String email, required String password}) {
    authServices
        .signUpUser(
      name: name,
      email: email,
      password: password,
    )
        .then((String? error) {
      if (error != null) {
        showSnackBar(context: context, message: error);
      }
    });
  }

  forgotPassword() {
    String email = _emailController.text;
    showDialog(
        context: context,
        builder: (context) {
          TextEditingController forgottenPasswordController =
              TextEditingController(text: email);
          return AlertDialog(
            title: const Text("Forgotten Password"),
            content: TextFormField(
              controller: forgottenPasswordController,
              decoration: const InputDecoration(label: Text("E-mail")),
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32)),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  authServices
                      .forgottenPassword(
                          email: forgottenPasswordController.text)
                      .then((String? error) {
                    if (error == null) {
                      showSnackBar(
                          context: context,
                          message: "Password reset email sent successfully!",
                          isError: false);
                    } else {
                      showSnackBar(context: context, message: error);
                    }
                    Navigator.pop(context);
                  });
                },
                child: const Text("Send E-mail"),
              )
            ],
          );
        });
  }
}
