import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ParganaOverviewScreen extends StatelessWidget {
  const ParganaOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pargana Overview Test'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: const Center(
        child: Text('Pargana Overview Screen Loaded Successfully!', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
