import 'package:flutter/material.dart';
import 'package:expense_tracker/models/noteModel.dart';
import 'package:expense_tracker/widgets/notesWidgets.dart';
import 'package:expense_tracker/constants.dart';

class NotesTab extends StatefulWidget {
  final List<Note> notes;
  final Future<void> Function() onRefresh;
  final DateTime selectedDate;
  const NotesTab({required this.notes, required this.onRefresh, required this.selectedDate, super.key});

  @override
  State<NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<NotesTab> {
  @override
  Widget build(BuildContext context) {
    List<Note> notes = widget.notes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        // Notes List
        if (notes.isNotEmpty)
          ...List.generate(
            notes.length,
            (index) {
              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 300 + (index * 50)),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => NotesWidgets(widget.onRefresh, context)
                          .editNoteSheet(notes[index]),
                      child: NotesWidgets(widget.onRefresh, context)
                          .noteCard(notes[index]),
                    ),
                  ),
                ),
              );
            },
          ),
        if (notes.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.note_add_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "No Notes Yet",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tap the + button to add your first note",
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 100),
      ],
    );
  }
}

