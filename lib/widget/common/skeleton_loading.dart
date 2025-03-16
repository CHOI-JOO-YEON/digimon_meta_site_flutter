import 'package:flutter/material.dart';

class SkeletonLoading extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<SkeletonLoading> createState() => _SkeletonLoadingState();
}

class _SkeletonLoadingState extends State<SkeletonLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value, 0),
              end: Alignment(-_animation.value, 0),
              colors: [
                Colors.grey.shade200,
                Colors.grey.shade300,
                Colors.grey.shade200,
              ],
            ),
          ),
        );
      },
    );
  }
}

class CardSkeletonLoading extends StatelessWidget {
  final double width;
  final double aspectRatio;

  const CardSkeletonLoading({
    super.key,
    required this.width,
    this.aspectRatio = 5 / 7,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width / aspectRatio,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SkeletonLoading(
        width: width,
        height: width / aspectRatio,
        borderRadius: 8,
      ),
    );
  }
}

class CardGridSkeletonLoading extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double spacing;
  final double aspectRatio;

  const CardGridSkeletonLoading({
    super.key,
    this.itemCount = 12,
    this.crossAxisCount = 4,
    this.spacing = 8.0,
    this.aspectRatio = 5 / 7,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return CardSkeletonLoading(
              width: constraints.maxWidth,
            );
          },
        );
      },
    );
  }
} 