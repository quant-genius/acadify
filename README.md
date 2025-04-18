
# Acadify - Campus Connect

Acadify is a secure, structured, and centralized platform for university academic communications and operations. It replaces informal WhatsApp groups with a purpose-built system tailored to the needs of students, lecturers, and class representatives.

## Features

- **Centralized Communication**: All academic activities—meetings, assignments, discussions, announcements—in one digital hub, organized by course or unit groups.
- **Structured Environment**: Clear content categories and moderation capabilities for lecturers and class representatives.
- **Enhanced Privacy**: Conversations and content are private to group members, with end-to-end encryption protecting sensitive exchanges.
- **Robust User Verification**: Only verified users can join groups, with roles dictating permissions.
- **Cross-Platform**: The app works consistently on Android and web platforms, adapting to various devices.
- **Real-Time Communication**: Instant updates for new posts, messages, or deadlines.
- **Institutional Integration**: Syncs with university databases for user verification and group creation.
- **Advanced Content Management**: Content is searchable and archived for easy retrieval.
- **Scalable Architecture**: Supports thousands of users and groups without performance loss.
- **Intuitive Interface**: User-friendly and tailored to academic tasks.

## Architecture

Acadify follows a clean architecture approach with clear separation of concerns:

- **Core Layer**: Houses utilities like authentication, API services, and Firestore integration.
- **Features Layer**: Splits the app into modules (auth, groups, discussions, etc.), each with data, domain, and UI components.
- **Shared Layer**: Provides reusable widgets and state management.

## Getting Started

### Prerequisites

- Flutter (latest stable version)
- Firebase account and project set up
- Dart SDK

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/acadify.git
   ```

2. Navigate to the project directory:
   ```
   cd acadify
   ```

3. Install dependencies:
   ```
   flutter pub get
   ```

4. Configure Firebase:
   - Create a Firebase project
   - Add Android and Web apps to your Firebase project
   - Download and add the configuration files
   - Enable Authentication, Firestore, and Storage services

5. Run the app:
   ```
   flutter run
   ```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

For any inquiries, please reach out to the development team at dev@acadify.com.
