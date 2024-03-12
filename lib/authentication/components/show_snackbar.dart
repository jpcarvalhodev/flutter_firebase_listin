import "package:flutter/material.dart";

showSnackBar({required BuildContext context, required String message, bool isError = true}) {
  SnackBar snackBar = SnackBar(
    content: Text(message),
    backgroundColor: (isError) ? Colors.red[300] : Colors.green[300],
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
