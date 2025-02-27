import 'package:flutter/material.dart';

class TextFieldInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isPassword;
  final String hintText;
  final TextInputType textInputType;

  const TextFieldInput(
      {required this.textEditingController,
      this.isPassword = false,
      required this.hintText,
      required this.textInputType,
      super.key});

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: Divider.createBorderSide(context));

    return TextField(
      controller: textEditingController,
      decoration: InputDecoration(
        hintText: hintText,
        border: inputBorder,
        focusedBorder: inputBorder,
        enabledBorder: inputBorder,
        contentPadding: const EdgeInsets.all(8),
        filled: true,
      ),
      keyboardType: textInputType,
      obscureText: isPassword,
    );
  }
}
