# Web app (PWA) — deploy & install guide

The same app runs in a browser and can be **installed to the home screen** on
iPhone (via Safari) and Android (via Chrome) — no App Store needed. This is how
iPhone users get the app.

---

## Deploying the web app (you)

Hosted on **Firebase Hosting** (free, HTTPS, part of your Firebase project).

```bash
# One time: install the CLI and sign in (skip if already done for functions)
npm install -g firebase-tools
firebase login

# Every time you want to publish the latest web build:
flutter build web --release
firebase deploy --only hosting
```

After the first deploy your app is live at:

- **https://apatani-biisi-kheta.web.app**
- **https://apatani-biisi-kheta.firebaseapp.com**

Share that link with iPhone (and any) users. Re-run the two build/deploy commands
whenever you change the app and want the web version updated.

> A custom domain (e.g. `app.babfo.org`) can be added later in Firebase Console →
> Hosting → Add custom domain, if you want.

---

## How iPhone users install it (share this with them)

1. Open the link in **Safari** (must be Safari, not Chrome, on iPhone).
2. Tap the **Share** button (the square with an up-arrow, at the bottom).
3. Scroll down and tap **Add to Home Screen**.
4. Tap **Add** (top right).

The app icon appears on their home screen and opens fullscreen like a normal app.
(The app also shows a little reminder banner in Safari with these steps.)

## How Android users install it

Chrome usually shows an **"Install app"** / **"Add to Home screen"** prompt
automatically. If not: menu (⋮) → **Add to Home screen**.

---

## Good to know / limitations on iPhone

- **Install is manual.** iPhone Safari doesn't auto-prompt like Android — users
  must do the Share → Add to Home Screen steps. The in-app banner guides them.
- **Notifications on iPhone web** work only if the app is **installed** to the
  home screen **and** the phone is on **iOS 16.4 or newer**, and require the web
  push key to be set (see below). The Scripture archive and everything else work
  regardless.
- **First load** downloads the app engine (a few MB), then it's cached and fast.

## To enable notifications on the web later

Set the **VAPID key** in `lib/services/notification_service.dart`
(`webVapidKey`), from Firebase Console → Project settings → Cloud Messaging →
Web Push certificates → generate key pair. Then rebuild/redeploy. The
`web/firebase-messaging-sw.js` service worker is already in place.
