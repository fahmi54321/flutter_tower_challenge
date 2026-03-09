import 'package:flutter/material.dart';

class PressButton extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onPressed;

  const PressButton({super.key, required this.child, required this.onPressed});

  @override
  State<PressButton> createState() => _PressButtonState();
}

class _PressButtonState extends State<PressButton> {
  double _scale = 1.0;

  Future<void> _handlePress() async {
    setState(() => _scale = 0.9);
    await Future.delayed(const Duration(milliseconds: 75));
    setState(() => _scale = 1.0);
    await Future.delayed(const Duration(milliseconds: 75));
    await widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 75),
      child: GestureDetector(onTap: _handlePress, child: widget.child),
    );
  }
}
