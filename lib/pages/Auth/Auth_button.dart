import 'package:flutter/material.dart';

class AppGradientButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;

  const AppGradientButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          colors: [
            // Color.fromRGBO(187, 63, 221, 1),
            // Color.fromRGBO(251, 109, 169, 1),
            Color.fromRGBO(63, 221, 76, 1),
            // Color.fromRGBO(165, 223, 142, 1),
            Color.fromRGBO(119, 255, 65, 1),
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          fixedSize: Size(MediaQuery.of(context).size.width, 55),
          // fixedSize:  Size(400, 55),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        ),
        child: Text(
          buttonText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
