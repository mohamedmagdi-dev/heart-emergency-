# Firebase Setup Guide

## Overview
This guide explains how to set up Firebase for the Heart Emergency app with complete integration for Authentication, Firestore, Storage, and Cloud Messaging.

## Prerequisites
- Flutter SDK (3.9.2 or higher)
- Android Studio or VS Code
- Firebase account (https://console.firebase.google.com)
- Google Maps API key

---

## Step 1: Create Firebase Project

1. Go to https://console.firebase.google.com
2. Click "Add project"
3. Name your project: `heart-emergency` or your preferred name
4. Disable Google Analytics (optional for development)
5. Click "Create project"

---

## Step 2: Add Android App to Firebase

1. In Firebase Console, click "Add app" → Select Android
2. Register app:
   - **Android package name**: `com.example.heart_emergency`
   - **App nickname**: Heart Emergency (optional)
   - **Debug signing certificate**: Leave blank for development
3. Click "Register app"

4. **Download `google-services.json`**:
   - Download the file
   - Place it in: `android/app/google-services.json`
   - ⚠️ **CRITICAL**: This file is already in the correct location, just verify the package name matches

5. Click "Next" → "Continue to console"

---

## Step 3: Add iOS App to Firebase (Optional but Recommended)

1. In Firebase Console, click "Add app" → Select iOS
2. Register app:
   - **iOS bundle ID**: `com.example.heartEmergency`
   - **App nickname**: Heart Emergency iOS (optional)
3. **Download `GoogleService-Info.plist`**:
   - Download the file
   - Open Xcode: `open ios/Runner.xcworkspace`
   - Drag `GoogleService-Info.plist` into `ios/Runner` folder
   - Ensure "Copy items if needed" is checked

4. Update `ios/Runner/Info.plist` with location and notification permissions:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to show nearby doctors and help them reach you in emergencies</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need your location to provide emergency medical services</string>
<key>NSCameraUsageDescription</key>
<string>We need camera access to upload medical certificates and ID documents</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to upload medical certificates and ID documents</string>
```

5. Update `ios/Podfile` minimum iOS version to 13.0:
```ruby
platform :ios, '13.0'
```

---

## Step 4: Enable Firebase Services

### 4.1 Firebase Authentication
1. In Firebase Console → Authentication → Get started
2. Enable sign-in methods:
   - **Email/Password**: Enable this
   - Other methods: Optional

### 4.2 Cloud Firestore
1. In Firebase Console → Firestore Database → Create database
2. Start in **test mode** for development (update rules later)
3. Choose location: Select closest to your users
4. Click "Enable"

**Important**: Update security rules after testing:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
      allow update: if request.auth != null && 
        (get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin' ||
         request.auth.uid == userId);
    }
    
    // Requests collection
    match /requests/{requestId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
        request.auth.uid == request.resource.data.patientId;
      allow update: if request.auth != null && 
        (request.auth.uid == resource.data.patientId || 
         request.auth.uid == resource.data.doctorId ||
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Wallets collection
    match /wallets/{walletId} {
      allow read: if request.auth != null && request.auth.uid == walletId;
      allow write: if false; // Only via Cloud Functions or admin
    }
    
    // Transactions collection
    match /transactions/{transactionId} {
      allow read: if request.auth != null && 
        request.auth.uid == resource.data.userId;
      allow create: if request.auth != null;
    }
    
    // Reviews collection
    match /reviews/{reviewId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
        request.auth.uid == request.resource.data.patientId;
    }
    
    // Notifications collection
    match /notifications/{notificationId} {
      allow read: if request.auth != null && 
        request.auth.uid == resource.data.userId;
      allow write: if false; // Only via Cloud Functions
    }
    
    // Settings collection (exchange rates, etc.)
    match /settings/{document} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

### 4.3 Firebase Storage
1. In Firebase Console → Storage → Get started
2. Start in **test mode** for development
3. Choose same location as Firestore
4. Click "Done"

**Update Storage rules**:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /certificates/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /ids/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /profiles/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 4.4 Firebase Cloud Messaging (FCM)
1. In Firebase Console → Cloud Messaging
2. No additional setup required for basic functionality
3. For iOS, upload APNs certificate (see iOS setup guide)

---

## Step 5: Google Maps API Setup

1. Go to https://console.cloud.google.com
2. Select your Firebase project (or create a new project)
3. Enable APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Geocoding API
   - Places API
4. Create API Key:
   - APIs & Services → Credentials → Create Credentials → API Key
   - Copy the API key
5. Restrict API key (recommended):
   - Edit API key
   - Application restrictions: Android apps / iOS apps
   - Add package name: `com.example.heart_emergency`

**Update API key in code**:

**Android**: `android/app/src/main/AndroidManifest.xml`
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY" />
```

**iOS**: Add to `ios/Runner/AppDelegate.swift`:
```swift
import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

---

## Step 6: Initialize Sample Data

After Firebase is set up, you can initialize sample data using the Firebase Console or a Cloud Function.

### Sample Firestore Documents

#### Create Admin User
Collection: `users`
Document ID: (auto-generated)
```json
{
  "uid": "auto-generated-uid",
  "email": "admin@heartemergency.com",
  "name": "Admin",
  "role": "admin",
  "createdAt": "2025-10-01T00:00:00Z",
  "isVerified": true,
  "isBlocked": false,
  "additionalData": {}
}
```

#### Create Exchange Rates
Collection: `settings`
Document ID: `exchangeRates`
```json
{
  "rates": {
    "SAR": 1.0,
    "USD": 3.75,
    "EUR": 4.10,
    "YER": 0.0015,
    "EGP": 0.12
  },
  "updatedAt": "2025-10-01T00:00:00Z"
}
```

#### Create Service Pricing
Collection: `settings`
Document ID: `pricing`
```json
{
  "commissionPercent": 0.12,
  "basePrice": 50,
  "currency": "SAR",
  "updatedAt": "2025-10-01T00:00:00Z"
}
```

---

## Step 7: Test Firebase Connection

1. **Clean and get dependencies**:
```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
```

2. **Run the app**:
```bash
# For Android
flutter run

# For iOS (macOS only)
flutter run -d ios
```

3. **Test Authentication**:
   - Try creating a new account
   - Check Firebase Console → Authentication to see the user
   - Try logging in

4. **Test Firestore**:
   - Create an emergency request
   - Check Firebase Console → Firestore to see the document
   - Update user profile
   - Verify data appears in Firestore

5. **Test Storage**:
   - Upload a profile picture or certificate
   - Check Firebase Console → Storage to see the file
   - Verify file URL is saved in Firestore

6. **Test FCM**:
   - Send a test message from Firebase Console → Cloud Messaging
   - Verify notification appears on device

---

## Step 8: Production Deployment

### Update Firebase Security Rules
- Apply the security rules from Step 4.2 and 4.3
- Test thoroughly in a staging environment first

### Add Firebase Cloud Functions (Optional but Recommended)

Create `functions/index.js`:
```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Send notification when new request is created
exports.sendRequestNotification = functions.firestore
  .document('requests/{requestId}')
  .onCreate(async (snap, context) => {
    const request = snap.data();
    
    // Get nearby doctors
    const doctorsSnapshot = await admin.firestore()
      .collection('users')
      .where('role', '==', 'doctor')
      .where('isVerified', '==', true)
      .where('isOnline', '==', true)
      .get();
    
    const tokens = [];
    doctorsSnapshot.forEach(doc => {
      const fcmToken = doc.data().fcmToken;
      if (fcmToken) tokens.push(fcmToken);
    });
    
    if (tokens.length === 0) return null;
    
    const payload = {
      notification: {
        title: 'طلب طوارئ جديد',
        body: `طلب طوارئ جديد: ${request.symptoms}`,
      },
      data: {
        requestId: context.params.requestId,
        type: 'new_request',
      },
    };
    
    return admin.messaging().sendToDevice(tokens, payload);
  });
```

Deploy functions:
```bash
cd functions
npm install
firebase deploy --only functions
```

### Build Release APK

```bash
# Build release APK
flutter build apk --release

# Build App Bundle for Play Store
flutter build appbundle --release
```

### Sign Android App (for Play Store)

1. Create keystore:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. Create `android/key.properties`:
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=upload
storeFile=/path/to/upload-keystore.jks
```

3. Update `android/app/build.gradle.kts`:
```kotlin
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

---

## Troubleshooting

### Issue: "No Firebase App '[DEFAULT]' has been created"
**Solution**: Ensure `google-services.json` is in `android/app/` and package name matches

### Issue: Google Maps not showing
**Solution**: 
1. Verify API key is correct in AndroidManifest.xml
2. Enable "Maps SDK for Android" in Google Cloud Console
3. Check API key restrictions

### Issue: Notifications not working
**Solution**:
1. Request notification permission in app
2. Check FCM token is saved to Firestore
3. Test with Firebase Console → Cloud Messaging → Send test message
4. For iOS, ensure APNs is configured

### Issue: Location permission denied
**Solution**:
1. Ensure permissions in AndroidManifest.xml
2. Request runtime permission in Flutter code
3. Check device settings → App permissions

---

## Support

For issues:
1. Check Firebase Console for errors
2. Check Flutter logs: `flutter logs`
3. Check Firestore rules and Storage rules
4. Verify API keys are correct and not restricted incorrectly

---

## Security Checklist

Before going live:
- [ ] Update Firestore security rules (remove test mode)
- [ ] Update Storage security rules (remove test mode)
- [ ] Restrict API keys properly
- [ ] Enable App Check for additional security
- [ ] Set up budget alerts in Firebase
- [ ] Test all user roles (patient, doctor, admin)
- [ ] Implement rate limiting for API calls
- [ ] Add backup and recovery procedures
- [ ] Set up monitoring and alerts
- [ ] Review and limit Firebase costs

---

## Next Steps

1. Complete Firebase setup following this guide
2. Test all features thoroughly
3. Add additional features as needed
4. Deploy to production
5. Monitor usage and costs
6. Iterate based on user feedback

Good luck with your deployment! 🚀

