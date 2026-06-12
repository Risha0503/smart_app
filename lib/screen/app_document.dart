import 'package:file_picker/file_picker.dart';

class AppDocument {
  final PlatformFile file;
  String displayName;
  String category;
  String folder;
  DateTime? dueDate;
  String status;

  AppDocument({
    required this.file,
    required this.displayName,
    required this.category,
    this.folder = "General",
    this.dueDate,
    this.status = "No Status",
  });
}