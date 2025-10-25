# Chat App

A modern Flutter chat application with real-time messaging, voice messages, and friend management features.

## 📱 Features

### 🔐 Authentication
- **Phone Number Authentication**: Secure OTP-based login using Firebase Auth
- **OTP Verification**: SMS-based verification system
- **User Profile Management**: Store and manage user information

### 💬 Chat Features
- **Real-time Messaging**: Instant text messaging with Firebase Firestore
- **Voice Messages**: Record and send voice messages with audio playback
- **Message History**: Persistent chat history with timestamps
- **Audio Player**: Advanced audio player with play/pause/stop controls
- **Real-time Updates**: Live message synchronization across devices

### 👥 Friends Management
- **Friend Requests**: Send and receive friend requests
- **Friends List**: View and manage your friends
- **User Discovery**: Find and connect with other users
- **Request Management**: Accept or reject friend requests
- **Deduplication**: Prevents duplicate friends and users

### 🎨 User Interface
- **Modern Design**: Clean and intuitive Material Design
- **Responsive Layout**: Optimized for different screen sizes
- **Real-time Updates**: Live data synchronization
- **Loading States**: Proper loading indicators and error handling

## 🏗️ Architecture

The app follows Clean Architecture principles with clear separation of concerns:

### 📁 Project Structure
```
lib/
├── features/
│   ├── auth/                    # Authentication feature
│   │   ├── data/
│   │   │   ├── datasources/     # Remote data sources
│   │   │   ├── models/          # Data models
│   │   │   └── repositories/   # Repository implementations
│   │   ├── domain/
│   │   │   ├── entities/        # Business entities
│   │   │   ├── repositories/    # Repository interfaces
│   │   │   └── usecases/        # Business logic use cases
│   │   └── presentation/
│   │       ├── bloc/            # State management
│   │       ├── controllers/     # Business logic controllers
│   │       ├── widgets/         # Reusable UI components
│   │       └── views/           # UI screens
│   ├── chat/                    # Chat feature
│   └── friends/                 # Friends management feature
├── dependencies.dart            # Dependency injection
└── main.dart                    # App entry point
```

### 🔧 Key Components

#### **Controllers**
- **AuthController**: Handles authentication business logic
- **ChatController**: Manages chat operations and state
- **Separation of Concerns**: UI and business logic are completely separated

#### **Services**
- **UserService**: Cached user data management
- **AudioPlayerService**: Advanced audio playback management
- **FirebaseServices**: Real-time data synchronization

#### **State Management**
- **BLoC Pattern**: Clean state management with flutter_bloc
- **Real-time Streams**: Live data updates with Firestore streams
- **Error Handling**: Comprehensive error states and user feedback

## 🚀 Setup Instructions

### Prerequisites
- **Flutter SDK**: Version 3.0.0 or higher
- **Dart SDK**: Version 3.0.0 or higher
- **Firebase Project**: Configured with Authentication and Firestore
- **Android Studio** or **VS Code** with Flutter extensions

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

