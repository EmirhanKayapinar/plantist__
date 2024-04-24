import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plantist/routes/app_pages.dart';

import '../../constant/material_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialScreen(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.network("https://i.ibb.co/xCVthKq/bg2.png"),
          const Text(
            "Welcome back to",
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.w300),
          ),
          const Text(
            "Plantist",
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
          const Text("Start your productive life now!"),
          const SizedBox(
            height: 16,
          ),
          SizedBox(
            width: Get.width,
            height: 60,
            child: ElevatedButton.icon(
                onPressed: () {
                  Get.toNamed(AppRoutes.register);
                },
                style: ButtonStyle(
                    shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                )),
                icon: const Icon(Icons.mail),
                label: const Text("Sign in with email")),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Don't you have an account?"),
              TextButton(
                  onPressed: () {
                    Get.toNamed(AppRoutes.login);
                    // Get.toNamed(AppRoutes.home,arguments: {"user_id":});
                  },
                  child: const Text("Sign up"))
            ],
          ),
        ],
      ),
    );
  }
}
