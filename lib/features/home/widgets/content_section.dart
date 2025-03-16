import 'package:flutter/material.dart';

class ContentSection extends StatelessWidget {
  final Widget header;
  final Widget content;
  final EdgeInsets padding;

  const ContentSection({
    Key? key,
    required this.header,
    required this.content,
    this.padding = const EdgeInsets.only(bottom: 24),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }
}
