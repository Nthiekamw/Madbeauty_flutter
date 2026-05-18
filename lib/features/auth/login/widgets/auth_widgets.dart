import 'package:flutter/material.dart';

const _gold     = Color(0xFFC4956A);
const _goldLight= Color(0xFFEDE0CC);
const _textDark = Color(0xFF2C1810);
const _textGrey = Color(0xFF9E8878);

class AuthLabel extends StatelessWidget {
  const AuthLabel({required this.text, required this.rem});
  final String text; final double rem;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: rem * 2),
    child: Text(text, style: TextStyle(
      fontSize: rem * 3.8, fontWeight: FontWeight.w600, color: _textDark)));
}

class AuthField extends StatelessWidget {
  const AuthField({required this.label, required this.ctrl, required this.hint,
    required this.rem, this.type = TextInputType.text});
  final String label, hint; final TextEditingController ctrl;
  final double rem; final TextInputType type;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: TextStyle(
      fontSize: rem * 3.8, fontWeight: FontWeight.w600, color: _textDark)),
    SizedBox(height: rem * 2),
    AuthTextField(ctrl: ctrl, hint: hint, enabled: true, rem: rem, type: type),
    SizedBox(height: rem * 3.5),
  ]);
}

class AuthTextField extends StatelessWidget {
  const AuthTextField({required this.ctrl, required this.hint,
    required this.enabled, required this.rem,
    this.type = TextInputType.text, this.error});
  final TextEditingController ctrl; final String hint;
  final bool enabled; final double rem;
  final TextInputType type; final String? error;
  @override
  Widget build(BuildContext context) => TextField(
    controller: ctrl, enabled: enabled, keyboardType: type,
    style: TextStyle(fontSize: rem * 3.8, color: _textDark),
    decoration: authDeco(hint, rem, error: error));
}

InputDecoration authDeco(String hint, double rem, {String? error}) => InputDecoration(
  hintText: hint,
  hintStyle: TextStyle(color: _textGrey, fontSize: rem * 3.5),
  errorText: error,
  filled: true, fillColor: const Color(0xFFF8F5F0),
  contentPadding: EdgeInsets.symmetric(horizontal: rem * 4, vertical: rem * 3.2),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(rem * 6),
    borderSide: const BorderSide(color: Color(0xFFEDE0CC))),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(rem * 6),
    borderSide: const BorderSide(color: Color(0xFFEDE0CC))),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(rem * 6),
    borderSide: BorderSide(color: _gold, width: 2)),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(rem * 6),
    borderSide: const BorderSide(color: Colors.red)));