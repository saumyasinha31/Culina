import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool outlined;

  const AuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return outlined
        ? OutlinedButton( //future: would be using button from centralized ds component 
            onPressed: onPressed,
            child: Text(text),
          )
        : ElevatedButton(//future: would be using button from centralized ds component 
            onPressed: onPressed,
            child: Text(text),
          );
  }
}
