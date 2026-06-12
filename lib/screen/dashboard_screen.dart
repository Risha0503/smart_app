// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:smart_app/screen/app_document.dart';
import 'package:smart_app/models/app_tasks.dart';
import 'package:smart_app/screen/document_screen.dart';
import 'package:smart_app/screen/document_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.title});

  final String title;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;
  String selectedDepartment = "Finance";

  final List<String> departments = [
    "Finance",
    "HR",
    "Marketing",
    "Management",
  ];

  final List<AppDocument> documents = [];
  final List<AppTask> tasks = [];

  String autoCategorize(String fileName) {
    final name = fileName.toLowerCase();

    if (name.contains("invoice") || name.contains("factuur")) {
      return "Invoices";
    } else if (name.contains("contract")) {
      return "Contracts";
    } else if (name.contains("insurance") || name.contains("verzekering")) {
      return "Insurances";
    } else if (name.contains("tax") || name.contains("belasting")) {
      return "Taxes";
    } else if (name.contains("warranty") || name.contains("garantie")) {
      return "Warranties";
    } else {
      return "Uncategorized";
    }
  }

  Future<String?> askUserForCategory() async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Choose category"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              categoryOption("Invoices"),
              categoryOption("Contracts"),
              categoryOption("Insurances"),
              categoryOption("Taxes"),
              categoryOption("Warranties"),
              categoryOption("Other"),
            ],
          ),
        );
      },
    );
  }

  Widget categoryOption(String category) {
    return ListTile(
      title: Text(category),
      onTap: () {
        Navigator.pop(context, category);
      },
    );
  }

  Future<void> pickDocument() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
      allowMultiple: true,
    );

    if (result != null) {
      for (final file in result.files) {
        String category = autoCategorize(file.name);

        if (category == "Uncategorized") {
          category = await askUserForCategory() ?? "Other";
        }

        setState(() {
          documents.add(
            AppDocument(
              file: file,
              displayName: file.name,
              category: category,
            ),
          );
        });
      }
    }
  }

  Future<void> createTask() async {
    final titleController = TextEditingController();
    final assignedController = TextEditingController();

    final newTask = await showDialog<AppTask>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Create task"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Task title"),
              ),
              TextField(
                controller: assignedController,
                decoration: const InputDecoration(labelText: "Assigned to"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;

                Navigator.pop(
                  context,
                  AppTask(
                    title: titleController.text.trim(),
                    assignedTo: assignedController.text.trim().isEmpty
                        ? "Unassigned"
                        : assignedController.text.trim(),
                  ),
                );
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );

    if (newTask != null) {
      setState(() {
        tasks.add(newTask);
      });
    }
  }

  void openDocumentList(String title, List<AppDocument> filteredDocuments) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return DocumentListScreen(
            title: title,
            documents: filteredDocuments,
          );
        },
      ),
    );
  }

  Widget getSelectedPage() {
    if (selectedIndex == 0) {
      return buildHomeScreen();
    } else if (selectedIndex == 1) {
      return const Center(child: Text("Calendar"));
    } else if (selectedIndex == 2) {
      return DocumentScreen(documents: documents);
    } else {
      return const Center(child: Text("Menu"));
    }
  }

  Widget buildHomeScreen() {
    final now = DateTime.now();

    final expiredList = documents.where((doc) {
      return doc.dueDate != null && doc.dueDate!.isBefore(now);
    }).toList();

    final expiringList = documents.where((doc) {
      if (doc.dueDate == null) return false;
      final difference = doc.dueDate!.difference(now).inDays;
      return difference >= 0 && difference <= 7;
    }).toList();

    final noStatusList = documents.where((doc) {
      return doc.status == "No Status";
    }).toList();

    final doneList = documents.where((doc) {
      return doc.status == "Done";
    }).toList();

    final inReviewList = documents.where((doc) {
      return doc.status == "In Review";
    }).toList();

    final upcomingDocuments = expiringList;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            searchBar(),
            const SizedBox(height: 24),

            Row(
              children: [
                const Text(
                  "Overview",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: "this week",
                      style: const TextStyle(color: Colors.black, fontSize: 12),
                      items: const [
                        DropdownMenuItem(
                          value: "this week",
                          child: Text("this week"),
                        ),
                        DropdownMenuItem(
                          value: "this month",
                          child: Text("this month"),
                        ),
                        DropdownMenuItem(
                          value: "this year",
                          child: Text("this year"),
                        ),
                      ],
                      onChanged: (value) {},
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.45,
              children: [
                overviewCard(
                  title: "Expiring",
                  count: expiringList.length,
                  icon: Icons.warning,
                  iconColor: Colors.red,
                  backgroundColor: const Color(0xFFFFDD8D),
                  onTap: () {
                    openDocumentList("Expiring Documents", expiringList);
                  },
                ),
                overviewCard(
                  title: "Expired",
                  count: expiredList.length,
                  icon: Icons.error,
                  iconColor: Colors.red,
                  backgroundColor: const Color(0xFFFF9E9E),
                  onTap: () {
                    openDocumentList("Expired Documents", expiredList);
                  },
                ),
                overviewCard(
                  title: "In Review",
                  count: inReviewList.length,
                  icon: Icons.description,
                  iconColor: const Color(0xFF003366),
                  backgroundColor: const Color(0xFFA9C9FF),
                  onTap: () {
                    openDocumentList("In Review Documents", inReviewList);
                  },
                ),
                overviewCard(
                  title: "Done",
                  count: doneList.length,
                  icon: Icons.check_circle,
                  iconColor: const Color(0xFF003366),
                  backgroundColor: const Color(0xFFC6F3D6),
                  onTap: () {
                    openDocumentList("Done Documents", doneList);
                  },
                ),
                overviewCard(
                  title: "No Status",
                  count: noStatusList.length,
                  icon: Icons.description,
                  iconColor: const Color(0xFF003366),
                  backgroundColor: const Color(0xFFA9C9FF),
                  onTap: () {
                    openDocumentList("No Status Documents", noStatusList);
                  },
                ),
              ],
            ),

            const SizedBox(height: 28),

            sectionHeader("Upcoming deadlines"),

            const SizedBox(height: 12),

            upcomingDocuments.isEmpty
                ? emptyCard("No upcoming deadlines yet")
                : Column(
                    children: upcomingDocuments.take(3).map((doc) {
                      return deadlineCard(doc);
                    }).toList(),
                  ),

            const SizedBox(height: 28),

            sectionHeader("Tasks", onPressed: createTask),

            const SizedBox(height: 12),

            tasks.isEmpty
                ? emptyCard("No tasks assigned yet")
                : Column(
                    children: tasks.take(3).map((task) {
                      return taskCard(task);
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget searchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'search for documents, people, tasks, etc...',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget overviewCard({
    required String title,
    required int count,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const Positioned(
              top: 0,
              right: 0,
              child: Icon(Icons.chevron_right, size: 22),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    count.toString(),
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget sectionHeader(String title, {VoidCallback? onPressed}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            minimumSize: const Size(0, 34),
          ),
          child: Row(
            children: [
              Text(
                onPressed == null ? "See all" : "Add",
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 4),
              Icon(
                onPressed == null ? Icons.chevron_right : Icons.add,
                size: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget deadlineCard(AppDocument document) {
    return InkWell(
      onTap: () {
        openDocumentList("Upcoming Deadline", [document]);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.redAccent),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.displayName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Expires ${formatDate(document.dueDate)}",
                    style: const TextStyle(color: Colors.red, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget taskCard(AppTask task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.assignment, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  task.status,
                  style: const TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFF003366),
            child: Text(
              task.assignedTo.isEmpty
                  ? "?"
                  : task.assignedTo[0].toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget emptyCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text),
    );
  }

  String formatDate(DateTime? date) {
    if (date == null) return "No date";
    return "${date.day}-${date.month}-${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(85),
        child: Container(
          color: const Color(0xFF003366),
          padding: const EdgeInsets.only(top: 35, left: 16, right: 16),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Department",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 34,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedDepartment,
                        dropdownColor: const Color(0xFF003366),
                        iconEnabledColor: Colors.white,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        items: departments.map((String department) {
                          return DropdownMenuItem<String>(
                            value: department,
                            child: Text(department),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedDepartment = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Text(
                "YourManager",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications),
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ),
      body: getSelectedPage(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF003366),
        onPressed: pickDocument,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      backgroundColor: const Color(0xFFFAFBFC),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        currentIndex: selectedIndex,
        iconSize: 24,
        selectedItemColor: const Color(0xFFDB5B3B),
        unselectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Calendar",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: "Folders",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: "Menu"),
        ],
      ),
    );
  }
}