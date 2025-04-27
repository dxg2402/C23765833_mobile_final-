import 'package:flutter/material.dart';

class LocationSearchBar extends StatefulWidget {
  final Function(String) onSearch;

  const LocationSearchBar({required this.onSearch, super.key});

  @override
  _LocationSearchBarState createState() => _LocationSearchBarState();
}

class _LocationSearchBarState extends State<LocationSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: 'Enter Location',
        border: OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            widget.onSearch(_controller.text);
          },
        ),
      ),
    );
  }
}
