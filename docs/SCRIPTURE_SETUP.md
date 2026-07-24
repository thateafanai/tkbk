# Scripture of the Day — setup

| Part | What it is | Where |
|---|---|---|
| **The app** | Reads the shared archive from Firestore; shows the "Scripture" inbox + devotional page; receives push notifications | Flutter app |
| **Browser admin** | Add / edit / schedule / **Send now** — everything from one page, no terminal | `docs/scripture-admin.html` |
| **Cloud Functions** | The engine behind Send now + the daily auto-send of scheduled scriptures | `functions/` |
| **Sender** (optional/legacy) | The old local Node push tool — still works, but the admin page now does everything | `sender/` |

Everything reads/writes one Firestore collection: **`scriptures`**.

**The main workflow (once set up):** open `docs/scripture-admin.html` → sign in →
write a scripture → either leave the date empty (archive only), pick a date to
**schedule** it (auto-sends that morning), or hit **Send now**. No terminal needed.

---

## One-time Firebase setup

You must do these once in the [Firebase Console](https://console.firebase.google.com/project/apatani-biisi-kheta) — I can't do them for you.

### 1. Create the Firestore database
Console → **Firestore Database** → **Create database** → **Production mode** →
pick a location (e.g. `asia-south1`). (If it already exists, skip.)

### 2. Firestore security rules
Console → Firestore Database → **Rules** tab → paste this → **Publish**:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /scriptures/{doc} {
      allow read: if true;                                  // app reads publicly
      allow write: if request.auth != null
                   && request.auth.token.email == 'fpthatea@gmail.com';
    }
  }
}
```
Anyone can *read* scriptures (the app has no login); only you (signed in) can
*write*. The `sender/` tool bypasses these rules because it uses the admin key.

### 3. Storage security rules (for image uploads from the browser admin)
Console → **Storage** → **Rules** tab → paste → **Publish**:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /scripture_images/{img} {
      allow read: if true;
      allow write: if request.auth != null
                   && request.auth.token.email == 'fpthatea@gmail.com';
    }
  }
}
```

### 4. Enable Email/Password sign-in + create your admin user
Console → **Authentication** → **Get started** → **Sign-in method** →
enable **Email/Password**. Then **Users** tab → **Add user** →
email `fpthatea@gmail.com` + a password. That's what you'll log in with on the
admin page.

### 5. Deploy the Cloud Functions (for Send now + scheduling)
This enables the **Send now** button and the daily auto-send. Full steps are in
[`functions/README.md`](../functions/README.md). Short version:
```bash
npm install -g firebase-tools     # once
firebase login                    # once
cd functions && npm install && cd ..
firebase deploy --only functions
```
Say **yes** when it offers to enable the required Google APIs.

> Until the functions are deployed, the admin page still works for adding to the
> archive, but **Send now** and scheduled auto-send won't fire.

---

## Daily use — all from `docs/scripture-admin.html`

Open the page → sign in. For each scripture:
- **No date** → saved to the archive, visible in the app immediately, no push.
- **Pick a date** → it auto-sends as a notification that morning (6 AM IST). Prepare
  a whole week or month in advance.
- **Send now** (on any item) → pushes it to everyone right away.

> Host `scripture-admin.html` on GitHub Pages like your privacy policy, or just
> double-click the file to open it locally — both work.

The `sender/` Node tool is now optional — the admin page does everything.

---

## How a tap flows

Push notification → app shows it (with the book icon) → tap → opens the
devotional page for that exact scripture (matched by its Firestore id) → it's
also in the **Scripture** archive (bell icon on the home screen).

## Changing the daily send time

It's `0 6 * * *` (6 AM IST) in `functions/index.js`. See `functions/README.md`.
