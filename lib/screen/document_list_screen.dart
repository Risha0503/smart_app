import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:smart_app/screen/app_document.dart';

class DocumentListScreen extends StatelessWidget {
  final String title;
  final List<AppDocument> documents;

  const DocumentListScreen({
    super.key,
    required this.title,
    required this.documents,
  });

  String formatDate(DateTime? date) {
    if (date == null) return "No due date";
    return "${date.day}-${date.month}-${date.year}";
  }

  void openDocument(BuildContext context, AppDocument document) {
    final path = document.file.path;

    if (path != null) {
      OpenFilex.open(path);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Could not open this file"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF003366),
        foregroundColor: Colors.white,
      ),
      body: documents.isEmpty
          ? const Center(
              child: Text("No documents found"),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final document = documents[index];

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.description),
                    title: Text(document.displayName),
                    subtitle: Text(
                      "Category: ${document.category}\n"
                      "Status: ${document.status}\n"
                      "Due: ${formatDate(document.dueDate)}",
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () {
                      openDocument(context, document);
                    },
                  ),
                );
              },
            ),
    );
  }
}