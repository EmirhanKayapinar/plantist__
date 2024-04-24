import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:plantist/routes/app_pages.dart';

class RegisterController extends GetxController {
  RxBool isEmailValid = false.obs;
  RxBool isPasswordValid = false.obs;
  RxBool showPassword = false.obs;
  String password = "";
  String email = "";
  UserCredential? userCredential;
  Future<void> registerWithEmailPassword(String email, String password) async {
    try {
      EasyLoading.show();

      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      EasyLoading.dismiss();
      Get.toNamed(AppRoutes.home);
      debugPrint("Kayıt başarılı: ${userCredential.user!.email}");
    } on FirebaseAuthException catch (e) {
      debugPrint("Kayıt hatası: $e");
    }
  }

  Future<void> signInWithEmailPassword(String email, String password) async {
    try {
      EasyLoading.show();
       userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      
      EasyLoading.dismiss();

      Get.toNamed(AppRoutes.home);
      debugPrint("Giriş başarılı: ${userCredential?.user!.email}");
    } on FirebaseAuthException catch (e) {
      debugPrint("Giriş hatası: $e");
    }
  }
}
