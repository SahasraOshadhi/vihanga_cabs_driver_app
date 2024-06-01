import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class ImagePickerTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String helperText;
  final Function(String) onImageUploaded;
  final String driverEmail;

  const ImagePickerTextField({
    required this.controller,
    required this.labelText,
    required this.helperText,
    required this.onImageUploaded,
    required this.driverEmail,

  });

  @override
  _ImagePickerTextFieldState createState() => _ImagePickerTextFieldState();
}

class _ImagePickerTextFieldState extends State<ImagePickerTextField> {
  XFile? _imageFile;
  final picker = ImagePicker();
  String imageUrl = '';


  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });

      // Extract file name from the path
      String? fileName = pickedFile.path.split('/').last;

      // URL encode the driver's email to make it safe for use in the path
      String encodedEmail = Uri.encodeComponent(widget.driverEmail);

      //Get a reference to storage root
      Reference referenceRoot = FirebaseStorage.instance.ref();
      Reference referenceDirImages = referenceRoot.child('images').child(encodedEmail);
      
      //Create a reference for the image to be stored
      Reference referenceImageToUpload = referenceDirImages.child(fileName);

      //Handle error/success
      try{
        //Store the file
        await referenceImageToUpload.putFile(File(pickedFile.path));

        //Success: get the download url
        imageUrl = await referenceImageToUpload.getDownloadURL();

        // Call the callback with the imageUrl
        widget.onImageUploaded(imageUrl);

      }catch(error){
        print(error);
      }


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