import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/dependency_injection/service_locator.dart';
import '../../../../core/utiles/app_colors.dart';
import '../../../../core/widgets/text_button.dart';
import '../../../../core/widgets/text_form_field_widget.dart';
import '../../../home_feature/presentation/pages/home_screen.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_states.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
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
              ),
            );
          }
        },
        builder: (context, state) {
          var cubit = context.read<UserCubit>();
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "إنشاء حساب جديد",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "انضم إلينا لإدارة صيدليتك بذكاء",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 40),
                        CustomTextField(
                          controller: nameController,
                          label: "الاسم بالكامل",
                          prefixIcon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "يرجى إدخال الاسم";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: emailController,
                          label: "البريد الإلكتروني",
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "يرجى إدخال البريد الإلكتروني";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: phoneController,
                          label: "رقم الهاتف",
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icons.phone_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "يرجى إدخال رقم الهاتف";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: passwordController,
                          label: "كلمة المرور",
                          obscureText: cubit.isPassword,
                          keyboardType: TextInputType.visiblePassword,
                          prefixIcon: Icons.lock_outline,
                          suffixIconData: cubit.suffix,
                          suffixPressed: () {
                            cubit.changePasswordVisibility();
                          },
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return "كلمة المرور يجب أن لا تقل عن 6 أحرف";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 40),
                        CustomButton(
                          text: "إنشاء الحساب",
                          isLoading: state is LoadingState,
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              cubit.userRegister(
                                name: nameController.text,
                                email: emailController.text,
                                password: passwordController.text,
                                phone: phoneController.text,
                                id: "", 
                                token: "",
                              );
                            }
                          },
                        ),
                      ],
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
}
