import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class DoubleTapHeart extends StatefulWidget {
  final Widget child;
  final VoidCallback onLike;
  final double heartSize;

  const DoubleTapHeart({
    super.key,
    required this.child,
    required this.onLike,
    this.heartSize = 100,
  });

  @override
  State<DoubleTapHeart> createState() => _DoubleTapHeartState();
}

class _DoubleTapHeartState extends State<DoubleTapHeart> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(begin: 0.4, end: 1.15).chain(CurveTween(curve: Curves.easeOutBack)),
      weight: 45,
    ),
    TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 15),
    TweenSequenceItem(tween: ConstantTween(1.0), weight: 40),
  ]).animate(_controller);

  late final Animation<double> _opacity = TweenSequence<double>([
    TweenSequenceItem(tween: ConstantTween(1.0), weight: 65),
    TweenSequenceItem(
      tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeOut)),
      weight: 35,
    ),
  ]).animate(_controller);

  void _handleDoubleTap() {
    widget.onLike();
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _handleDoubleTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          widget.child,
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                if (_controller.value == 0) return const SizedBox.shrink();
                return Opacity(
                  opacity: _opacity.value,
                  child: Transform.scale(
                    scale: _scale.value,
                    child: Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: widget.heartSize,
                      shadows: const [Shadow(color: Colors.black45, blurRadius: 18)],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedLikeButton extends StatefulWidget {
  final bool isLiked;
  final VoidCallback onTap;
  final double size;

  const AnimatedLikeButton({
    super.key,
    required this.isLiked,
    required this.onTap,
    this.size = 24,
  });

  @override
  State<AnimatedLikeButton> createState() => _AnimatedLikeButtonState();
}

class _AnimatedLikeButtonState extends State<AnimatedLikeButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    lowerBound: 0.8,
    upperBound: 1.0,
    value: 1.0,
  );

  void _bounce() {
    _controller.forward(from: 0.8);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap();
        _bounce();
      },
      child: ScaleTransition(
        scale: _controller,
        child: Icon(
          widget.isLiked ? Icons.favorite : Icons.favorite_border,
          color: widget.isLiked ? AppTheme.like : Colors.white,
          size: widget.size,
        ),
      ),
    );
  }
}
