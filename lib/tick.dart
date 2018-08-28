import 'package:flutter/material.dart';

typedef List<Tick> TicksBuilder(BuildContext context, DateTime day);

class Tick extends StatelessWidget {

  Color color;

  Tick({
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

}