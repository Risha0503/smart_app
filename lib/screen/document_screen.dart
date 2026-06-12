import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:smart_app/screen/app_document.dart';

class DocumentScreen extends StatefulWidget {
  final List<AppDocument> documents;

  const DocumentScreen({
    super.key,
    required this.documents,
  });

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  String filter = "All";

  final List<String> filters = [
    "All",
    "Expiring Soon",
    "Expired",
    "No Status",
    "In Review",
    "Done",
  ];

  Future<void> renameDocument(AppDocument document) async {
    final controller = TextEditingController(text: document.displayName);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Rename document"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: "Document name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text("Save"),
            ),
          ],
        );
      },
    );

    if (newName != null && newName.trim().isNotEmpty) {
      setState(() {
        document.displayName = newName.trim();
      });
    }
  }

  Future<void> changeCategory(AppDocument document) async {
    final categories = [
      "Invoices",
      "Contracts",
      "Insurances",
      "Taxes",
      "Warranties",
      "Other",
    ];

    final selectedCategory = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Change category"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: categories.map((category) {
              return ListTile(
                title: Text(category),
                onTap: () => Navigator.pop(context, category),
              );
            }).toList(),
          ),
        );
      },
    );

    if (selectedCategory != null) {
      setState(() {
        document.category = selectedCategory;
      });
    }
  }

  Future<void> changeFolder(AppDocument document) async {
    final controller = TextEditingController(text: document.folder);

    final folderName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add to folder"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: "Folder name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text("Save"),
            ),
          ],
        );
      },
    );

    if (folderName != null && folderName.trim().isNotEmpty) {
      setState(() {
        document.folder = folderName.trim();
      });
    }
  }

  Future<void> assignDueDate(AppDocument document) async {
    final selectedDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      initialDate: document.dueDate ?? DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        document.dueDate = selectedDate;
      });
    }
  }

  Future<void> changeStatus(AppDocument document) async {
    final statuses = [
      "In Review",
      "Done",
      "No Status",
      "Expired",
      "Expiring Soon",
    ];

    final selectedStatus = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Change status"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: statuses.map((status) {
              return ListTile(
                title: Text(status),
                onTap: () => Navigator.pop(context, status),
              );
            }).toList(),
          ),
        );
      },
    );

    if (selectedStatus != null) {
      setState(() {
        document.status = selectedStatus;
      });
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return "No due date";
    return "${date.day}-${date.month}-${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE6E6E6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search for folder or documents',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                const Text(
                  'Folders',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                DropdownButton<String>(
                  value: filter,
                  items: filters.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      filter = newValue!;
                    });
                  },
                ),
              ],
            ),

            Text(
              'Filtered by: $filter',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.folder),
                  SizedBox(width: 12),
                  Text(
                    "Documents",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Added files",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            widget.documents.isEmpty
                ? const Text("No files added yet")
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.documents.length,
                    itemBuilder: (context, index) {
                      final document = widget.documents[index];

                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.description),
                          title: Text(document.displayName),
                          subtitle: Text(
                            "Category: ${document.category}\n"
                            "Folder: ${document.folder}\n"
                            "Status: ${document.status}\n"
                            "Due: ${formatDate(document.dueDate)}",
                          ),
                          isThreeLine: false,
                          onTap: () {
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
                          },
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == "rename") {
                                renameDocument(document);
                              } else if (value == "category") {
                                changeCategory(document);
                              } else if (value == "folder") {
                                changeFolder(document);
                              } else if (value == "dueDate") {
                                assignDueDate(document);
                              } else if (value == "status") {
                                changeStatus(document);
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: "rename",
                                child: Text("Rename"),
                              ),
                              PopupMenuItem(
                                value: "category",
                                child: Text("Change category"),
                              ),
                              PopupMenuItem(
                                value: "folder",
                                child: Text("Add to folder"),
                              ),
                              PopupMenuItem(
                                value: "dueDate",
                                child: Text("Assign due date"),
                              ),
                              PopupMenuItem(
                                value: "status",
                                child: Text("Change status"),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}