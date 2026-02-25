import 'package:flutter/material.dart';
import '../../app/core/constants/app_colors.dart';
import '../../app/core/constants/app_text_styles.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AmaraColors.bg,
      body: SafeArea(
        child: Center(
          child: Text('Explorer', style: AmaraTextStyles.h1),
        ),
      ),
    );
  }
}
