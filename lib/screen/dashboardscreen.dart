// ignore: file_names
// ignore: file_names
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';


class DashboardScreen extends StatefulWidget{
  const DashboardScreen({super.key, required this.title});
  final String title;

  @override

  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>{ 
  int selectedIndex = 0;
  String selectedDepartment = "Finance";

List<String> departments = [
  "Finance",
  "HR",
  "Marketing",
  "Management",
];
Future<void> pickDocument() async { //async function means that it will return a Future, which is a way to handle asynchronous operations in Dart. The function will perform some asynchronous work (in this case, picking a file) and will eventually complete with a result (the picked file) or an error.
  final result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
  );

  if (result != null) {
    PlatformFile file = result.files.first;

    print("File name: ${file.name}");
    print("File path: ${file.path}");
  } else {
    print("User canceled picker");
  }
}


@override
Widget build(BuildContext context){
  return Scaffold(
    appBar: PreferredSize(
      preferredSize: const Size.fromHeight(80),
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
            Container(
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
                  style: const TextStyle(color: Colors.white, fontSize: 12),
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
floatingActionButton: FloatingActionButton(
  backgroundColor: const Color(0xFF003366),
  onPressed: pickDocument,
  child: const Icon(Icons.add, color: Colors.white),
),
floatingActionButtonLocation:
    FloatingActionButtonLocation.centerDocked,

    body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,

            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), //this is the padding inside the search bar
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 163, 162, 162), //this is the background color of the container
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search for tasks, people, or documents',//this is the hint text in the search bar
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    backgroundColor: const Color.fromARGB(255, 250, 251, 252),//this is the background color of the app
    bottomNavigationBar: BottomNavigationBar(
      onTap: (index){
        setState(() {
          selectedIndex = index;
        });
      },
      currentIndex: selectedIndex,
      backgroundColor:  const Color.fromARGB(131, 119, 118, 118),
      //this is the background color of the bottom navigation bar
      iconSize: 24,
      selectedItemColor: const Color.fromARGB(255, 219, 91, 59), //this is the color of the icons in the bottom navigation bar
      unselectedItemColor: const Color.fromARGB(240, 0, 0, 0), //this is the color of the text in the bottom navigation bar
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Schedule"),
        BottomNavigationBarItem(icon: Icon(Icons.folder), label: "documents"),
        BottomNavigationBarItem(icon: Icon(Icons.menu), label: "menu"),
      ],
    ),
  );
    }
}

