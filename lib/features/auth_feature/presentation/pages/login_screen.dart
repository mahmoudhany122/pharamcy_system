import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/cache/cahche_helper.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utiles/app_colors.dart';
import '../../../home_feature/presentation/pages/home_screen.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_states.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var emailController = TextEditingController();
    var passwordController = TextEditingController();
    var formKey = GlobalKey<FormState>();
    var size = MediaQuery.of(context).size;

    return BlocProvider(
      create: (context) => AuthCubit(),
      child: BlocConsumer<AuthCubit, AuthStates>(
        listener: (context, state) {
          if (state is AuthLoginSuccessState || state is AuthSocialLoginSuccessState) {
            String uId = (state is AuthLoginSuccessState) 
                ? state.uId 
                : (state as AuthSocialLoginSuccessState).uId;

            CacheHelper.saveData(key: 'uId', value: uId).then((value) {
               Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            });
          }
          if (state is AuthLoginErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FadeInDown(
                              duration: const Duration(milliseconds: 800),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: const Icon(
                                  Icons.local_pharmacy_rounded,
                                  size: 80,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            FadeInLeft(
                              child: Text(
                                "login".tr(context),
                                style: TextStyle(
                                  fontSize: size.width * 0.09,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            FadeInRight(
                              child: Text(
                                "login_now".tr(context),
                                style: const TextStyle(color: Colors.white70, fontSize: 16),
                              ),
                            ),
                            const SizedBox(height: 40),
                            FadeInUp(
                              delay: const Duration(milliseconds: 200),
                              child: _buildGlassTextField(
                                controller: emailController,
                                label: "email".tr(context),
                                icon: Icons.email_outlined,
                                context: context,
                              ),
                            ),
                            const SizedBox(height: 20),
                            FadeInUp(
                              delay: const Duration(milliseconds: 400),
                              child: _buildGlassTextField(
                                controller: passwordController,
                                label: "password".tr(context),
                                icon: Icons.lock_outline,
                                isPassword: true,
                                cubit: cubit,
                                context: context,
                              ),
                            ),
                            const SizedBox(height: 40),
                            FadeInUp(
                              delay: const Duration(milliseconds: 600),
                              child: SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (formKey.currentState!.validate()) {
                                      cubit.userLogin(
                                        email: emailController.text,
                                        password: passwordController.text,
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 10,
                                  ),
                                  child: state is AuthLoginLoadingState
                                      ? const CircularProgressIndicator()
                                      : Text(
                                          "login".tr(context).toUpperCase(),
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            FadeIn(
                              delay: const Duration(milliseconds: 800),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("dont_have_account".tr(context), style: const TextStyle(color: Colors.white70)),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                                      );
                                    },
                                    child: Text(
                                      "register_now".tr(context),
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            FadeInUp(
                              delay: const Duration(milliseconds: 1000),
                              child: Row(
                                children: [
                                  const Expanded(child: Divider(color: Colors.white24)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Text("OR".tr(context), style: const TextStyle(color: Colors.white38)),
                                  ),
                                  const Expanded(child: Divider(color: Colors.white24)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            FadeInUp(
                              delay: const Duration(milliseconds: 1200),
                              child: _buildSocialButton(
                                label: "google_login".tr(context),
                                icon: Icons.g_mobiledata_rounded,
                                onTap: () => cubit.googleSignIn(),
                                isLoading: state is AuthLoginLoadingState,
                              ),
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
    required BuildContext context,
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
        validator: (value) => value!.isEmpty ? 'Field required' : null,
      ),
    );
  }

  Widget _buildSocialButton({required String label, required IconData icon, required VoidCallback onTap, bool isLoading = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white24),
          color: Colors.white.withOpacity(0.05),
        ),
        child: isLoading 
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.login, color: Colors.redAccent),
                const SizedBox(width: 10),
                Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
      ),
    );
  }
}
