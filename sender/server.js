// Local compose-and-send tool for Apatani Biisi Kheta.
// Sends a push notification (Scripture of the Day or an announcement) to every
// installed app, optionally with an image, without opening the Firebase Console.
//
// Setup: see README.md. In short:
//   1) Put your Firebase service account key at sender/service-account.json
//   2) npm install
//   3) npm start   → open http://localhost:4000
const express = require('express');
const multer = require('multer');
const admin = require('firebase-admin');
const path = require('path');
const fs = require('fs');

const PORT = 4000;
const TOPIC = 'all_users_tkbk'; // must match broadcastTopic in the Flutter app
const BUCKET = 'apatani-biisi-kheta.firebasestorage.app';

// Accept either service-account.json or the original filename Firebase gives
// the downloaded key (…-firebase-adminsdk-….json). Just drop it in this folder.
function findServiceAccount() {
  const explicit = path.join(__dirname, 'service-account.json');
  if (fs.existsSync(explicit)) return explicit;
  const match = fs
    .readdirSync(__dirname)
    .find((f) => /firebase-adminsdk.*\.json$/i.test(f) || /serviceaccount.*\.json$/i.test(f));
  return match ? path.join(__dirname, match) : null;
}

const SERVICE_ACCOUNT = findServiceAccount();

if (!SERVICE_ACCOUNT) {
  console.error(`
  ✗ No Firebase service account key found in this folder.

  Download it once from the Firebase Console:
    Project settings → Service accounts → Generate new private key
  Then drop the downloaded .json file into:
    ${__dirname}

  You can keep its original name (…-firebase-adminsdk-….json) — it will be
  detected automatically. It's a secret: it's git-ignored, never share it.
`);
  process.exit(1);
}

console.log(`  Using service account: ${path.basename(SERVICE_ACCOUNT)}`);

admin.initializeApp({
  credential: admin.credential.cert(require(SERVICE_ACCOUNT)),
  storageBucket: BUCKET,
});

const app = express();
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 8 * 1024 * 1024 }, // 8 MB
});
app.use(express.static(path.join(__dirname, 'public')));

// Uploads an image to Firebase Storage and returns a long-lived signed URL.
// Signed URLs work regardless of the bucket's public-access settings.
async function uploadImage(file) {
  const bucket = admin.storage().bucket();
  const ext = (file.originalname.split('.').pop() || 'jpg').toLowerCase().replace(/[^a-z0-9]/g, '');
  const dest = `scripture_images/${Date.now()}.${ext || 'jpg'}`;
  const target = bucket.file(dest);
  await target.save(file.buffer, { contentType: file.mimetype, resumable: false });
  const [url] = await target.getSignedUrl({ action: 'read', expires: '03-09-2491' });
  return url;
}

app.post('/send', upload.single('image'), async (req, res) => {
  try {
    const title = (req.body.title || 'Scripture of the Day').trim();
    const reference = (req.body.reference || '').trim();
    const verse = (req.body.verse || '').trim();
    const songNumber = (req.body.songNumber || '').trim();
    let imageUrl = (req.body.imageUrl || '').trim();

    if (!verse && !title) {
      return res.status(400).json({ ok: false, error: 'Add at least a title or a verse before sending.' });
    }

    if (req.file) {
      imageUrl = await uploadImage(req.file);
    }

    // Write to the shared Firestore archive first, so the pushed scripture
    // appears in everyone's in-app archive (including new installs), and grab
    // its id so a tap opens the exact document.
    const docRef = await admin.firestore().collection('scriptures').add({
      title,
      reference,
      verse,
      imageUrl: imageUrl || null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      visibleFrom: admin.firestore.FieldValue.serverTimestamp(),
      sent: true,
      sentAt: admin.firestore.FieldValue.serverTimestamp(),
      source: 'sender',
    });

    const data = { type: 'scripture', title, reference, verse, scriptureId: docRef.id };
    if (imageUrl) data.imageUrl = imageUrl;
    if (songNumber) data.songNumber = songNumber;

    const message = {
      topic: TOPIC,
      notification: {
        title: title || 'Scripture of the Day',
        body: verse || reference,
        ...(imageUrl ? { imageUrl } : {}),
      },
      data,
      android: {
        priority: 'high',
        notification: {
          channelId: 'high_importance_channel',
          ...(imageUrl ? { imageUrl } : {}),
        },
      },
      apns: {
        payload: { aps: { 'mutable-content': 1, sound: 'default' } },
        ...(imageUrl ? { fcmOptions: { imageUrl } } : {}),
      },
    };

    const id = await admin.messaging().send(message);
    console.log(`✓ Sent "${title}" → ${TOPIC} (id: ${id})`);
    res.json({ ok: true, id, imageUrl: imageUrl || null });
  } catch (e) {
    console.error('✗ Send failed:', e.message);
    res.status(500).json({ ok: false, error: e.message });
  }
});

app.listen(PORT, () => {
  console.log(`\n  📖  tkbk sender ready  →  http://localhost:${PORT}\n`);
});
