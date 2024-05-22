import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class ImagePickerTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String helperText;

  const ImagePickerTextField({
    required this.controller,
    required this.labelText,
    required this.helperText
  });

  @override
  _ImagePickerTextFieldState createState() => _ImagePickerTextFieldState();
}

class _ImagePickerTextFieldState extends State<ImagePickerTextField> {
  XFile? _imageFile;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });

      // Extract file name from the path
      String? fileName = pickedFile.path.split('/').last;

      // Update the text field with the file name
      widget.controller.text = fileName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: widget.controller,
            decoration: InputDecoration(
              labelText: widget.labelText,
              labelStyle: TextStyle(
                fontSize: 14,
              ),
              hintText: _imageFile == null ? 'Select an image' : _imageFile!.path,
              helperText: widget.helperText,
              helperStyle: TextStyle(color: Colors.grey.withOpacity(0.7)),
            ),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 15,
            ),
            readOnly: true,
          ),
        ),
        IconButton(
          icon: Icon(Icons.camera_alt),
          onPressed: _pickImage,
        ),
      ],
    );
  }
}