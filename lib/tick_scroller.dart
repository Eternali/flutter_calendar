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
    return Container(
      alignment: Alignment.center,
      height: 14.0,
      child: ListView(
        scrollDirection: scrollDirection,
        shrinkWrap: true,
        children: ticks,
      ),
    );
  }

}