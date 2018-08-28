import 'package:flutter/material.dart';

import 'package:flutter_calendar/tick.dart';

class TickScroller extends StatelessWidget {
    
  final List<Tick> ticks;
  final Axis scrollDirection;

  TickScroller({
    this.ticks,
    this.scrollDirection = Axis.horizontal,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: scrollDirection,
      children: ticks,
    );
  }

}