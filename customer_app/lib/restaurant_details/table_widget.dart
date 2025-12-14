import 'package:flutter/material.dart';

class TableWidget extends StatelessWidget {
  final int tableNumber;
  final bool isSelected;
  final bool isBooked;
  final VoidCallback? onTap;

  const TableWidget({
    required this.tableNumber,
    required this.isSelected,
    required this.isBooked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color color;

    if (isBooked) {
      color = Colors.grey;
    } else if (isSelected) {
      color = Colors.blue;
    } else {
      color = Colors.green;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'Table $tableNumber',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
