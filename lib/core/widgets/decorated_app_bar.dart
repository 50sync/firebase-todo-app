import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class DecoratedAppBar extends StatelessWidget {
  const DecoratedAppBar({super.key,
  required this.height
  });

  final double height;
  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.none,
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(color: Color(0xFF4a3780)),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.bottomLeft,
            child: SvgPicture.asset('assets/ellipse1.svg'),
          ),
          Align(
            alignment: Alignment.topRight,
            child: SvgPicture.asset('assets/ellipse2.svg'),
          ),
        ],
      ),
    );
  }
}
