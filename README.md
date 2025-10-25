# Heart Emergency - من قلب الطوارئ

A comprehensive emergency medical services mobile application built with Flutter and Firebase.

## Overview

Heart Emergency is a production-ready mobile application connecting patients with nearby verified doctors for emergency medical services. The app features real-time location tracking, secure payments with multi-currency support, in-app notifications, and a complete admin dashboard.

## Features

### For Patients 🏥
- ✅ Emergency call button to request immediate medical help
- ✅ Real-time GPS location with accurate address detection
- ✅ View nearby available doctors sorted by distance
- ✅ Doctor profiles with ratings and reviews
- ✅ Multi-currency wallet system with secure transactions
- ✅ Push notifications for request updates and payments
- ✅ Medical history and appointment tracking
- ✅ Wallet top-up and payment management

### For Doctors 👨‍⚕️
- ✅ Receive real-time notifications for emergency requests
- ✅ View patient location on interactive map
- ✅ Accept/reject requests with one tap
- ✅ Complete profile management with certificate uploads
- ✅ View and manage reviews from patients
- ✅ Multi-currency wallet with automatic commission calculation
- ✅ Withdrawal to bank account or PayPal
- ✅ Online/offline status toggle
- ✅ Earnings and statistics dashboard

### For Admins 🔐
- ✅ Manage all doctors (add/remove/block/unblock)
- ✅ Verify uploaded medical certificates and ID documents
- ✅ Assign additional admin users
- ✅ Monitor all wallet transactions and balances
- ✅ Set service pricing and commission percentage (default 12%)
- ✅ System-wide notifications management
- ✅ Analytics dashboard with real-time statistics
- ✅ Exchange rate management for multi-currency support

## Technology Stack

### Mobile App
- **Framework**: Flutter 3.9.2+
- **State Management**: Riverpod 3.0
- **Local Storage**: Hive + Shared Preferences
- **Navigation**: Go Router 16.2.4

### Backend Services
- **Authentication**: Firebase Authentication
- **Database**: Cloud Firestore (with offline persistence)
- **File Storage**: Firebase Storage
- **Push Notifications**: Firebase Cloud Messaging (FCM)
- **Analytics**: Firebase Analytics

### Maps & Location
- **Maps**: Google Maps Flutter
- **Geolocation**: Geolocator package
- **Geocoding**: Geocoding package

### Additional Packages
- Image Picker, File Picker for document uploads
- Flutter Local Notifications for in-app notifications
- Cached Network Image for optimized image loading
- Rating Bar for reviews
- Connectivity Plus for network status
- URL Launcher for external links

## Project Structure

```
lib/
├── config/
│   ├── router.dart                  # App routing configuration
│   └── hive_config.dart             # Local storage config
├── core/
│   ├── cache/                       # Caching utilities
│   ├── constants/                   # App constants
│   ├── theme/                       # Theme configuration
│   └── utils/                       # Utility functions
│       ├── validators.dart          # Form validation
│       ├── haversine.dart           # Distance calculation
│       └── shared_preferences_helper.dart
├── data/
│   ├── api/                         # API services
│   ├── local/                       # Local data management
│   └── models/                      # Data models
│       ├── user_model.dart
│       ├── request_model.dart
│       ├── review_model.dart
│       ├── transaction_model.dart
│       └── notification_model.dart
├── features/
│   ├── admin/                       # Admin features
│   ├── auth/                        # Authentication
│   ├── common/                      # Shared widgets
│   ├── doctor/                      # Doctor features
│   ├── patient/                     # Patient features
│   └── wallet/                      # Wallet system
├── maps/                            # Map widgets
├── services/                        # Firebase services
│   ├── firebase_auth_service.dart
│   ├── firestore_service.dart
│   ├── firebase_storage_service.dart
│   ├── fcm_service.dart
│   └── local_storage_service.dart
└── main.dart                        # App entry point
```

## Getting Started

### Prerequisites

1. **Flutter SDK**: Version 3.9.2 or higher
   ```bash
   flutter --version
   ```

2. **Firebase CLI**: For deploying Cloud Functions (optional)
   ```bash
   npm install -g firebase-tools
   ```

3. **Android Studio** or **VS Code** with Flutter extensions

4. **Firebase Account**: https://console.firebase.google.com

5. **Google Cloud Account**: For Maps API

### Installation Steps

#### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/heart_emergency.git
cd heart_emergency
```

#### 2. Install Dependencies
```bash
flutter pub get
```

#### 3. Firebase Setup

**IMPORTANT**: Follow the detailed guide in `FIREBASE_SETUP.md` for complete Firebase configuration.

Quick setup:
1. Create a Firebase project at https://console.firebase.google.com
2. Add Android app with package name: `com.example.heart_emergency`
3. Download `google-services.json` and place in `android/app/`
4. Add iOS app (if deploying to iOS)
5. Download `GoogleService-Info.plist` and add to `ios/Runner/`
6. Enable Firebase services:
   - Authentication (Email/Password)
   - Cloud Firestore
   - Firebase Storage
   - Cloud Messaging

#### 4. Google Maps API Setup

1. Go to https://console.cloud.google.com
2. Enable these APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Geocoding API
3. Create an API key
4. Update `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_GOOGLE_MAPS_API_KEY" />
   ```
5. For iOS, update `ios/Runner/AppDelegate.swift` with your API key

#### 5. Run the App

```bash
# For Android
flutter run

