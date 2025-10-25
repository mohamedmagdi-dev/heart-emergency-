# Firebase Authentication Implementation Guide

## 🎯 Overview

This document describes the complete Firebase Authentication implementation for the Emergency Medical Services app with three user roles: **Patient**, **Doctor**, and **Admin**.

## 📋 Features Implemented

### ✅ Authentication Features
- **Email/Password Authentication** for all user types
- **Auto-login** functionality using Firebase Auth state persistence
- **Role-based navigation** (Patient/Doctor/Admin dashboards)
- **Secure token storage** (handled automatically by Firebase SDK)
- **Error handling** with Arabic error messages
- **Account verification** for doctors (pending/approved workflow)

### ✅ User Profiles & Firestore Integration

#### Patient Signup Collects:
- Name
- Phone
- Email
- Location (GPS auto-fetched)
- Wallet balance (default: 0)
- Role: "patient"
- FCM token for notifications

#### Doctor Signup Collects:
- Name
- Phone
- Email
- Specialization (dropdown selection)
- Years of experience
- Certificates (PDF/Image upload to Firebase Storage)
- ID Document (upload to Firebase Storage)
- Location (GPS auto-fetched)
- Verification status (default: "pending")
- Wallet balance (default: 0)
- Role: "doctor"
- FCM token for notifications

#### Admin:
- Created manually in Firestore with role: "admin"
- Auto-verified
- Access to admin dashboard

### ✅ Security Implementation

#### Firestore Security Rules (`firestore.rules`):
- **Users Collection**: Users can only read/update their own data (except sensitive fields)
- **Requests Collection**: Patients create, doctors can accept/update, role-based read access
- **Wallets Collection**: Read-only for users, write-only for admins
- **Transactions Collection**: Read-only for transaction owners, write-only for admins
- **Reviews Collection**: Public read, patients can create/update their own
- **Notifications Collection**: Users can only read/update their own notifications
- **Settings Collection**: Public read, admin-only write

#### Data Protection:
- Patients cannot edit doctor verification status
- Users cannot modify their own wallet balances
- Role changes are prevented
- Blocked users are automatically logged out

### ✅ Navigation Flow

```
App Launch
    ↓
Check Firebase Auth State
    ↓
[Not Logged In] → Welcome Screen → Choose Role → Auth Screen
    ↓
[Logged In] → Check Role → Redirect to Dashboard
    ↓
Patient → Patient Dashboard
Doctor (Verified) → Doctor Dashboard
Doctor (Not Verified) → Verification Pending Screen
Admin → Admin Dashboard
```

## 📁 File Structure

### Core Files
```
lib/
├── providers/
│   └── auth_provider.dart              # Riverpod providers for auth state
├── services/
│   ├── firebase_auth_service.dart      # Firebase Auth operations
│   ├── firebase_storage_service.dart   # File upload to Storage
│   └── fcm_service.dart                # Push notifications
├── data/models/
│   └── user_model.dart                 # User data model
├── features/
│   ├── auth/screens/
│   │   ├── firebase_patient_auth_screen.dart
│   │   ├── firebase_doctor_auth_screen.dart
│   │   ├── firebase_admin_login_screen.dart
│   │   └── doctor_verification_pending_screen.dart
│   └── common/screens/
│       └── firebase_welcome_screen.dart
├── config/
│   └── firebase_router.dart            # GoRouter with auth guards
└── main.dart                           # App entry with Firebase init
```

### Configuration Files
```
firestore.rules                         # Firestore security rules
firebase.json                           # Firebase config
android/app/google-services.json        # Android Firebase config
```

## 🚀 How to Use

### 1. Patient Registration Flow

```dart
// User opens app → Welcome screen → Clicks "مريض" button
// Navigation: / → /patient/auth

1. Fill form:
   - Name
   - Phone
   - Email
   - Password
   - Confirm Password
   (Location fetched automatically)

2. Click "إنشاء الحساب"

3. System:
   - Creates Firebase Auth user
   - Uploads data to Firestore /users/{uid}
   - Initializes wallet with balance: 0
   - Saves FCM token
   - Auto-login

4. Redirect to: /patient/dashboard
```

### 2. Doctor Registration Flow

```dart
// User opens app → Welcome screen → Clicks "طبيب" button
// Navigation: / → /doctor/auth

1. Fill form:
   - Name
   - Phone
   - Email
   - Specialization (dropdown)
   - Experience (dropdown)
   - Upload Certificates (PDF/Images)
   - Upload ID Document
   - Password
   - Confirm Password
   (Location fetched automatically)

2. Click "إنشاء الحساب"

3. System:
   - Creates Firebase Auth user
   - Uploads files to Firebase Storage
   - Uploads data to Firestore /users/{uid}
   - Sets isVerified: false
   - Initializes wallet with balance: 0
   - Saves FCM token

4. Redirect to: /doctor/pending-verification
   (Shows message: Account under review)
```

### 3. Admin Login Flow

```dart
// Admin must be created manually in Firestore first

1. Create admin user in Firestore:
   {
     uid: "admin_uid",
     email: "admin@example.com",
     name: "Admin Name",
     role: "admin",
     isVerified: true,
     isBlocked: false,
     createdAt: Timestamp.now()
   }

2. Create Firebase Auth account with same email

3. Admin can login at: /admin/login

4. Redirect to: /admin/dashboard
```

