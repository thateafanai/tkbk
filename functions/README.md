# tkbk Cloud Functions

Two functions power the browser admin page's **Send now** and **Schedule**:

- **`sendScheduledScriptures`** — runs every day at **6:00 AM IST** and pushes any
  scripture whose scheduled date has arrived (and hasn't been sent). This is what
  lets you prepare a week/month ahead and have each go out automatically.
- **`sendScriptureNow`** — called by the admin page's **Send now** button to push a
  scripture immediately (signed-in admin only).

Both send to the FCM topic `all_users_tkbk` and mark the scripture as sent.

## Deploy (one time, then again whenever you change `index.js`)

You need the Firebase CLI and to be on the **Blaze** plan (you are).

```bash
# 1. Install the CLI once (if you don't have it):
npm install -g firebase-tools

# 2. Sign in once:
firebase login

# 3. From the PROJECT ROOT (d:\AppDevelopments\tkbk), install deps and deploy:
cd functions
npm install
cd ..
firebase deploy --only functions
```

The first deploy will ask to enable a few Google APIs (Cloud Functions, Cloud
Build, Cloud Scheduler) — say **yes**. It takes a couple of minutes.

## After deploying

- The **scheduled** job is created automatically (Cloud Scheduler). Check it in
  the Firebase Console → **Functions**, or Google Cloud Console → Cloud Scheduler.
- Test **Send now** from the admin page (`docs/scripture-admin.html`) — it calls
  `sendScriptureNow`. If it errors with *permission-denied*, make sure you're
  signed in as `fpthatea@gmail.com`.
- View logs: `firebase functions:log` (or `npm run logs` in this folder).

## Changing the daily send time

Edit the `schedule` line in `index.js`:

```js
{ schedule: '0 6 * * *', timeZone: 'Asia/Kolkata', region: REGION }
```

`'0 6 * * *'` is standard cron = "minute 0 of hour 6, every day". For example
`'30 5 * * *'` = 5:30 AM. Redeploy after changing.

## Notes

- The admin email is hard-coded as `fpthatea@gmail.com` in `index.js` (guards the
  callable). Change it there if the admin ever changes.
- Region is `us-central1`; the admin page's `getFunctions(app, 'us-central1')`
  must match it.
