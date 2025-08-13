# Mobile Development Standards

## 🎯 Overview

Standards and guidelines for Flutter mobile app development in the Tuvens ecosystem, focusing on the events discovery app with Mapbox integration.

## 🛠️ Technology Stack

### Core Framework
- **Flutter**: 3.x+ for cross-platform mobile development
- **Dart**: Latest stable version
- **Target Platforms**: iOS 13+, Android API 26+ (Android 8.0)

### Key Integrations
- **Mapbox SDK**: Interactive maps and location services
- **Tuvens API**: RESTful API integration for events data
- **Firebase**: Push notifications and analytics
- **SQLite/Hive**: Local data storage and offline capabilities

## 📱 App Architecture

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── app/                      # App-level configuration
├── core/                     # Core utilities and constants
│   ├── api/                  # API client and services
│   ├── storage/              # Local storage abstractions
│   └── utils/                # Shared utilities
├── features/                 # Feature-based modules
│   ├── events/               # Event discovery and display
│   ├── maps/                 # Mapbox integration
│   ├── auth/                 # Authentication
│   └── profile/              # User profile management
├── shared/                   # Shared UI components
│   ├── widgets/              # Reusable widgets
│   ├── models/               # Data models
│   └── services/             # Shared business logic
└── assets/                   # Images, fonts, etc.
```

### Architecture Pattern
- **Clean Architecture**: Clear separation of concerns
- **Feature-First**: Organize code by features, not layers
- **State Management**: Provider/Riverpod or Bloc pattern
- **Dependency Injection**: get_it or similar for service location

## 🗺️ Mapbox Integration Standards

### Setup Requirements
- Secure API key management using flutter_dotenv
- Proper Android and iOS SDK configuration
- Custom map styling matching Tuvens design language

### Event Display
- Custom markers for different event types
- Marker clustering for performance optimization
- Interactive info windows with event details
- Smooth map animations and transitions

### Location Services
- Request location permissions gracefully
- Handle permission denial scenarios
- Implement background location updates when appropriate
- Respect user privacy and battery usage

## 🔌 API Integration Standards

### HTTP Client Configuration
```dart
// Example API client setup
class ApiClient {
  static const baseUrl = 'https://api.tuvens.com';
  
  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  ));
}
```

### Authentication
- JWT token management with automatic refresh
- Secure token storage using flutter_secure_storage
- Proper logout and session management
- Handle authentication errors gracefully

### Data Models
- Use json_annotation for serialization
- Implement proper error models
- Add validation for API responses
- Handle null safety appropriately

## 🎨 UI/UX Standards

### Design System
- **Colors**: Follow Tuvens color palette
  - Primary: Tuvens Blue (#5C69E6)
  - Secondary: Coral (#FF5A6D)
  - Accent: Yellow (#FFD669)
  - Dark: Navy (#071551)

### Typography
- **Font Family**: Montserrat (or system default)
- Consistent text styles throughout the app
- Proper accessibility contrast ratios
- Responsive text sizing for different screen sizes

### Component Standards
- Reusable widget library in `shared/widgets/`
- Consistent spacing and padding (8px grid system)
- Smooth animations with proper duration curves
- Loading states for all async operations

## 📋 Event Card Design

### Card Structure
```dart
class EventCard extends StatelessWidget {
  final Event event;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Column(
        children: [
          EventImage(url: event.imageUrl),
          EventDetails(event: event),
          EventActions(event: event),
        ],
      ),
    );
  }
}
```

### Required Information
- Event title and description
- Date, time, and location
- Event category with color coding
- Distance from user (if location enabled)
- Attendance count or interest indicators
- Action buttons (save, share, get directions)

## 🧪 Testing Standards

### Test Coverage Requirements
- **Minimum**: 70% overall test coverage
- **Unit Tests**: Core business logic and utilities
- **Widget Tests**: UI components and user interactions
- **Integration Tests**: Critical user flows and API integration

### Testing Structure
```
test/
├── unit/                     # Unit tests
├── widget/                   # Widget tests
├── integration/              # Integration tests
└── helpers/                  # Test utilities and mocks
```

### Key Testing Areas
- Event data parsing and display
- Map functionality and location services
- API error handling and retry logic
- User authentication flows
- Offline data synchronization

## 📱 Platform-Specific Considerations

### iOS Requirements
- App Store compliance and review guidelines
- Proper info.plist configuration for permissions
- iOS-specific UI patterns where appropriate
- TestFlight distribution for beta testing

### Android Requirements
- Google Play Store requirements
- Proper AndroidManifest.xml configuration
- Material Design 3 components
- Android App Bundle (AAB) for distribution

### Permissions
- Location: "This app uses your location to show nearby events"
- Camera: "Take photos to share with your event posts"
- Notifications: "Receive updates about events you're interested in"

## 🔋 Performance Optimization

### Mobile Performance Targets
- **App Startup**: < 3 seconds cold start
- **Frame Rate**: Maintain 60fps during scrolling and animations
- **Memory Usage**: Stay under 100MB for typical usage
- **Battery Usage**: Minimal background activity

### Optimization Techniques
- Lazy loading for event lists and images
- Image caching with flutter_cached_network_image
- Efficient state management to prevent unnecessary rebuilds
- Proper disposal of controllers and streams

## 🌐 Offline Capabilities

### Local Storage Strategy
- Cache recent events data for offline browsing
- Store user preferences and authentication tokens
- Implement sync mechanisms for when connectivity returns
- Handle conflicts between local and remote data

### Offline UX
- Clear indicators when app is offline
- Graceful degradation of features
- Queue actions to perform when online
- Informative error messages for network issues

## 🔔 Push Notifications

### Firebase Integration
- Proper FCM setup for both platforms
- Handle notification permissions
- Deep linking from notifications to specific events
- Analytics for notification engagement

### Notification Types
- New events in user's area
- Events from followed organizers
- Reminders for saved events
- System updates and announcements

## 📊 Analytics and Monitoring

### Required Tracking
- App usage patterns and feature adoption
- Crash reporting with Firebase Crashlytics
- Performance monitoring and user session data
- Custom events for business metrics

### Privacy Considerations
- Respect user privacy preferences
- Implement proper consent mechanisms
- Follow GDPR and other privacy regulations
- Provide opt-out options for analytics

## 🚀 Development Workflow

### Code Quality
- Use flutter_lints for consistent code style
- Implement pre-commit hooks for formatting
- Code reviews focusing on performance and UX
- Regular dependency updates and security patches

### Deployment Process
- Automated testing in CI/CD pipeline
- Staged rollouts for major updates
- A/B testing for new features
- Monitoring and rollback procedures

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Mapbox Flutter Plugin](https://docs.mapbox.com/flutter/maps/)
- [Tuvens API Documentation](../../repositories/tuvens-api.md)
- [Tuvens Design System](../frontend-integration/design-system-integration.md)

---

*This document should be updated as the mobile app evolves and new requirements emerge.*