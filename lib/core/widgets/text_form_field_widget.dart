import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final IconData? prefixIcon;
  final IconData? suffixIconData;
  final Widget? suffixWidget;
  final VoidCallback? suffixPressed; // 👈 مضافة لعمل الأزرار داخل الحقل
  final VoidCallback? onTap;         // 👈 مضافة لاختيار التاريخ (Expiry Date)
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool readOnly;               // 👈 لمنع الكتابة اليدوية في حقول معينة

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIconData,
    this.suffixWidget,
    this.suffixPressed,
    this.onTap,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onTap: onTap,
      readOnly: readOnly,
      style: const TextStyle(fontSize: 16), // توحيد حجم الخط
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,

        // 👈 السحر هنا: لو فيه Widget جاهزة حطها، لو أيقونة بس حولها لـ IconButton
        suffixIcon: suffixWidget ??
            (suffixIconData != null
                ? IconButton(
              icon: Icon(suffixIconData),
              onPressed: suffixPressed,
            )
                : null),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // شكل عصري أكتر
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
