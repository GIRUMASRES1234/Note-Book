import 'package:flutter/material.dart';

class AppSnackBar {
  static void error(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xff1e293b),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void success(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xff1e293b),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.greenAccent.withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.greenAccent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String cleanFirebaseError(String error) {
    if (error.contains("network-request-failed")) {
      return "No internet connection. Please check your network.";
    }
    if (error.contains("email-already-in-use")) {
      return "This email is already registered.";
    }
    if (error.contains("weak-password")) {
      return "Password is too weak. Use at least 6 characters.";
    }
    if (error.contains("invalid-email")) {
      return "Invalid email format.";
    }
    if (error.contains("wrong-password")) {
      return "Wrong password. Try again.";
    }
    if (error.contains("user-not-found")) {
      return "Account not found.";
    }
    if (error.contains("too-many-requests")) {
      return "Too many attempts. Try again later.";
    }
    return "Something went wrong. Please try again.";
  }
}
