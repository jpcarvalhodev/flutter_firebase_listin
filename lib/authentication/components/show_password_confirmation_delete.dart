import "package:flutter/material.dart";
import "package:flutter_firebase_listin/authentication/services/auth_services.dart";

showPasswordConfirmationDeleteDialog({
  required BuildContext context,
  required String email,
}) {
  showDialog(
    context: context,
    builder: (context) {
      TextEditingController passwordDeleteController = TextEditingController();
      return AlertDialog(
        title: Text("Are you sure you want to delete $email?"),
        content: SizedBox(
          height: 175,
          child: Column(
            children: [
              const Text("To confirm, please type your password:"),
              TextFormField(
                obscureText: true,
                controller: passwordDeleteController,
                decoration: const InputDecoration(
                  labelText: "Password",
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              AuthServices()
                  .removeAccount(password: passwordDeleteController.text)
                  .then((String? error) {
                if (error == null) {
                  Navigator.pop(context);
                }
              });
            },
            child: const Text("Erase account!"),
          ),
        ],
      );
    },
  );
}
