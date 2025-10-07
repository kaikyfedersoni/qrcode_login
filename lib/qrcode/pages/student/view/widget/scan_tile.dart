import 'package:flutter/material.dart';

class ScanTile extends StatelessWidget {
  final String title;
  final DateTime? timestamp;
  final VoidCallback onTap;

  const ScanTile({
    super.key,
    required this.title,
    required this.timestamp,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateText = timestamp != null
        ? "${timestamp!.day}/${timestamp!.month}/${timestamp!.year} - ${timestamp!.hour}:${timestamp!.minute.toString().padLeft(2, '0')}"
        : "Sem data";


    return ListTile(
    title: Text(title),
    subtitle: Text(dateText),
    trailing: const Icon(Icons.arrow_forward_ios),
    onTap: onTap,
    );


  }
}
