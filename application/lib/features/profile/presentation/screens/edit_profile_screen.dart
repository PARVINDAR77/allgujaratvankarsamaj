import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Edit Profile (પ્રોફાઈલ સુધારો)', style: TextStyle(color: AppColors.secondary)),
        iconTheme: const IconThemeData(color: AppColors.secondary),
      ),
      body: const SafeArea(
        child: Center(
          child: Text('પ્રોફાઈલ સુધારવા માટેની વિગતો', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
