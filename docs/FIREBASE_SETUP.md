# Firebase Push Notifications — Hướng dẫn Setup

## 1. Tạo Firebase Project

1. Truy cập [Firebase Console](https://console.firebase.google.com)
2. Nhấn **"Create a project"** → nhập tên project (VD: `annhitra-app`)
3. Bỏ chọn Google Analytics (không cần thiết) → **"Create project"**

## 2. Thêm Android App

1. Trong Firebase Console → **Project Settings** → **"Add app"** → chọn **Android**
2. Nhập:
   - **Package name**: `com.annhitra.app` (kiểm tra trong `android/app/build.gradle` → `applicationId`)
   - **App nickname**: `An Nhi Trà Android`
3. Download `google-services.json`
4. Đặt file vào: `annhitra-flutter/android/app/google-services.json`
5. Cập nhật `android/build.gradle`:
   ```gradle
   // android/build.gradle (project-level)
   buildscript {
     dependencies {
       classpath 'com.google.gms:google-services:4.4.0'
     }
   }
   ```
6. Cập nhật `android/app/build.gradle`:
   ```gradle
   // android/app/build.gradle
   apply plugin: 'com.google.gms.google-services'
   ```

## 3. Thêm iOS App

1. Firebase Console → **"Add app"** → chọn **iOS**
2. Nhập:
   - **Bundle ID**: `com.annhitra.app` (kiểm tra trong Xcode → Runner → General → Bundle Identifier)
3. Download `GoogleService-Info.plist`
4. Mở Xcode → kéo thả `GoogleService-Info.plist` vào `Runner/Runner/` (chọn **Copy items if needed**)

### Cấu hình iOS Push Notifications:

1. Xcode → Runner → **Signing & Capabilities** → nhấn **"+ Capability"**
2. Thêm **"Push Notifications"**
3. Thêm **"Background Modes"** → tick ✅ "Remote notifications"

### Tạo APNs Key (bắt buộc cho iOS push):

1. Truy cập [Apple Developer](https://developer.apple.com/account/resources/authkeys/list)
2. **Keys** → **"+"** → tick **"Apple Push Notifications service (APNs)"**
3. Download file `.p8`
4. Firebase Console → **Project Settings** → **Cloud Messaging** → **Apple app configuration**
5. Upload file `.p8` → nhập **Key ID** và **Team ID**

## 4. Cấu hình Backend (Node.js)

### Tạo Service Account Key:

1. Firebase Console → **Project Settings** → **Service accounts**
2. Nhấn **"Generate new private key"** → download file JSON
3. Đặt file ở: `annhitra-node-backend/firebase-service-account.json`
4. **QUAN TRỌNG**: Thêm vào `.gitignore`:
   ```
   firebase-service-account.json
   ```

### Cập nhật `.env`:

```bash
FIREBASE_SERVICE_ACCOUNT_PATH=./firebase-service-account.json
```

### Cập nhật `notifications.ts`:

Thay đoạn scaffold Firebase bằng code thực:

```typescript
import * as admin from "firebase-admin";

// Initialize Firebase Admin SDK
const serviceAccount = require(
  process.env.FIREBASE_SERVICE_ACCOUNT_PATH ||
    "./firebase-service-account.json",
);
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// Trong hàm send notification:
async function sendPush(token: string, title: string, body: string) {
  await admin.messaging().send({
    token,
    notification: { title, body },
    apns: {
      payload: { aps: { sound: "default", badge: 1 } },
    },
    android: {
      notification: { sound: "default", channelId: "default" },
    },
  });
}
```

## 5. Flutter Dependencies

Đã có sẵn hoặc cần thêm vào `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^3.0.0
  firebase_messaging: ^15.0.0
```

Chạy:

```bash
flutter pub add firebase_core firebase_messaging
```

### Khởi tạo Firebase trong `main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Request notification permission
  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // Get FCM token
  final token = await messaging.getToken();
  print('FCM Token: $token');
  // → Gửi token này lên backend qua: POST /api/notifications/register

  runApp(const ProviderScope(child: AnNhiTraApp()));
}
```

## 6. Apple App Store Compliance

Để Apple phê duyệt, cần đảm bảo:

- ✅ **Có toggle tắt/bật thông báo** trong Settings (đã implement: `POST /api/notifications/toggle`)
- ✅ **Request permission trước khi gửi** (dùng `requestPermission()`)
- ✅ **Privacy Policy** phải ghi rõ việc sử dụng push notifications
- ✅ **App mô tả trong App Store Connect** phải ghi rõ tính năng thông báo
- ✅ **Không spam** — chỉ gửi thông báo liên quan đến đơn hàng, khuyến mãi do admin gửi

## 7. Checklist Deploy

| Step                                      | Status |
| ----------------------------------------- | ------ |
| Tạo Firebase project                      | ⬜     |
| Thêm Android app + `google-services.json` | ⬜     |
| Thêm iOS app + `GoogleService-Info.plist` | ⬜     |
| Upload APNs key (.p8)                     | ⬜     |
| Tạo Service Account key cho backend       | ⬜     |
| Cập nhật `.env` trên VPS                  | ⬜     |
| Thêm Firebase dependencies vào Flutter    | ⬜     |
| Test push notification                    | ⬜     |
