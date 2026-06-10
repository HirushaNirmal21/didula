import 'package:didula_api/utils/constanse/appconstance.dart';
import 'package:flutter/material.dart';

class Responsivelayout extends StatefulWidget {
  final Widget mobilelayout;
  final Widget weblayout;
  const Responsivelayout({
    super.key,
    required this.mobilelayout,
    required this.weblayout,
  });

  @override
  State<Responsivelayout> createState() => _ResponsivelayoutState();
}

class _ResponsivelayoutState extends State<Responsivelayout> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > webMinScreenWidth) {
          return widget.weblayout;
        } else {
          return widget.mobilelayout;
        }
      },
    );
  }
}
