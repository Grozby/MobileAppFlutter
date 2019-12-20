import 'package:flutter/material.dart';
import 'package:mobile_application/providers/theming/theme_provider.dart';

class LoadingAnimated extends StatefulWidget {
  const LoadingAnimated();

  @override
  _LoadingAnimatedState createState() => _LoadingAnimatedState();
}

class _LoadingAnimatedState extends State<LoadingAnimated>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation gradientPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    gradientPosition = Tween<double>(
      begin: -2,
      end: 4,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: gradientPosition,
      child: Text(
        "RyFy",
        style: Theme.of(context).textTheme.display2.copyWith(
              color: Colors.white,
              fontSize: 50,
            ),
      ),
      builder: (ctx, child) {
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            final gradient = LinearGradient(
              begin: Alignment(gradientPosition.value, 0),
              end: Alignment(gradientPosition.value - 2, 0),
              colors: [
                ThemeProvider.primaryColor.withOpacity(0.3),
                ThemeProvider.primaryColor.withOpacity(0.8),
                ThemeProvider.primaryColor.withOpacity(0.3),
              ],
            );

            // using bounds directly doesn't work because the shader origin is translated already
            // so create a new rect with the same size at origin
            return gradient.createShader(Offset.zero & bounds.size);
          },
          child: child,
        );
      },
    );
  }
}
