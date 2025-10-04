# 🔥 Firebase Console Setup Guide

## Complete step-by-step guide to configure Firebase Console for your Emergency Medical Services App

---

## 📋 Prerequisites

- Google Account
- Firebase project already created
- `google-services.json` already downloaded and placed in `android/app/`

---

## 1️⃣ Enable Authentication Methods

### Step 1: Go to Authentication
1. Open [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **"heart_emergency"** (or your project name)
3. Click **"Authentication"** in the left sidebar
4. Click **"Get started"** (if first time)

### Step 2: Enable Email/Password Authentication
1. Click **"Sign-in method"** tab
2. Find **"Email/Password"** in the list
3. Click on it
4. Toggle **"Enable"** to ON
5. **Important:** Keep "Email link (passwordless sign-in)" DISABLED
6. Click **"Save"**

✅ **Email/Password authentication is now enabled!**

### Step 3: (Optional) Enable Phone Authentication
If you want phone number login in the future:
1. Click on **"Phone"** in sign-in methods
2. Toggle **"Enable"** to ON
3. Click **"Save"**

---

## 2️⃣ Set Up Firestore Database

### Step 1: Create Firestore Database
1. Click **"Firestore Database"** in the left sidebar
2. Click **"Create database"**
3. **Select mode**: Choose **"Start in production mode"** (we'll add rules next)
4. **Select location**: Choose closest to your users (e.g., `asia-south1` for Middle East/India)
5. Click **"Enable"**

⏳ Wait 1-2 minutes for database to be created

### Step 2: Create Required Collections

#### Create `users` Collection:
1. In Firestore, click **"Start collection"**
2. Collection ID: `users`
3. Click **"Next"**
4. Click **"Auto-ID"** for first document (we'll create admin user later)
5. Click **"Save"**

#### Create Other Collections (Optional - will be auto-created by app):
- `requests` - Emergency requests
- `wallets` - User wallets
- `transactions` - Transaction history
- `reviews` - Doctor reviews
- `notifications` - User notifications
- `settings` - App settings (exchange rates, etc.)

### Step 3: Deploy Security Rules
1. In Firestore, click **"Rules"** tab
2. **Delete all existing rules**
3. **Copy the entire content** from your project's `firestore.rules` file
4. **Paste** into the Firebase Console rules editor
5. Click **"Publish"**

✅ **Firestore is now secured with role-based access control!**

---

## 3️⃣ Set Up Firebase Storage

### Step 1: Enable Storage
1. Click **"Storage"** in the left sidebar
2. Click **"Get started"**
3. Click **"Next"** (keep default rules for now)
4. **Select location**: Use the **same location** as Firestore
5. Click **"Done"**

### Step 2: Configure Storage Rules
1. In Storage, click **"Rules"** tab
2. Replace the default rules with:

```javascript
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    
    // Certificates folder - only doctors can upload, all authenticated users can read
    match /certificates/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                   request.resource.size < 10 * 1024 * 1024; // Max 10MB
    }
    
    // ID documents folder - only doctors can upload, admin can read
    match /id_documents/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                   request.resource.size < 10 * 1024 * 1024; // Max 10MB
    }
    
    // Profile pictures folder
    match /profile_pictures/{fileName} {
      allow read: if true; // Public read
      allow write: if request.auth != null && 
                   request.resource.size < 5 * 1024 * 1024; // Max 5MB
    }
  }
}
```

3. Click **"Publish"**

✅ **Storage is now configured!**

---

## 4️⃣ Set Up Cloud Messaging (FCM)

### Step 1: Enable Cloud Messaging
1. Click **"Cloud Messaging"** in the left sidebar
2. Firebase Cloud Messaging should already be enabled
3. Note your **Server Key** (you might need it for backend notifications)

### Step 2: Configure Android
Your `google-services.json` already contains FCM configuration.

✅ **FCM is ready to send push notifications!**

---

## 5️⃣ Create Admin User (CRITICAL!)

### Method 1: Using Firebase Console (Recommended)

#### Step A: Create Auth User
1. Go to **"Authentication"** → **"Users"** tab
2. Click **"Add user"**
3. Enter:
   - **Email**: `admin@heart-emergency.com` (or your preferred email)
   - **Password**: `Admin123!@#` (use a strong password)
4. Click **"Add user"**
5. **Copy the User UID** (you'll need it next)

#### Step B: Create Firestore Document
1. Go to **"Firestore Database"**
2. Click on **"users"** collection
3. Click **"Add document"**
4. **Document ID**: Paste the **User UID** you copied
5. Add these fields:

```javascript
Field                Value                    Type
-----                -----                    ----
uid                  [paste UID here]         string
email                admin@heart-emergency.com string
name                 المسؤول الرئيسي         string
role                 admin                    string
isVerified           true                     boolean
isBlocked            false                    boolean
createdAt            [current timestamp]      timestamp
phone                +966500000000            string
additionalData       {}                       map
```

6. Click **"Save"**

✅ **Admin account created! You can now login as admin in the app.**

### Method 2: Create Multiple Admins (If Needed)
Repeat the process above for each admin user.

---

## 6️⃣ Test Data Setup (Optional)

### Create Test Patient
1. Go to **"Authentication"** → **"Users"**
2. Add user:
   - Email: `patient@test.com`
   - Password: `Test123!`
3. Copy UID
4. In **"Firestore"** → **"users"** → **"Add document"**:
   - Document ID: [UID]
   - Fields:
     ```
     uid: [UID]
     email: patient@test.com
     name: محمد أحمد
     role: patient
     phone: +966501234567
     isVerified: true
     isBlocked: false
     createdAt: [timestamp]
     additionalData: {
       walletBalance: 100.0
     }
     ```

### Create Test Doctor (Already Verified)
1. Add Authentication user: `doctor@test.com` / `Test123!`
2. Copy UID
3. Add Firestore document with fields:
   ```
   uid: [UID]
   email: doctor@test.com
   name: د. أحمد علي
   role: doctor
   phone: +966509876543
   specialization: قلب وأوعية دموية
   experience: 5-10 سنوات
   isVerified: true  ← IMPORTANT!
   isBlocked: false
   isOnline: true
   latitude: 24.7136
   longitude: 46.6753
   averageRating: 4.5
   reviewCount: 10
   createdAt: [timestamp]
   certificateUrls: []
   additionalData: {
     walletBalance: 0.0
   }
   ```

---

## 7️⃣ Configure App Settings in Firestore

### Create Exchange Rates Document
1. Go to **"Firestore Database"**
2. Click **"Start collection"** (or navigate to existing)
3. Collection ID: `settings`
4. Document ID: `exchangeRates`
5. Add field:
   ```javascript
   rates: {
     SAR: 1.0,
     USD: 3.75,
     EUR: 4.10,
     YER: 0.0015
   }
   ```
6. Click **"Save"**

---

## 8️⃣ Initialize Wallets Collection

### Create Wallet for Admin
1. Go to **"Firestore Database"**
2. Click **"Start collection"**: `wallets`
3. Document ID: `admin_commission`
4. Add fields:
   ```javascript
   userId: "admin_commission"
   balances: {
     SAR: 0.0
   }
   createdAt: [timestamp]
   ```

---

## 9️⃣ Verify Setup

### Checklist ✅
- [ ] Authentication → Email/Password enabled
- [ ] Firestore Database created
- [ ] Firestore Security Rules deployed
- [ ] Storage enabled and rules configured
- [ ] FCM enabled
- [ ] Admin user created in Authentication
- [ ] Admin user document created in Firestore with `role: admin` and `isVerified: true`
- [ ] Settings collection created (optional)
- [ ] Wallets collection created (optional)

---

## 🔟 Test Authentication Flow

### Test Admin Login
1. Open your Flutter app
2. Click **"مسؤول"** (Admin)
3. Enter:
   - Email: `admin@heart-emergency.com`
   - Password: `Admin123!@#`
4. Click **"تسجيل الدخول"**
5. ✅ Should redirect to Admin Dashboard

### Test Patient Signup
1. Open app → Click **"مريض"** (Patient)
2. Toggle to signup mode
3. Fill form with test data
4. Click **"إنشاء الحساب"**
5. ✅ Should create user and redirect to Patient Dashboard

### Test Doctor Signup
1. Open app → Click **"طبيب"** (Doctor)
2. Toggle to signup mode
3. Fill form and upload test files
4. Click **"إنشاء الحساب"**
5. ✅ Should create user and redirect to "Verification Pending" screen

### Verify Doctor (Admin Action)
1. Login as admin
2. Go to **Firebase Console** → **Firestore**
3. Find the doctor document in `users` collection
4. Edit the document
5. Change `isVerified: false` to `isVerified: true`
6. Doctor can now login and access dashboard

---

## 🔧 Troubleshooting

### Issue 1: "Permission Denied" errors
**Solution**: Make sure Firestore rules are properly deployed from `firestore.rules`

### Issue 2: Can't login as admin
**Solution**: 
1. Verify admin user exists in Authentication
2. Verify admin document exists in Firestore `/users/{uid}`
3. Verify `role: "admin"` and `isVerified: true`
4. UIDs must match between Authentication and Firestore

### Issue 3: Doctor can't upload files
**Solution**: Check Storage rules are deployed correctly

### Issue 4: No push notifications
**Solution**: 
1. Verify FCM is enabled
2. Check `google-services.json` is in `android/app/`
3. Rebuild the app after adding `google-services.json`

### Issue 5: "User not found" after signup
**Solution**: Check Firestore rules allow write access for new users

---

## 📊 Monitor Usage

### View Real-time Data
- **Authentication**: See all users in Authentication → Users tab
- **Firestore**: Browse data in Firestore Database → Data tab
- **Storage**: See uploaded files in Storage → Files tab

### Check Logs
- **Functions logs**: Cloud Functions → Logs
- **Rules evaluation**: Firestore → Rules → Playground (test rules)

---

## 🚨 Important Security Notes

1. ⚠️ **Never commit Firebase config files to public repos**
2. ⚠️ **Change default admin password immediately after first login**
3. ⚠️ **Regularly review Firestore and Storage rules**
4. ⚠️ **Enable App Check** for production (optional but recommended)
5. ⚠️ **Set up billing alerts** in Firebase Console → Usage

---

## 📱 Production Checklist

Before going live:
- [ ] Remove all test accounts
- [ ] Update admin credentials
- [ ] Enable App Check
- [ ] Set up backup strategy
- [ ] Configure usage alerts
- [ ] Test all user flows end-to-end
- [ ] Deploy production Firestore rules
- [ ] Set up monitoring and analytics
- [ ] Configure custom domain (if using)
- [ ] Enable 2FA for Firebase Console access

---

## 🎯 Quick Commands Reference

### Deploy Firestore Rules
```bash
firebase deploy --only firestore:rules
```

### Deploy Storage Rules
```bash
firebase deploy --only storage
```

### View Project Info
```bash
firebase projects:list
```

### Check Current Config
```bash
firebase use
```

---

## 📞 Support Resources

- **Firebase Console**: https://console.firebase.google.com/
- **Firebase Documentation**: https://firebase.google.com/docs
- **Firestore Security Rules**: https://firebase.google.com/docs/firestore/security/get-started
- **Storage Security Rules**: https://firebase.google.com/docs/storage/security/start

---

## ✅ Final Verification Steps

1. **Open Firebase Console**
2. **Check each section:**
   - ✅ Authentication has at least 1 admin user
   - ✅ Firestore has `users` collection with admin document
   - ✅ Firestore Rules are deployed (check Rules tab)
   - ✅ Storage is enabled with proper rules
   - ✅ FCM is enabled

3. **Test the app:**
   - ✅ Admin can login
   - ✅ Patient can signup
   - ✅ Doctor can signup (goes to pending)
   - ✅ Files upload successfully
   - ✅ Auto-login works after closing app

---

**🎉 Your Firebase Console is now fully configured!**

**Next Step**: Run `flutter run` and test all authentication flows.

If you encounter any issues, refer to the Troubleshooting section above.

