# FireBase set Up
---
## Go to firebase console https://console.firebase.google.com
## then create a project <br>
<img width="580" height="302" alt="image" src="https://github.com/user-attachments/assets/b6580cdc-208e-4f48-a0a4-934f3144616c" /><br>
## click continue<br>
<img width="1738" height="868" alt="image" src="https://github.com/user-attachments/assets/0c0beb53-dfa9-496d-b83c-91219825dedf" /><br>
<img width="550" height="164" alt="image" src="https://github.com/user-attachments/assets/2ec0aad4-0bf1-4753-8de9-154aa0be306a" /><br>
<img width="795" height="847" alt="image" src="https://github.com/user-attachments/assets/6e528e02-59ab-4416-9935-84debb42d80c" /><br>

## Go to VS code -> android -> app -> build.gradle.kts
<img width="876" height="385" alt="image" src="https://github.com/user-attachments/assets/e1eda348-51a6-40c7-be14-84972860a254" />
## copy the namespace and paste it into company name <br>
<img width="904" height="732" alt="image" src="https://github.com/user-attachments/assets/b679ef52-703d-4dec-aed6-20739330c4b8" />

## download the json file. copy and paste it into androi-> app. [Right click on the app]
## click next<br>

---

## copy the plugins
<img width="887" height="688" alt="image" src="https://github.com/user-attachments/assets/9a41da18-05d7-4de0-b3d7-ce038c11f6d6" />

## paste the plugins in the start of android-> build.gradle.kts <br>
<img width="1120" height="452" alt="image" src="https://github.com/user-attachments/assets/0db79b8f-28b1-4ae2-931a-71ab9fa9f6bd" />

## In your Module (app-level) Gradle file (android/app/build.gradle.kts
<img width="956" height="449" alt="image" src="https://github.com/user-attachments/assets/1bc1a8f8-ba1e-4936-b902-ccec01edf3f5" /><br>

---
## now go to VS code and run in the terminal
```flutter pub get firebase_core```
```flutter pub add firebase_core```

---
## go to main.dart<br>
<img width="742" height="294" alt="image" src="https://github.com/user-attachments/assets/d68e3cc1-9adf-4f49-b611-c0917fdbf7c8" />

## replace the void main() function:
```
void main() async { 
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); 
  runApp(const QuizApp());
}
```
## import :
```
import 'package:firebase_core/firebase_core.dart';
```
<img width="856" height="261" alt="image" src="https://github.com/user-attachments/assets/a6fb4851-fc42-4dc6-be6f-83816b02a608" />