# For iOS (macOS only)
flutter run -d ios
```

### Building for Production

#### Debug APK (for testing)
```bash
flutter build apk --debug
```
Output: `build/app/outputs/flutter-apk/app-debug.apk`

#### Release APK (unsigned)
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

#### Signed Release APK (for distribution)

1. Create a keystore (one-time setup):
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA \
  -keysize 2048 -validity 10000 -alias upload
```

2. Create `android/key.properties`:
```properties
storePassword=<your_keystore_password>
keyPassword=<your_key_password>
keyAlias=upload
storeFile=/path/to/upload-keystore.jks
```

3. Build signed APK:
```bash
flutter build apk --release
```

#### App Bundle for Google Play Store
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS Build (macOS only)

1. Install CocoaPods dependencies:
```bash
cd ios
pod install
cd ..
```

2. Open in Xcode and configure signing:
```bash
open ios/Runner.xcworkspace
```

3. Build:
```bash
flutter build ios --release
```

## Configuration

### Environment Variables

The app uses Firebase configuration files for sensitive data:
- `android/app/google-services.json` (Firebase Android config)
- `ios/Runner/GoogleService-Info.plist` (Firebase iOS config)
- Google Maps API keys in platform manifests

**⚠️ NEVER commit these files to public repositories!**

Add to `.gitignore`:
```
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
android/key.properties
*.jks
```

### Firestore Security Rules

See `FIREBASE_SETUP.md` for complete security rules. Sample:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    // ... more rules
  }
}
```

### Firebase Storage Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /certificates/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Sample Data

### Test Accounts

Create these in Firebase Console → Authentication:

**Admin**:
- Email: `admin@heartemergency.com`
- Password: (set your own)
- Role: `admin` (set in Firestore `users` collection)

**Doctor**:
- Email: `doctor@test.com`
- Password: (set your own)
- Role: `doctor`
- Must upload certificates and be verified by admin

**Patient**:
- Email: `patient@test.com`
- Password: (set your own)
- Role: `patient`

### Sample Firestore Documents

See `assets/samples/firestore_sample_data.json` for complete sample data structure.

## Testing

### Unit Tests

Run unit tests for core utilities:
```bash
flutter test
```

Test files are in `test/` directory:
- `test/utils/haversine_test.dart` - Distance calculation tests
- `test/utils/currency_conversion_test.dart` - Currency tests
- `test/services/firestore_test.dart` - Firestore service tests

### Integration Tests

```bash
flutter test integration_test/
```

### Manual Testing Checklist

- [ ] Patient registration and login
- [ ] Doctor registration with certificate upload
- [ ] Admin verification of doctor
- [ ] Emergency request creation with GPS
- [ ] Doctor receives notification for request
- [ ] Doctor accepts request
- [ ] Payment processing with commission
- [ ] Review submission
- [ ] Wallet top-up
- [ ] Withdrawal to bank/PayPal
- [ ] Multi-currency conversion
- [ ] Offline data persistence
- [ ] Push notifications (foreground & background)
- [ ] Maps showing correct markers
- [ ] Distance calculation accuracy

## Troubleshooting

### Common Issues

**1. Build fails with Gradle error**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk
```

**2. Maps not showing**
- Verify API key is correct
- Enable "Maps SDK for Android" in Google Cloud Console
- Check API key restrictions

**3. Notifications not working**
- Request notification permission in app
- Check FCM token is saved to Firestore
- For iOS, configure APNs

**4. Firebase connection error**
- Verify `google-services.json` package name matches app package
- Check internet connection
- Verify Firebase project is active

**5. Location permission denied**
- Request runtime permissions in Flutter code
- Check device settings → App permissions
- For iOS, verify Info.plist has location usage descriptions

## Performance Optimization

- ✅ Firestore offline persistence enabled
- ✅ Cached network images
- ✅ Lazy loading for lists
- ✅ Optimized map rendering
- ✅ Background FCM handling
- ✅ Hive for fast local caching

## Security Best Practices

- ✅ Firebase security rules enforced
- ✅ API keys restricted by package name
- ✅ Sensitive data encrypted (Flutter Secure Storage)
- ✅ Input validation on all forms
- ✅ HTTPS only connections
- ✅ Token-based authentication
- ✅ Role-based access control

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## License

This project is licensed under the MIT License - see LICENSE file for details.

## Support

For issues and questions:
- Open an issue on GitHub
- Email: support@heartemergency.com
- Documentation: See `FIREBASE_SETUP.md` for detailed Firebase setup

## Roadmap

- [ ] Video consultations
- [ ] Prescription management
- [ ] Integration with pharmacy APIs
- [ ] Medical records storage
- [ ] Insurance integration
- [ ] Multi-language support
- [ ] Web admin dashboard
- [ ] Advanced analytics
- [ ] AI-powered symptom checker

## Acknowledgments

- Flutter team for amazing framework
- Firebase for backend infrastructure
- Google Maps for location services
- All open-source contributors

---

**Built with ❤️ using Flutter and Firebase**

Version: 1.0.0
Last Updated: October 2025
