# 🔥 Firebase Setup Guide

## Step 1: Download Configuration Files

### For Android:
1. Go to your Firebase Console → Project Settings → General → Your apps
2. Click "Add app" → Android
3. Use package name: `com.example.social_tinder`
4. Download `google-services.json`
5. Place it in `android/app/` directory

### For iOS:
1. Go to your Firebase Console → Project Settings → General → Your apps
2. Click "Add app" → iOS
3. Use bundle ID: `com.example.socialTinder`
4. Download `GoogleService-Info.plist`
5. Place it in `ios/Runner/` directory

## Step 2: Enable Firebase Services

### Authentication:
1. Go to Authentication → Sign-in method
2. Enable "Email/Password"

### Firestore Database:
1. Go to Firestore Database → Create database
2. Start in test mode (we'll add security rules later)
3. Choose a location close to your users

### Storage:
1. Go to Storage → Get started
2. Start in test mode

## Step 3: Security Rules

### Firestore Rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Posts can be read by all authenticated users, written by post owner
    match /posts/{postId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == resource.data.userId;
    }
    
    // Matches can be read/written by users in the match
    match /matches/{matchId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in resource.data.users;
    }
    
    // Messages can be read/written by users in the match
    match /matches/{matchId}/messages/{messageId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in get(/databases/$(database)/documents/matches/$(matchId)).data.users;
    }
    
    // Restaurants can be read by all, written by owner
    match /restaurants/{restaurantId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        request.auth.uid == resource.data.ownerId;
    }
    
    // Events can be read by all, written by promoter
    match /events/{eventId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        request.auth.uid == resource.data.promoterId;
    }
    
    // Tickets can be read/written by ticket owner
    match /tickets/{ticketId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
  }
}
```

### Storage Rules:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Profile photos
    match /profile_photos/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Post images
    match /post_images/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Restaurant images
    match /restaurant_images/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Event images
    match /event_images/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

## Step 4: Test the Connection

1. Run the app: `flutter run`
2. Try to sign up with a new account
3. Check Firebase Console to see if the user was created
4. Try uploading a profile photo
5. Check Storage to see if the image was uploaded

## Step 5: Environment Variables (Optional)

Create a `.env` file in your project root:
```
FIREBASE_API_KEY=your_api_key_here
FIREBASE_PROJECT_ID=your_project_id_here
```

## Troubleshooting

### Common Issues:

1. **"google-services.json not found"**
   - Make sure the file is in `android/app/` directory
   - Check that the package name matches

2. **"Firebase not initialized"**
   - Make sure you've enabled the services in Firebase Console
   - Check that the configuration files are correct

3. **"Permission denied"**
   - Update the security rules in Firebase Console
   - Make sure authentication is enabled

4. **"Image upload failed"**
   - Check Storage rules
   - Make sure Storage is enabled in Firebase Console

## Next Steps

After setting up Firebase:
1. Test all features (auth, profile, social, dating, restaurants, events, chat)
2. Customize the security rules for production
3. Set up proper error handling
4. Add analytics and crash reporting
5. Configure push notifications

## Support

If you encounter issues:
1. Check Firebase Console logs
2. Verify configuration files are correct
3. Test with a simple Firebase app first
4. Check Flutter Firebase documentation 