#### Android Setup
1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/` directory
3. Ensure the file is properly configured in `android/app/build.gradle`

#### iOS Setup
1. Download `GoogleService-Info.plist` from Firebase Console
2. Add it to `ios/Runner/` directory in Xcode
3. Ensure it's added to the Xcode project

### 4. Firebase Services Configuration

#### Authentication
- Enable **Phone Authentication** in Firebase Console
- Configure **SMS providers** (Twilio, etc.)
- Set up **App verification** for testing

#### Firestore Database
- Create Firestore database in **production mode**
- Set up security rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /chats/{chatId}/messages/{messageId} {
      allow read, write: if request.auth != null;
    }
    match /friends/{friendId} {
      allow read, write: if request.auth != null;
    }
    match /friend_requests/{requestId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 5. Environment Configuration
Create a `.env` file in the root directory:
```env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_API_KEY=your-api-key
```

## 🏃‍♂️ Running the App

### Debug Mode
```bash
flutter run
```

### Release Mode
```bash
flutter run --release
```

### Build APK
```bash
flutter build apk --release
```

### Build iOS
```bash
flutter build ios --release
```

## 📱 App Screens

### 🔐 Authentication Flow
1. **Login Screen**: Phone number input with country code
2. **OTP Verification**: SMS code verification
3. **Profile Setup**: User information collection

### 👥 Friends Management
1. **Friends Tab**: List of current friends with chat options
2. **Requests Tab**: Pending friend requests with accept/reject actions
3. **All Users Tab**: Discover and send friend requests to other users
4. **Search Users**: Find users by phone number

### 💬 Chat Interface
1. **Chat List**: Conversations with friends
2. **Message Interface**: Text and voice message composition
3. **Audio Player**: Advanced voice message playback
4. **Real-time Updates**: Live message synchronization

## 🎨 UI Components

### **Reusable Widgets**
- **PhoneInputWidget**: Country code and phone number input
- **AuthButtonWidget**: Consistent authentication buttons
- **AudioMessageWidget**: Voice message player with controls
- **UserItemWidget**: Friend/user list items

### **Design System**
- **Material Design 3**: Modern Material Design components
- **Color Scheme**: Consistent color palette throughout the app
- **Typography**: Clear and readable text hierarchy
- **Icons**: Intuitive iconography for better UX

## 🔧 Technical Features

### **Performance Optimizations**
- **Batch Queries**: Efficient Firestore data fetching
- **Caching**: In-memory user data caching
- **Stream Optimization**: Real-time data with minimal overhead
- **Deduplication**: Prevents duplicate data in UI

### **Audio Management**
- **Advanced Player**: Play/pause/stop controls
- **State Management**: Proper audio state synchronization
- **Error Handling**: Graceful audio playback error recovery
- **Memory Management**: Proper cleanup of audio resources

### **Real-time Features**
- **Live Messaging**: Instant message delivery
- **Presence Updates**: Real-time user status
- **Friend Requests**: Live request notifications
- **Data Synchronization**: Automatic data updates

## 🐛 Known Issues

### Current Limitations
1. **Offline Support**: Limited offline message queuing
2. **File Sharing**: No image/document sharing yet
3. **Group Chats**: Only one-on-one conversations supported
4. **Push Notifications**: Basic notification system

### Performance Considerations
1. **Large Friend Lists**: May need pagination for 1000+ friends
2. **Message History**: Consider message archiving for old chats
3. **Audio Storage**: Voice message storage optimization needed

## 🚀 Future Improvements

### Planned Features
- **Group Chats**: Multi-user conversation support
- **File Sharing**: Image and document sharing
- **Push Notifications**: Advanced notification system
- **Message Reactions**: Emoji reactions to messages
- **Voice Calls**: Audio/video calling features
- **Message Search**: Search through message history
- **Dark Mode**: Theme switching support
- **Offline Support**: Enhanced offline functionality

### Technical Enhancements
- **Message Encryption**: End-to-end encryption
- **Performance Monitoring**: Analytics and crash reporting
- **Automated Testing**: Comprehensive test coverage
- **CI/CD Pipeline**: Automated deployment
- **Internationalization**: Multi-language support

## 📊 Dependencies

### Core Dependencies
```yaml
dependencies:
  flutter: ^3.0.0
  firebase_core: ^2.0.0
  firebase_auth: ^4.0.0
  cloud_firestore: ^4.0.0
  flutter_bloc: ^8.0.0
  go_router: ^12.0.0
  just_audio: ^0.9.0
  record: ^5.0.0
  path_provider: ^2.0.0
```

### Development Dependencies
```yaml
dev_dependencies:
  flutter_test: ^3.0.0
  flutter_lints: ^3.0.0
  mockito: ^5.0.0
  bloc_test: ^9.0.0
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation for common solutions

---

**Built with ❤️ using Flutter and Firebase**