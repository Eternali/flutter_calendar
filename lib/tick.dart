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
      margin: const EdgeInsets.symmetric(horizontal: 2.0),
      height: 14.0,
      width: 14.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

}