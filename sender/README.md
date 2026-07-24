# tkbk sender

A small local tool to send **Scripture of the Day** and other announcements to
everyone who has the Apatani Biisi Kheta app — with an optional image — without
opening the Firebase Console each time. It shows a live preview of exactly how
the message will look in the app before you send.

## One-time setup

1. **Get your service account key** (this is what lets the tool send on your
   project's behalf):
   - Firebase Console → ⚙ **Project settings** → **Service accounts**
   - Click **Generate new private key** → a `.json` file downloads
   - Drop that file into the `sender/` folder. **You can keep its original
     name** (`…-firebase-adminsdk-….json`) — it's detected automatically.

   > ⚠️ This file is a secret. Any `…-firebase-adminsdk-….json` /
   > `service-account.json` here is already `.gitignore`d, so it won't be
   > committed. Never share it or put it in the app.

2. **Install Node dependencies** (Node.js must be installed):
   ```
   cd sender
   npm install
   ```

## Every time you want to send

**Easiest:** double-click **`Send Scripture.bat`** — it opens the composer in
your browser and starts the server.

Or from a terminal:
```
cd sender
npm start
```
Then open **http://localhost:4000** in your browser.

- Fill in the **title**, optional **reference** (e.g. `John 3:16`), and the
  **message/verse**.
- Optionally attach an **image** (upload a file, or paste a link). Uploaded
  files are stored in your Firebase Storage and delivered to the app.
- Watch the **live preview** on the right — it matches the app's devotional page.
- Click **Send to everyone**.

Press `Ctrl+C` in the terminal to stop the server when you're done.

## How it reaches users

The tool sends to the FCM topic **`all_users_tkbk`**, which every app install
subscribes to automatically (see `broadcastTopic` in
`lib/services/notification_service.dart`). The app turns the message into a
proper tray notification, saves it to the in-app **Scripture** archive, and —
when tapped — opens the devotional page.

## Notes

- **Bucket**: uploads go to `apatani-biisi-kheta.firebasestorage.app`. If your
  Storage bucket name ever changes, update `BUCKET` in `server.js`.
- **Custom data keys** sent (also usable directly from the Firebase Console
  composer under *Additional options → Custom data* if you ever prefer it):
  `type=scripture`, `title`, `reference`, `verse`, `imageUrl`, and optional
  `songNumber`.
- This is a local tool — it only runs on your computer while `npm start` is
  active. Nothing is hosted publicly.
