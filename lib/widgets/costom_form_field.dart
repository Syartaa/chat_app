import 'package:flutter/material.dart';

class CostomFormField extends StatelessWidget {
  final String hintText;
  final double height;
  const CostomFormField(
      {super.key, required this.hintText, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextFormField(
        decoration: InputDecoration(
          hintText: hintText,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
