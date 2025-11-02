# Chat App

A modern Flutter chat application with real-time messaging, voice messages, and friend management features. Built with Firebase backend and clean architecture principles.

## Features

### 🔐 Authentication
- Phone number-based authentication using OTP verification
- Secure session management with persistent login
- User-friendly login and verification flow

### 👥 Friends Management
- Search and discover users
- Send, accept, and reject friend requests
- View all users and manage friend list
- Real-time friend request updates

### 💬 Chat Features
- Real-time text messaging
- Voice message recording and playback
- Audio waveform visualization
- Image sharing support
- Clean and intuitive chat interface

## Tech Stack

### Framework & Language
- **Flutter** (SDK ^3.9.2)
- **Dart**

### State Management
- **flutter_bloc** - BLoC pattern for state management
- **get** - Additional state management utilities

### Backend Services
- **Firebase Auth** - Authentication and OTP verification
- **Cloud Firestore** - Real-time database for messages and user data
- **Firebase Storage** - File storage for voice messages and images

### Key Dependencies
- **go_router** - Declarative routing and navigation
- **image_picker** - Image selection from gallery/camera
- **record** - Audio recording capabilities
- **audio_waveforms** - Audio visualization
- **just_audio** - Audio playback
- **cached_network_image** - Efficient image caching
- **permission_handler** - Handle runtime permissions
- **get_it** - Dependency injection
- **shared_preferences** - Local data persistence
- **dartz** - Functional programming utilities
- **equatable** - Value equality comparisons

## Architecture

This project follows **Clean Architecture** principles with a clear separation of concerns:

```
lib/
├── features/
│   ├── auth/          # Authentication feature
│   ├── chat/          # Chat messaging feature
│   └── friends/       # Friends management feature
│
└── Each feature follows:
    ├── data/          # Data layer
    │   ├── datasources/    # Remote/local data sources
    │   ├── models/         # Data models
    │   ├── repositories/   # Repository implementations
    │   └── services/       # Data services
    │
    ├── domain/        # Domain layer (Business logic)
    │   ├── entities/       # Business entities
    │   ├── repositories/   # Repository interfaces
    │   ├── services/       # Domain services
    │   └── usecases/       # Use cases
    │
    └── presentation/   # Presentation layer
        ├── bloc/          # BLoC state management
        ├── controllers/   # View controllers
        ├── views/         # UI screens
        └── widgets/       # Reusable widgets
```

### State Management Pattern
- **BLoC (Business Logic Component)** pattern is used throughout the app
- Three main BLoCs:
  - `AuthBloc` - Handles authentication state
  - `ChatBloc` - Manages chat messages and voice recordings
  - `FriendsBloc` - Controls friends and friend requests

## Prerequisites

Before you begin, ensure you have the following installed:
- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Firebase CLI (optional, for Firebase setup)
- A Firebase project with the following services enabled:
  - Authentication (Phone auth enabled)
  - Cloud Firestore
  - Firebase Storage

## Setup Instructions

### 1. Clone the Repository
```bash
git clone <repository-url>
cd chat_app
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Configuration

#### For Android:
1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/` directory
3. The project already includes a `google-services.json` file

#### For iOS:
1. Download `GoogleService-Info.plist` from Firebase Console
2. Place it in `ios/Runner/` directory

#### Firebase Configuration in Code:
The Firebase configuration is initialized in `lib/main.dart` with:
```dart
FirebaseOptions(
  apiKey: "YOUR_API_KEY",
  appId: "YOUR_APP_ID",
  messagingSenderId: "YOUR_SENDER_ID",
  projectId: "YOUR_PROJECT_ID",
)
```

**Note:** Replace the hardcoded Firebase configuration with environment variables or a configuration file for production use.

### 4. Enable Phone Authentication in Firebase
1. Go to Firebase Console → Authentication → Sign-in method
2. Enable Phone authentication
3. Configure your app's SHA-1 certificate for Android (if needed)

### 5. Configure Firestore Database
1. Create a Firestore database in Firebase Console
2. Set up security rules (start with test mode for development)

### 6. Configure Firebase Storage
1. Enable Firebase Storage in Firebase Console
2. Set up storage rules (start with test mode for development)

### 7. Run the App
```bash
# For Android
flutter run

# For iOS
flutter run

# For web
flutter run -d chrome
```

## Project Structure

```
chat_app/
├── android/              # Android-specific files
├── ios/                  # iOS-specific files
├── lib/
│   ├── features/         # Feature modules
│   │   ├── auth/         # Authentication feature
│   │   ├── chat/         # Chat feature
│   │   └── friends/      # Friends feature
│   ├── main.dart         # App entry point
│   ├── router.dart       # Navigation configuration
│   └── dependencies.dart # Dependency injection setup
├── assets/               # Assets (images, fonts, etc.)
├── pubspec.yaml          # Project dependencies
└── README.md            # This file
```

## Key Features Implementation

### Authentication Flow
1. User enters phone number
2. OTP is sent via Firebase Auth
3. User verifies OTP
4. Session is stored and user is authenticated

### Friends System
- Users can search for other users
- Send friend requests
- Accept/reject incoming requests
- View friends list

### Chat System
- Real-time message synchronization via Firestore
- Voice messages with recording and playback
- Image sharing support
- Audio waveform visualization

## Development Guidelines

### Adding a New Feature
1. Create feature folder in `lib/features/`
2. Follow the clean architecture structure:
   - `data/` - Data sources, models, repositories
   - `domain/` - Entities, use cases, repository interfaces
   - `presentation/` - BLoC, views, widgets
3. Register dependencies in `lib/dependencies.dart`
4. Add routes in `lib/router.dart`

### Code Style
- Follow Flutter/Dart style guide
- Use meaningful variable and function names
- Add comments for complex logic
- Keep widgets small and reusable

## Build Commands

```bash
# Build APK
flutter build apk

# Build iOS
flutter build ios

# Build Web
flutter build web

# Run tests
flutter test
```

## Troubleshooting

### Firebase Issues
- Ensure `google-services.json` is properly placed
- Verify Firebase project settings
- Check if phone authentication is enabled

### Permission Issues
- Grant microphone permission for voice messages
- Grant storage permission for images
- Check platform-specific permission settings

### Build Issues
```bash
# Clean build
flutter clean
flutter pub get

# Update dependencies
flutter pub upgrade
```

## Future Enhancements

Potential features to add:
- Push notifications
- Group chats
- Message status indicators (sent, delivered, read)
- Typing indicators
- Message reactions
- End-to-end encryption
- File sharing
- User presence status

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License.

## Contact

For questions or support, please open an issue in the repository.

---

**Note:** This is a development project. For production use, ensure:
- Secure Firebase configuration management
- Proper security rules for Firestore and Storage
- Error handling and logging
- Performance optimization
- Comprehensive testing

