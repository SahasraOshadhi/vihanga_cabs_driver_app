import 'package:flutter/material.dart';

class YearPickerTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;

  const YearPickerTextField({
    Key? key,
    required this.controller,
    required this.labelText,
  }) : super(key: key);

  @override
  _YearPickerTextFieldState createState() => _YearPickerTextFieldState();
}

class _YearPickerTextFieldState extends State<YearPickerTextField> {
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.controller.text.isNotEmpty
        ? int.tryParse(widget.controller.text) ?? DateTime.now().year
        : DateTime.now().year;
  }

  Future<void> _selectYear() async {
    final int? pickedYear = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select ${widget.labelText}'),
          content: SizedBox(
            width: 200.0,
            child: ListView.builder(
              itemCount: 101, // 100 years from the past + current year
              itemBuilder: (BuildContext context, int index) {
                final year = DateTime.now().year - index;
                return ListTile(
                  title: Text(year.toString()),
                  onTap: () {
                    Navigator.of(context).pop(year);
                  },
                );
              },
            ),
          ),
        );
      },
    );
    if (pickedYear != null) {
      setState(() {
        _selectedYear = pickedYear;
        widget.controller.text = pickedYear.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: TextStyle(
          fontSize: 14,
        ),
      ),
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 15,
      ),
      readOnly: true,
      onTap: _selectYear,
    );
  }
}
