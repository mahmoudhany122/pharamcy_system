import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utiles/app_colors.dart';
import '../../../home_feature/presentation/pages/home_screen.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_states.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var nameController = TextEditingController();
    var emailController = TextEditingController();
    var passwordController = TextEditingController();
    var phoneController = TextEditingController();
    var formKey = GlobalKey<FormState>();
    var size = MediaQuery.of(context).size;

    return BlocProvider(
      create: (context) => AuthCubit(),
      child: BlocConsumer<AuthCubit, AuthStates>(
        listener: (context, state) {
          if (state is AuthCreateUserSuccessState) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          var cubit = AuthCubit.get(context);

          return Scaffold(
            body: Container(
              height: size.height,
              width: size.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.7),
                    Colors.black,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            FadeInDown(
                              child: Text(
                                "register".tr(context),
                                style: TextStyle(
                                  fontSize: size.width * 0.09,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            FadeInUp(
                              delay: const Duration(milliseconds: 200),
                              child: _buildGlassTextField(
                                controller: nameController,
                                label: "name".tr(context),
                                icon: Icons.person_outline,
                              ),
                            ),
                            const SizedBox(height: 15),
                            FadeInUp(
                              delay: const Duration(milliseconds: 400),
                              child: _buildGlassTextField(
                                controller: emailController,
                                label: "email".tr(context),
                                icon: Icons.email_outlined,
                              ),
                            ),
                            const SizedBox(height: 15),
                            FadeInUp(
                              delay: const Duration(milliseconds: 600),
                              child: _buildGlassTextField(
                                controller: passwordController,
                                label: "password".tr(context),
                                icon: Icons.lock_outline,
                                isPassword: true,
                                cubit: cubit,
                              ),
                            ),
                            const SizedBox(height: 15),
                            FadeInUp(
                              delay: const Duration(milliseconds: 800),
                              child: _buildGlassTextField(
                                controller: phoneController,
                                label: "phone".tr(context),
                                icon: Icons.phone_outlined,
                              ),
                            ),
                            const SizedBox(height: 40),
                            FadeInUp(
                              delay: const Duration(milliseconds: 1000),
                              child: SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (formKey.currentState!.validate()) {
                                      cubit.userRegister(
                                        name: nameController.text,
                                        email: emailController.text,
                                        password: passwordController.text,
                                        phone: phoneController.text,
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: state is AuthRegisterLoadingState
                                      ? const CircularProgressIndicator()
                                      : Text(
                                          "register".tr(context).toUpperCase(),
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Already have an account? Login", style: TextStyle(color: Colors.white70)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    AuthCubit? cubit,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white24),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? (cubit?.isPassword ?? true) : false,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white70),
          suffixIcon: isPassword
              ? IconButton(
                  onPressed: () => cubit?.changePasswordVisibility(),
                  icon: Icon(cubit?.suffix, color: Colors.white70),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        validator: (value) => value!.isEmpty ? 'Required' : null,
      ),
    );
  }
}
