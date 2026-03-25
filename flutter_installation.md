


# 🚀 Flutter Development Environment Setup Guide


---

## 📂 Step 1: Flutter SDK Installation
1. **Download:** Get the latest Flutter SDK from [flutter.dev](https://docs.flutter.dev/get-started/install/windows).
2. **Extract:** Extract the zip file into a simple path like `C:\src\flutter` (Avoid `C:\Program Files` as it requires admin privileges).
3. **Set Environment Path:**
   - Search for **"Edit the system environment variables"** in Windows Start.
   - Click **Environment Variables**.
   - Under **User variables**, find the **Path** variable and click **Edit**.
   - Click **New** and paste the path to your Flutter bin folder: `C:\flutter\bin`.
   - Click **OK** on all windows.

---

## 🤖 Step 2: Android Studio & SDK Setup
1. **Download:** [Android Studio](https://developer.android.com/studio).
2. **SDK Configuration:**
   - Open Android Studio.
   - Go to **Settings > Languages & Frameworks > Android SDK**.
   - Select the **SDK Tools** tab.
   - **Check and Install:**
     - [x] Android SDK Build-Tools
     - [x] Android SDK Command-line Tools (latest)
     - [x] Android Emulator
     - [x] Android Emulator Hypervisor Driver
     - [x] Android SDK Platform-Tools
3. **Plugins:**
   - Go to **Settings > Plugins**.
   - Search for **Flutter** and click **Install** (This will automatically install the Dart plugin).
   - **Restart** Android Studio.

---

## 🛠️ Step 3: Android Toolchain & Licenses
Before building apps, you must accept the Android licenses.
1. Open your terminal (CMD or PowerShell).
2. Run the following command:
   ```bash
   flutter doctor --android-licenses
   ```
3. Type `y` for every prompt until the process is complete.

---

## 💻 Step 4: Desktop Development (Visual Studio)
To build Flutter apps for Windows Desktop, you need the C++ workload.
1. **Download:** [Visual Studio Community](https://visualstudio.microsoft.com/downloads/).
2. **Installer Selection:** - During installation, select the checkbox for **"Desktop development with C++"**.
   - This installs the necessary MSVC v143 build tools and Windows SDK.

---

## 📱 Step 5: Emulator Setup (Virtual Device)
1. In Android Studio, click the **Device Manager** icon (usually on the right sidebar).
2. Click **Create Device**.
3. Choose a device (e.g., **Pixel 8**) and click **Next**.
4. Download a System Image (e.g., **API 35**).
5. Click **Finish**. You can now launch this phone using the **Play** button.

---

## 🔥 Step 6: Firebase Integration (google-services.json)
If you are using Firebase, you must place your configuration file in the correct directory.
1. **File Location:** Move your downloaded `google-services.json` to:
   `android/app/google-services.json`
2. **Config Example:** Ensure your `storage_bucket` matches your project:
   ```json
   "storage_bucket": "adda-aa69b.firebasestorage.app"
   ```

---

## ✅ Final Verification
Run this command to ensure everything is "Green":
```bash
flutter doctor -v
```

---

### 💡 Useful Commands
| Command | Purpose |
| :--- | :--- |
| `flutter clean` | Clears build cache (Fixes many errors) |
| `flutter pub get` | Downloads app dependencies |
| `flutter run` | Launches the app on a connected device |
```


