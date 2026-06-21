# YourManager

YourManager is a Flutter application designed to help small business owners organise and manage important physical and digital documents.

The application aims to reduce the risk of losing documents, missing important deadlines, and forgetting expiration dates by providing a central place to store, categorise, and manage documents.

## Features

Current features include:

* Upload and store documents from a device
* Manual document categorisation
* Basic automatic categorisation using keyword detection
* Folder organisation
* Document status tracking
* Due date management
* Search and filtering functionality
* Local data persistence using SQLite
* Custom notification tone settings
* Bottom navigation for easy access to different screens

Planned features:

* Camera document scanning
* Advanced automatic categorisation using OCR or AI
* Expiration reminders and notifications
* Cloud synchronisation
* Multi-user support

## Built With

* Flutter
* Dart
* SQLite (`sqflite`)
* File Picker (`file_picker`)
* Open FileX (`open_filex`)
* Path (`path`)

## Getting Started

### Prerequisites

Before running the project, make sure you have installed:

* Flutter SDK
* Dart SDK
* Android Studio or Visual Studio Code
* Android Emulator or a physical Android device

Useful links:

* https://flutter.dev/docs/get-started/install
* https://developer.android.com/studio

### Installation

1. Clone the repository:

```bash
git clone <https://github.com/Risha0503/smart_app.git>
```

2. Navigate to the project directory:

```bash
cd yourmanager
```

3. Install dependencies:

```bash
flutter pub get
```

4. Run the application:

```bash
flutter run
```

## Project Structure

```text
lib/
├── models/
├── screen/
├── services/
├── widgets/
└── main.dart
```

### Main Components

* **Models:** Contains data models such as `AppDocument` and `AppTask`.
* **Screen:** Contains the user interface screens.
* **Services:** Contains business logic and database operations.
* **Main:** Application entry point.

## Database

The application uses SQLite for local data storage.

The `documents` table stores:

* id
* displayName
* category
* folder
* dueDate
* status
* filePath

The application supports CRUD operations:

* Create documents
* Retrieve documents
* Update documents
* Delete documents

## Automatic Categorisation

The application includes a basic automatic categorisation feature.

When a document is uploaded, the application checks the file name for predefined keywords such as:

* invoice
* contract
* insurance
* tax
* warranty

Based on these keywords, the application automatically assigns a category. If no matching keyword is found, users can manually select a category.

## Current Status

This project is currently under active development as part of a Mobile App Development course.

Core functionality for document storage, categorisation, and management has been implemented.

## Known Limitations

* Automatic categorisation is currently rule-based and depends on predefined keywords.
* Cloud synchronisation is not available.
* Camera document scanning is not yet implemented.

## Contributing

If you would like to contribute:

1. Create a new branch:

```bash
git checkout -b feature/your-feature-name
```

2. Commit your changes:

```bash
git commit -m "Describe your changes"
```

3. Push your branch:

```bash
git push origin feature/your-feature-name
```

4. Open a pull request.

## Author

Rishantely Estachia

## License

This project was created for educational purposes.
