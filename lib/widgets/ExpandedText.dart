import 'package:flutter/material.dart';

//TODO: Add this to GITHUB components
class ExpandableText extends StatefulWidget {
  final String text;
  final int trimLines;

  ExpandableText({required this.text, this.trimLines = 4});

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Use the "maxLines" property for truncation
        Text(
          widget.text,
          maxLines: _isExpanded ? null : widget.trimLines,
          overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
        widget.trimLines < 4
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Text(
                  _isExpanded ? 'See less' : 'See more',
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
              )
            : Container(),
      ],
    );
  }
}
