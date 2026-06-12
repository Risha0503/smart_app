class AppTask {
  String title;
  String status;
  String assignedTo;

  AppTask({
    required this.title,
    this.status = "To do",
    this.assignedTo = "Unassigned",
  });
}