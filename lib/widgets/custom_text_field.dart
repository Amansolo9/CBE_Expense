import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final IconData? icon;
  final TextEditingController? controller;
  final bool showToggle;

  const CustomTextField({
    required this.label,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.icon,
    this.controller,
    this.showToggle = false,
    Key? key,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscure = false;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontFamily: 'LexendDeca',
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF333333),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscure,
          validator: widget.validator,
          onChanged: widget.onChanged,
          style: const TextStyle(
            fontFamily: 'LexendDeca',
            fontWeight: FontWeight.normal,
            fontSize: 16,
            color: Color(0xFF333333),
            letterSpacing: 0.3,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            prefixIcon:
                widget.icon != null
                    ? Icon(widget.icon, color: Color(0xFFCD359C))
                    : null,
            suffixIcon:
                widget.showToggle
                    ? IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: Color(0xFFCD359C),
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    )
                    : null,
            hintText: 'Enter your ${widget.label.toLowerCase()}',
            hintStyle: const TextStyle(
              fontFamily: 'LexendDeca',
              fontWeight: FontWeight.normal,
              fontSize: 16,
              color: Color(0xFF999999),
              letterSpacing: 0.3,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFCD359C), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF4D4F), width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF4D4F), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
