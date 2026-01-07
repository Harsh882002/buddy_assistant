# Buddy Assistant - Zero Compile Setup

## 1. Project Setup
You have the full code structure in `buddy_assistant/`.
To get your APK, you do NOT need to install anything on your laptop (except Git).

## 2. Pushing to GitHub
1. Create a new repository on GitHub (e.g., `buddy-voice-assistant`).
2. Open a terminal in `buddy_assistant/` folder.
3. Run:
   ```bash
   git init
   git add .
   git commit -m "Initial commit of Buddy"
   # Replace URL with your new repo
   git remote add origin https://github.com/YOUR_USERNAME/buddy-voice-assistant.git
   git push -u origin master
   ```

## 3. Building the APK
1. Go to your GitHub Repository page.
2. Click the **Actions** tab.
3. You should see a workflow running named "Build Buddy APK".
4. Wait for it to turn Green (approx 5-8 minutes).
5. Click on the workflow run.
6. Scroll down to **Artifacts** section.
7. Click **buddy-assistant-release** to download the ZIP.

## 4. Installation
1. Unzip the downloaded file to get `app-debug.apk`.
2. Send this APK to your phone (USB, Drive, WhatsApp, etc.).
3. Tap to install. (Allow "Install from Unknown Sources").
4. **IMPORTANT**:
   - Open the App.
   - Accept ALL permissions (Microphone, Phone, Notification).
   - Tap "Start Listening".
   - Say **"Hey Buddy"**.

## 5. Troubleshooting
- **Crash on Start?** Check if you added the Vosk model to `assets/models/`. The code expects `assets/models/vosk-model-small-en-us-0.15`. 
  - *Correction*: The CI script attempts to bundle what is in the folder. If you didn't download the model, the app will launch but STT won't work.
  - **Download Model**: [Vosk Models](https://alphacephei.com/vosk/models).
  - Unzip `vosk-model-small-en-us-0.15` into `buddy_assistant/assets/models/`.
  
## 6. Voice Commands
- "Flashlight on" / "Flashlight off"
- "Call Mom" / "Call Dad"
- "Open Spotify" / "Open WhatsApp"
- "Set volume to 50"
- "Send SMS to Mom I'm coming home"
