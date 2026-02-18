import 'package:flutter/material.dart';

class StatusMessageWidget extends StatelessWidget {
  final String message;
  final bool show;

  const StatusMessageWidget({required this.message, this.show = true, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.black54,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
