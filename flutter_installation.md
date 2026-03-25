


# 🚀 Flutter Development Environment Setup Guide


---

## 📂 Step 1: Flutter SDK Installation
1. **Download:** Get the latest Flutter SDK from [flutter.dev](https://docs.flutter.dev/get-started/install/windows).
2. **Extract:** Extract the zip file into a simple path like `C:\src\flutter` (Avoid `C:\Program Files` as it requires admin privileges).
3. **Set Environment Path:**
   - Search for **"Edit the system environment variables"** in Windows Start.<br>
     <img width="541" height="569" alt="image" src="https://github.com/user-attachments/assets/53a86305-133e-4ddf-ae3c-8d9fd0e8b4b2" />

   - Click **Environment Variables**.<br>
     <img width="684" height="759" alt="image" src="https://github.com/user-attachments/assets/d05a837b-805e-4134-801a-5417f3268d63" />

   - Under **User variables**, find the **Path** variable and click **Edit**.
   - Click **New** and paste the path to your Flutter bin folder: `C:\flutter\bin`[Your bin file path].
     <img width="608" height="164" alt="image" src="https://github.com/user-attachments/assets/6e4f570a-2552-435b-8238-63394e480dd8" />

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
1. Open your terminal (CMD or PowerShell) or VS code.
2. Run the following command:
   ```bash
   flutter doctor --android-licenses
   ```
3. Type `y` for every prompt until the process is complete.

---

## 💻 Step 4: Desktop Development (Visual Studio)
To build Flutter apps for Windows Desktop, you need the C++ workload.
1. **Download:** [Visual Studio Community](https://visualstudio.microsoft.com/downloads/).
   <img width="1278" height="496" alt="image" src="https://github.com/user-attachments/assets/ee0ad5ea-0481-4bf9-a5a0-581f21e1de40" />

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



