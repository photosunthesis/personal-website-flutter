import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

class CRTShaderOverlay extends StatefulWidget {
  const CRTShaderOverlay({required this.child, super.key});

  final Widget child;

  @override
  State<CRTShaderOverlay> createState() => _CRTShaderOverlayState();
}

class _CRTShaderOverlayState extends State<CRTShaderOverlay> {
  double shadertime = 0;
  Timer? timer;
  bool _shaderLoaded = false;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      setState(() => shadertime += 0.016);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShaderBuilder(assetKey: 'assets/shaders/crt.glsl', (
      context,
      shader,
      child,
    ) {
      if (!_shaderLoaded) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _shaderLoaded = true);
        });
        // Show the child widget without shader while loading
        return child!;
      }

      return AnimatedSampler((image, size, canvas) {
        final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
        shader
          ..setFloat(0, image.width.toDouble() / devicePixelRatio)
          ..setFloat(1, image.height.toDouble() / devicePixelRatio)
          ..setFloat(2, shadertime)
          ..setImageSampler(0, image);

        canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
      }, child: child!);
    }, child: widget.child);
  }
}
