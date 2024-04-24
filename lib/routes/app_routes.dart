import 'package:get/get.dart';
import 'package:plantist/routes/app_pages.dart';
import 'package:plantist/ui/home/home.dart';
import 'package:plantist/ui/login/login.dart';
import 'package:plantist/ui/register/register.dart';


class AppPages {
  static var list = [
    GetPage(
        name: AppRoutes.login,
        page: () => LoginScreen(),
        transition: Transition.fadeIn),
    GetPage(
        name: AppRoutes.register,
        page: () => RegisterScreen(),
        transition: Transition.fadeIn),
    GetPage(
        name: AppRoutes.home,
        page: () =>  HomeScreen(),
        transition: Transition.fadeIn),
  ];
}
