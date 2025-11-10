import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame/widgets.dart';
import 'package:flame_network_assets/flame_network_assets.dart';
import 'package:flutter/material.dart';

class OverlaySprite extends StatefulWidget {
  final String url;
  final double stepTime;
  final Vector2 textureSize;
  final bool playing;

  const OverlaySprite({
    super.key,
    required this.url,
    required this.stepTime,
    required this.textureSize,
    this.playing = true,
  });

  @override
  State<StatefulWidget> createState() => _OverlaySpriteState();
}

class _OverlaySpriteState extends State<OverlaySprite> {
  SpriteAnimation? _animation;
  SpriteAnimationTicker? _ticker;

  @override
  void initState() {
    super.initState();
    final networkAssets = FlameNetworkImages();
    networkAssets.load(widget.url).then((img) {
      if (!mounted) return;
      setState(() {
        _animation = SpriteAnimation.fromFrameData(
          img,
          SpriteAnimationData.sequenced(
            amount: 4,
            textureSize: widget.textureSize,
            stepTime: widget.stepTime,
          ),
        );
        _ticker = SpriteAnimationTicker(_animation!);
      });
    });
  }

  @override
  void didUpdateWidget(covariant OverlaySprite oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.url != oldWidget.url ||
        widget.textureSize != oldWidget.textureSize) {
      _animation = null;
      _ticker = null;
      final networkAssets = FlameNetworkImages();
      networkAssets.load(widget.url).then((img) {
        _animation = SpriteAnimation.fromFrameData(
          img,
          SpriteAnimationData.sequenced(
            amount: 4,
            textureSize: widget.textureSize,
            stepTime: widget.stepTime,
          ),
        );
        _ticker = SpriteAnimationTicker(_animation!);
      });
    }

    if (widget.stepTime != oldWidget.stepTime) {
      _animation?.stepTime = widget.stepTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_animation == null || _ticker == null) return const SizedBox.shrink();
    return SpriteAnimationWidget(
      animation: _animation!,
      animationTicker: _ticker!,
      playing: widget.playing,
    );
  }
}
