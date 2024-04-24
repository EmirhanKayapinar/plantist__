import 'package:flutter/material.dart';

class MaterialScreen extends StatelessWidget {
  const MaterialScreen(
      {super.key, required this.body, this.title, this.leading,this.actions});
  final Widget body;
  final Text? title;
  final Widget? leading;
  final List<Widget>? actions;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title != null
          ? AppBar(
              title: title,
              leading: leading,
              actions: actions,
            )
          : null,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: body,
        ),
      ),
    );
  }
}
