// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:smart_app/screen/app_document.dart';
import 'package:smart_app/screen/document_screen.dart';

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
    final expiredDocuments = documents.where((doc) {
      return doc.dueDate != null && doc.dueDate!.isBefore(DateTime.now());
    }).length;

    final expiringDocuments = documents.where((doc) {
      if (doc.dueDate == null) return false;

      final difference = doc.dueDate!.difference(DateTime.now()).inDays;
      return difference >= 0 && difference <= 7;
    }).length;

    final inReviewDocuments = documents.where((doc) {
      return doc.category == "Uncategorized" || doc.category == "Other";
    }).length;

    final doneDocuments = documents.where((doc) {
      return doc.category != "Uncategorized" && doc.category != "Other";
    }).length;

    final upcomingDocuments = documents.where((doc) {
      return doc.dueDate != null;
    }).toList();

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
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
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
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "this week",
                          child: Text("this week"),
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
                  count: expiringDocuments,
                  icon: Icons.warning,
                  iconColor: Colors.red,
                  backgroundColor: const Color(0xFFFFDD8D),
                ),
                overviewCard(
                  title: "Expired",
                  count: expiredDocuments,
                  icon: Icons.error,
                  iconColor: Colors.red,
                  backgroundColor: const Color(0xFFFF9E9E),
                ),
                overviewCard(
                  title: "in review",
                  count: inReviewDocuments,
                  icon: Icons.description,
                  iconColor: const Color(0xFF003366),
                  backgroundColor: const Color(0xFFA9C9FF),
                ),
                overviewCard(
                  title: "Done",
                  count: doneDocuments,
                  icon: Icons.check_circle,
                  iconColor: const Color(0xFF003366),
                  backgroundColor: const Color(0xFFC6F3D6),
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

            sectionHeader("Tasks"),

            const SizedBox(height: 12),

            documents.isEmpty
                ? emptyCard("No tasks yet")
                : Column(
                    children: documents.take(3).map((doc) {
                      return taskCard(doc);
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
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
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
    );
  }

  Widget sectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            minimumSize: const Size(0, 34),
          ),
          child: const Row(
            children: [
              Text("See all", style: TextStyle(fontSize: 12)),
              SizedBox(width: 4),
              Icon(Icons.chevron_right, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget deadlineCard(AppDocument document) {
    return Container(
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
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget taskCard(AppDocument document) {
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
            child: Text(
              document.displayName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFF003366),
            child: Icon(Icons.person, color: Colors.white, size: 16),
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