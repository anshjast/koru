import 'package:flutter/material.dart';

enum ConfirmAction { done, delete }

class ConfirmActionToggle extends StatefulWidget {
  final VoidCallback onDoneConfirmed;
  final VoidCallback onDeleteConfirmed;

  const ConfirmActionToggle({
    super.key,
    required this.onDoneConfirmed,
    required this.onDeleteConfirmed,
  });

  @override
  State<ConfirmActionToggle> createState() => _ConfirmActionToggleState();
}

class _ConfirmActionToggleState extends State<ConfirmActionToggle> {
  ConfirmAction? _confirming;

  void _handleTap(ConfirmAction action) {
    if (_confirming == action) {
      if (action == ConfirmAction.done) {
        widget.onDoneConfirmed();
      } else {
        widget.onDeleteConfirmed();
      }
    } else {
      setState(() {
        _confirming = action;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 150,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        border: Border.all(color: Colors.grey[800]!, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _handleTap(ConfirmAction.done),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: _confirming == ConfirmAction.done
                      ? Colors.green.shade700
                      : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(7),
                    bottomLeft: Radius.circular(7),
                  ),
                ),
                child: Center(
                  child: Text(
                    _confirming == ConfirmAction.done ? "Confirm?" : "Done",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _confirming == ConfirmAction.done
                          ? Colors.white
                          : Colors.greenAccent,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Delete button
          Expanded(
            child: GestureDetector(
              onTap: () => _handleTap(ConfirmAction.delete),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: _confirming == ConfirmAction.delete
                      ? Colors.red.shade700
                      : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(7),
                    bottomRight: Radius.circular(7),
                  ),
                ),
                child: Center(
                  child: Text(
                    _confirming == ConfirmAction.delete ? "Confirm?" : "Delete",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _confirming == ConfirmAction.delete
                          ? Colors.white
                          : Colors.redAccent,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}