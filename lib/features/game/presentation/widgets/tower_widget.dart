import 'package:flutter/material.dart';
import 'package:tower/features/game/presentation/widgets/car_widget.dart';

class TowerWidget extends StatefulWidget {
  final int value;
  final int target;
  final bool showCar;
  final bool filledPlayer;
  final bool showAdd;
  final double width;
  final VoidCallback? onTap;
  final Duration animationDuration;

  const TowerWidget({
    super.key,
    required this.value,
    required this.target,
    this.showCar = false,
    this.filledPlayer = false,
    this.showAdd = false,
    this.width = 60,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<TowerWidget> createState() => _TowerWidgetState();
}

class _TowerWidgetState extends State<TowerWidget>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  Color getColor() {
    if (widget.showAdd) return Colors.grey;

    final progress = widget.target == 0 ? 0.0 : widget.value / widget.target;
    final p = progress.clamp(0.0, 1.0);

    if (p < 0.3) return Colors.green;
    if (p < 0.6) return Colors.yellow;
    if (p < 0.9) return Colors.orange;
    return Colors.red;
  }

  Future<void> _handleTap() async {
    if (widget.onTap == null) return;

    setState(() => _scale = 0.9);
    await Future.delayed(const Duration(milliseconds: 75));
    setState(() => _scale = 1.0);
    await Future.delayed(const Duration(milliseconds: 75));

    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    const double maxHeight = 180.0;
    const double minHeight = 40.0;

    final progress = widget.target == 0 ? 0.0 : widget.value / widget.target;
    final p = progress.clamp(0.0, 1.0);
    double height = p * maxHeight;
    if (height < minHeight) height = minHeight;

    return GestureDetector(
      onTap: widget.showAdd ? _handleTap : widget.onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (widget.showCar) const CarWidget(),

          AnimatedScale(
            scale: _scale,
            duration: const Duration(milliseconds: 150),
            child: AnimatedContainer(
              duration: widget.animationDuration,
              curve: Curves.easeOut,
              width: widget.width,
              height: height,
              decoration: BoxDecoration(
                color: getColor(),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: widget.showAdd
                    ? const Icon(Icons.add, size: 30, color: Colors.white)
                    : widget.filledPlayer
                    ? const Icon(Icons.person, color: Colors.white)
                    : Text(
                        widget.value.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          if (!widget.showAdd)
            Text(
              widget.value.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }
}
