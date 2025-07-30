# Social Tinder - Caribbean Connection

A comprehensive Flutter app that combines social networking, dating, restaurant discovery, and event management with a beautiful Caribbean theme.

## 🌴 Features

### Authentication & Profile Setup
- **Beautiful Caribbean-themed login/signup screens** with coconut trees and beach gradients
- **Complete profile setup** including name, age, location, nationality, gender, height, interests, and photo uploads
- **Firebase Authentication** for secure user management

### Social Wall
- **Post status updates** with text and images
- **Like and comment** on posts
- **Add friends by username**
- **Real-time feed** of friends' activities
- **Caribbean-themed UI** with yellow and white color scheme

### Dating Features
- **Swipe-based matching** (right to like, left to pass)
- **Advanced filtering** by distance, nationality, gender, and age
- **Automatic matching** when both users swipe right
- **Profile cards** with photos, interests, and basic info
- **Match notifications** and chat integration

### Restaurant Hub
- **Restaurant listings** with ratings and reviews
- **Menu and specials** display
- **1-5 star rating system**
- **Restaurant owner dashboard** for managing listings
- **Monthly subscription model** for restaurant advertising

### Event Hub
- **Event creation and management** for promoters
- **E-ticket sales** with commission tracking
- **Event discovery** with filtering options
- **Ticket purchase** and management
- **Revenue tracking** for promoters

### Chat System
- **Real-time messaging** between matched users
- **Chat history** and message persistence
- **User-friendly interface** with message bubbles
- **Match-based conversations**

## 🎨 Design & Theme

### Caribbean Color Palette
- **Primary Yellow**: `#FFD700` (Golden yellow)
- **Secondary Yellow**: `#FFEB3B` (Light yellow)
- **Light Yellow**: `#FFF8E1` (Very light yellow)
- **Ocean Blue**: `#1E90FF` (Caribbean blue)
- **Light Blue**: `#87CEEB` (Sky blue)
- **Sand Color**: `#F4E4BC` (Beach sand)
- **Dark Text**: `#2C3E50` (Deep blue-gray)
- **Light Text**: `#7F8C8D` (Gray)

### UI Components
- **Gradient backgrounds** simulating Caribbean beaches
- **Coconut tree decorations** on splash screen
- **Rounded corners** and modern card designs
- **Responsive design** using ScreenUtil and MediaQuery
- **Smooth animations** and transitions

## 🛠 Technical Stack

### Frontend
- **Flutter 3.0+** for cross-platform development
- **GetX** for state management and dependency injection
- **ScreenUtil** for responsive design
- **MediaQuery** for adaptive layouts

### Backend
- **Firebase Authentication** for user management
- **Cloud Firestore** for real-time database
- **Firebase Storage** for image uploads
- **Firebase Cloud Functions** (optional for advanced features)

### Key Dependencies
```yaml
get: ^4.6.6                    # State management
firebase_core: ^2.24.2         # Firebase core
firebase_auth: ^4.15.3         # Authentication
cloud_firestore: ^4.13.6       # Database
firebase_storage: ^11.5.6       # File storage
screenutil: ^5.9.0             # Responsive design
image_picker: ^1.0.4           # Image selection
cached_network_image: ^3.3.0   # Image caching
geolocator: ^10.1.0            # Location services
```

## 📱 App Structure

```
lib/
├── main.dart                   # App entry point
├── app/
│   ├── theme/
│   │   └── app_theme.dart     # Caribbean theme
│   ├── routes/
│   │   ├── app_routes.dart    # Route constants
│   │   └── app_pages.dart     # Route definitions
│   └── modules/
│       ├── splash/            # Splash screen
│       ├── auth/              # Authentication
│       ├── profile/           # Profile setup
│       ├── main/              # Main navigation
│       ├── social/            # Social wall
│       ├── dating/            # Dating features
│       ├── restaurants/       # Restaurant hub
│       ├── events/            # Event hub
│       └── chat/              # Messaging
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0+
- Dart 3.0+
- Firebase project setup
- Android Studio / VS Code

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/social-tinder.git
   cd social-tinder
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project
   - Enable Authentication, Firestore, and Storage
   - Download and add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Configure Firebase rules for security

4. **Run the app**
   ```bash
   flutter run
   ```

## 🔧 Configuration

### Firebase Configuration
1. **Authentication**: Enable Email/Password authentication
2. **Firestore**: Set up collections for users, posts, matches, restaurants, events, tickets
3. **Storage**: Configure rules for image uploads
4. **Security Rules**: Implement proper access control

### Environment Variables
Create a `.env` file for sensitive configuration:
```
FIREBASE_API_KEY=your_api_key
FIREBASE_PROJECT_ID=your_project_id
```

## 📊 Database Schema

### Collections
- **users**: User profiles and preferences
- **posts**: Social wall posts
- **matches**: Dating matches
- **messages**: Chat messages
- **restaurants**: Restaurant listings
- **events**: Event listings
- **tickets**: Event tickets
- **ratings**: Restaurant ratings

## 🎯 Key Features Implementation

### Dating Algorithm
- **Swipe tracking** in Firestore
- **Match detection** when both users swipe right
- **Filtering** based on user preferences
- **Location-based matching** (future enhancement)

### Restaurant System
- **Owner verification** and subscription management
- **Rating aggregation** and display
- **Menu management** with specials
- **Revenue tracking** for platform

### Event Management
- **Promoter profiles** and verification
- **Ticket sales** with commission calculation
- **Event discovery** with search and filters
- **Revenue sharing** system

## 🔒 Security Features

- **Firebase Authentication** for secure login
- **Firestore security rules** for data protection
- **Image upload validation** and virus scanning
- **User data privacy** controls
- **Rate limiting** for API calls

## 📱 Platform Support

- **Android**: API level 21+ (Android 5.0+)
- **iOS**: iOS 11.0+
- **Web**: Chrome, Firefox, Safari (future)
- **Desktop**: Windows, macOS, Linux (future)

## 🚀 Deployment

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Caribbean community** for inspiration
- **Flutter team** for the amazing framework
- **Firebase team** for the robust backend services
- **GetX team** for the excellent state management solution

## 📞 Support

For support and questions:
- Create an issue on GitHub
- Email: support@socialtinder.com
- Discord: [Social Tinder Community](https://discord.gg/socialtinder)

---

**Made with ❤️ for the Caribbean community**