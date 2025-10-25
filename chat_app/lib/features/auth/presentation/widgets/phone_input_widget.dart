import 'package:flutter/material.dart';

class PhoneInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final String countryCode;
  final Function(String) onChanged;
  final String? Function(String?) validator;

  const PhoneInputWidget({
    super.key,
    required this.controller,
    required this.countryCode,
    required this.onChanged,
    required this.validator,
  });

  @override
  State<PhoneInputWidget> createState() => _PhoneInputWidgetState();
}

class _PhoneInputWidgetState extends State<PhoneInputWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.countryCode,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 24,
            color: Colors.grey.shade300,
          ),
          Expanded(
            child: TextFormField(
              controller: widget.controller,
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                hintText: '9876543210',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                hintStyle: TextStyle(color: Colors.grey),
              ),
              validator: widget.validator,
              onChanged: widget.onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
