import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/dependency_injection/service_locator.dart';
import '../../../../core/utiles/app_colors.dart';
import '../../../../core/widgets/text_button.dart';
import '../../../../core/widgets/text_form_field_widget.dart';
import '../../../home_feature/presentation/pages/home_screen.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_states.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuad),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<UserCubit>(),
      child: BlocConsumer<UserCubit, AuthStates>(
        listener: (context, state) {
          if (state is SuccessState) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
          if (state is ErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          var cubit = context.read<UserCubit>();
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Stack(
              children: [
                // Background Design Element
                Positioned(
                  top: -100,
                  right: -100,
                  child: Container(
                    height: 300,
                    width: 300,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: FadeTransition(
                        opacity: _opacityAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Form(
                            key: formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Icon(
                                  Icons.local_pharmacy_rounded,
                                  size: 80,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  "أهلاً بك مرة أخرى",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "قم بتسجيل الدخول لإدارة صيدليتك باحترافية",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 50),
                                _buildTextFieldContainer(
                                  child: CustomTextField(
                                    controller: emailController,
                                    label: "البريد الإلكتروني",
                                    keyboardType: TextInputType.emailAddress,
                                    prefixIcon: Icons.alternate_email_rounded,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "يرجى إدخال البريد الإلكتروني";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildTextFieldContainer(
                                  child: CustomTextField(
                                    controller: passwordController,
                                    label: "كلمة المرور",
                                    obscureText: cubit.isPassword,
                                    keyboardType: TextInputType.visiblePassword,
                                    prefixIcon: Icons.lock_outline_rounded,
                                    suffixIconData: cubit.suffix,
                                    suffixPressed: () {
                                      cubit.changePasswordVisibility();
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "يرجى إدخال كلمة المرور";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: CustomTextButton(
                                    text: "نسيت كلمة المرور؟",
                                    onPressed: () {},
                                    textColor: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 40),
                                CustomButton(
                                  text: "تسجيل الدخول",
                                  isLoading: state is LoadingState,
                                  onPressed: () {
                                    if (formKey.currentState!.validate()) {
                                      cubit.userLogin(
                                        email: emailController.text,
                                        password: passwordController.text,
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(height: 30),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "ليس لديك حساب؟",
                                      style: TextStyle(color: AppColors.textSecondary),
                                    ),
                                    CustomTextButton(
                                      text: "أنشئ حساباً الآن",
                                      fontWeight: FontWeight.bold,
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const RegisterScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextFieldContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}
