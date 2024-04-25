// ignore_for_file: must_be_immutable

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plantist/constant/material_screen.dart';
import 'package:plantist/theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:plantist/ui/register/register_controller.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});
  RegisterController controller = Get.put(RegisterController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState> _emailFieldKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _passwordFieldKey =
      GlobalKey<FormFieldState>();
  @override
  Widget build(BuildContext context) {
    return MaterialScreen(
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_arrow_left,
            size: 36,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        title: const Text(""),
        body: InkWell(
          enableFeedback: false,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Form(
            key: _formKey,
            child: SizedBox(
              width: Get.width,
              height: Get.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sign up with email",
                    style: const ThemeTextStyles().titleMedium,
                  ),
                  themeSpaceHeight16,
                  Text(
                    "Enter your email and password",
                    style: const ThemeTextStyles().bodySmall,
                  ),
                  themeSpaceHeight24,
                  TextFormField(
                    textAlignVertical: TextAlignVertical.center,
                    key: _emailFieldKey,
                    decoration: InputDecoration(
                        hintText: 'E-mail',
                        contentPadding: const EdgeInsets.only(left: 24),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade500),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade500),
                        ),
                        suffixIcon: Obx(() => controller.isEmailValid.value
                            ? const Icon(
                                FontAwesomeIcons.solidCircleCheck,
                                size: 20,
                              )
                            : const SizedBox())),
                    obscureText: false,
                    keyboardType: TextInputType.emailAddress,
                    cursorColor: Colors.black,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email required';
                      }

                      if (!RegExp(r'\b[\w\.-]+@[\w\.-]+\.\w{2,4}\b')
                          .hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        _emailFieldKey.currentState!.validate();
                      } else {
                        _emailFieldKey.currentState!.reset();
                      }

                      controller.isEmailValid.value =
                          RegExp(r'\b[\w\.-]+@[\w\.-]+\.\w{2,4}\b')
                              .hasMatch(value);
                      controller.email = value;
                    },
                  ),
                  themeSpaceHeight16,
                  Obx(
                    () => TextFormField(
                      key: _passwordFieldKey,
                      textAlignVertical: TextAlignVertical.center,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password required';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        if (!value.contains(RegExp(r'[A-Z]'))) {
                          return 'Password must contain at least one uppercase letter';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        controller.isPasswordValid.value =
                            value.contains(RegExp(r'[A-Z]'));
                        if (value.isNotEmpty) {
                          _passwordFieldKey.currentState!.validate();
                        } else {
                          _passwordFieldKey.currentState!.reset();
                        }
                        controller.password = value;
                      },
                      decoration: InputDecoration(
                        hintText: 'Password',
                        contentPadding: const EdgeInsets.only(left: 24),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade500),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade500),
                        ),
                        suffixIcon: Obx(() => controller.showPassword.value
                            ? IconButton(
                                icon: const Icon(
                                  FontAwesomeIcons.eye,
                                  size: 16,
                                ),
                                onPressed: () {
                                  controller.showPassword.value =
                                      !controller.showPassword.value;
                                },
                              )
                            : IconButton(
                                icon: const Icon(
                                  FontAwesomeIcons.eyeSlash,
                                  size: 16,
                                ),
                                onPressed: () {
                                  controller.showPassword.value =
                                      !controller.showPassword.value;
                                },
                              )),
                      ),
                      obscureText: controller.showPassword.value,
                      cursorColor: Colors.black,
                    ),
                  ),
                  themeSpaceHeight24,
                  SizedBox(
                    width: Get.width,
                    height: 60,
                    child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Get.toNamed(AppRoutes.home);

                            // controller.registerWithEmailPassword(
                            //     controller.email, controller.password);

                            controller.registerWithEmailPassword(
                                controller.email, controller.password);
                            debugPrint('Form geçerli!');
                          } else {
                            debugPrint('Form geçersiz!');
                          }
                        },
                        style: ButtonStyle(
                            backgroundColor: !controller.isEmailValid.value
                                ? MaterialStatePropertyAll(Colors.grey.shade300)
                                : const MaterialStatePropertyAll(Colors.black),
                            shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            )),
                        child: Text(
                          "Create Account",
                          style: const ThemeTextStyles().bodyLarge.copyWith(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )),
                  ),
                  themeSpaceHeight16,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(children: [
                            TextSpan(
                                text: "By countinuing, you agree to our",
                                style: const ThemeTextStyles()
                                    .bodySmall
                                    .copyWith(color: Colors.black)),
                            TextSpan(
                              text: " Privacy Policy",
                              style: const ThemeTextStyles().bodySmall.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline),
                              recognizer: TapGestureRecognizer()..onTap = () {},
                            ),
                            TextSpan(
                                text: " and",
                                style: const ThemeTextStyles()
                                    .bodySmall
                                    .copyWith(color: Colors.black)),
                            TextSpan(
                              text: " \nTerms of Use",
                              style: const ThemeTextStyles().bodySmall.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline),
                              recognizer: TapGestureRecognizer()..onTap = () {},
                            ),
                          ])),
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