### 4. Auto-Login

```dart
// On app launch, Firebase Auth checks for existing session

If (user logged in) {
  Get user role from Firestore
  
  If (patient) → /patient/dashboard
  If (doctor && verified) → /doctor/dashboard
  If (doctor && !verified) → /doctor/pending-verification
  If (admin) → /admin/dashboard
}
Else {
  Show welcome screen
}
```

## 🔐 Security Best Practices

### 1. Firestore Rules
Deploy the `firestore.rules` file to Firebase:
```bash
firebase deploy --only firestore:rules
```

### 2. Storage Rules
Configure Firebase Storage rules:
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /certificates/{document} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.token.role == 'doctor';
    }
    match /id_documents/{document} {
      allow read: if request.auth != null && 
                  (request.auth.token.role == 'admin' || request.auth.uid == resource.metadata.uploadedBy);
      allow write: if request.auth != null && request.auth.token.role == 'doctor';
    }
  }
}
```

### 3. Environment Variables
Never commit sensitive data. Use environment variables for:
- Firebase API keys (already in `firebase_options.dart`)
- Admin credentials

## 📱 Push Notifications (FCM)

### Implementation in `fcm_service.dart`:
```dart
// On signup/login:
1. Request notification permission
2. Get FCM token
3. Save token to Firestore user document

// When doctor gets verified:
Admin → Updates isVerified to true
FCM sends notification: "تم تفعيل حسابك"

// When patient creates emergency request:
System → Notifies nearby doctors
FCM sends notification: "طلب طوارئ جديد"
```

## 🧪 Testing

### Test User Accounts

#### Patient Test Account:
```
Email: patient@test.com
Password: Test123!
Role: patient
```

#### Doctor Test Account:
```
Email: doctor@test.com
Password: Test123!
Role: doctor
isVerified: true (manually set in Firestore)
```

#### Admin Test Account:
```
Email: admin@test.com
Password: Admin123!
Role: admin
```

### Test Scenarios

1. **New Patient Signup**
   - Go to /patient/auth
   - Fill form with valid data
   - Verify account created in Firebase Console
   - Check redirect to /patient/dashboard

2. **New Doctor Signup**
   - Go to /doctor/auth
   - Upload test certificates and ID
   - Verify files uploaded to Storage
   - Check redirect to /doctor/pending-verification

3. **Doctor Verification**
   - Login as admin
   - Go to admin dashboard
   - Approve doctor verification
   - Doctor should receive notification
   - Doctor can now login to dashboard

4. **Auto-Login**
   - Login as any user
   - Close and reopen app
   - Should automatically redirect to correct dashboard

5. **Role-Based Access**
   - Try accessing /admin/dashboard as patient → Should redirect to /
   - Try accessing /patient/dashboard as doctor → Should redirect to /

## 🐛 Error Handling

### Common Errors & Solutions

| Error | Arabic Message | Solution |
|-------|---------------|----------|
| `email-already-in-use` | البريد الإلكتروني مستخدم بالفعل | Use different email |
| `weak-password` | كلمة المرور ضعيفة جداً | Use stronger password (min 6 chars) |
| `wrong-password` | كلمة المرور غير صحيحة | Check password |
| `user-not-found` | المستخدم غير موجود | Check email or signup |
| `network-request-failed` | فشل الاتصال بالإنترنت | Check internet connection |

## 📊 Database Schema

### Users Collection (`/users/{uid}`)
```javascript
{
  uid: string,
  email: string,
  name: string,
  role: 'patient' | 'doctor' | 'admin',
  phone: string,
  createdAt: Timestamp,
  isVerified: boolean,
  isBlocked: boolean,
  fcmToken: string?,
  
  // Patient fields
  age: number?,
  
  // Doctor fields
  specialization: string?,
  experience: string?,
  certificateUrls: string[]?,
  idDocumentUrl: string?,
  latitude: number?,
  longitude: number?,
  isOnline: boolean?,
  averageRating: number?,
  reviewCount: number?,
  
  // Additional data
  additionalData: {
    walletBalance: 0
  }
}
```

## 🔄 Wallet & Transactions

### Wallet Initialization
On signup, wallet is automatically created:
```dart
/wallets/{userId} {
  userId: uid,
  balances: {
    'SAR': 0.0
  },
  createdAt: Timestamp.now()
}
```

### Transaction Flow (Patient → Doctor)
1. Patient completes service
2. System deducts from patient wallet
3. System adds to doctor wallet (minus 12% commission)
4. System adds commission to admin wallet
5. Transaction records created for both users

## 📈 Next Steps

### Features to Add:
1. ✅ Email verification
2. ✅ Phone number authentication (OTP)
3. ✅ Forgot password flow
4. ✅ Profile picture upload
5. ✅ Two-factor authentication
6. ✅ Session management
7. ✅ Device tracking

### Admin Features:
- Dashboard to approve/reject doctor verifications
- View all users
- Manage transactions
- Send notifications
- Generate reports
- Block/unblock users

## 🆘 Support

For issues or questions:
1. Check Firebase Console logs
2. Review Firestore security rules
3. Verify user role in database
4. Check FCM token registration
5. Review error messages in Arabic

## 📝 License

This implementation is part of the Emergency Medical Services app.

---

**Last Updated**: 2025-10-02
**Version**: 1.0.0
**Status**: ✅ Fully Implemented & Tested

