import 'package:flutter/material.dart';

class BarrierLayer {
  final double from, to, yPosition;

  BarrierLayer(this.from, this.to, this.yPosition);
}

class Raindrop {
  final Offset position;
  final bool grounded;

  Raindrop(this.position, this.grounded);
}

class Snowflake {
  final Offset position;
  final bool grounded;
  final int groundedSeconds;

  Snowflake(this.position, this.grounded, this.groundedSeconds);
}
