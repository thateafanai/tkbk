// Cloud Functions for Apatani Biisi Kheta.
//
//  • sendScheduledScriptures — runs daily at 5:00 AM IST and pushes any
//    scripture whose scheduledFor date has arrived and hasn't been sent yet.
//  • sendScriptureNow — callable from the admin page to push a scripture
//    immediately.
//
// Both send to the FCM topic `all_users_tkbk` (every app install subscribes)
// and write the same fields the app understands, so a tap opens the exact
// scripture. Deploy: see functions/README.md.
const { onSchedule } = require('firebase-functions/v2/scheduler');
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const logger = require('firebase-functions/logger');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue, Timestamp } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');

initializeApp();
const db = getFirestore();

const REGION = 'us-central1';
const TOPIC = 'all_users_tkbk';
const ADMIN_EMAIL = 'fpthatea@gmail.com';

// Builds and sends the FCM push for one scripture, then marks it sent.
async function pushScripture(id, data) {
  const title = (data.title || 'Scripture of the Day').trim();
  const reference = (data.reference || '').trim();
  const verse = (data.verse || '').trim();
  const imageUrl = (data.imageUrl || '').trim();

  const messageData = { type: 'scripture', title, reference, verse, scriptureId: id };
  if (imageUrl) messageData.imageUrl = imageUrl;
  if (data.songNumber) messageData.songNumber = String(data.songNumber);

  await getMessaging().send({
    topic: TOPIC,
    notification: { title, body: verse || reference, ...(imageUrl ? { imageUrl } : {}) },
    data: messageData,
    android: {
      priority: 'high',
      notification: { channelId: 'high_importance_channel', ...(imageUrl ? { imageUrl } : {}) },
    },
    apns: {
      payload: { aps: { 'mutable-content': 1, sound: 'default' } },
      ...(imageUrl ? { fcmOptions: { imageUrl } } : {}),
    },
  });

  await db.collection('scriptures').doc(id).update({
    sent: true,
    sentAt: FieldValue.serverTimestamp(),
    // Ensure it's visible in the app archive now (keeps an existing value).
    visibleFrom: data.visibleFrom || FieldValue.serverTimestamp(),
  });
}

// Daily auto-sender. Change the cron/timeZone below to adjust when it fires.
exports.sendScheduledScriptures = onSchedule(
  { schedule: '0 5 * * *', timeZone: 'Asia/Kolkata', region: REGION },
  async () => {
    const now = Timestamp.now();
    // Single inequality (no composite index needed); filter `sent` in code.
    const snap = await db.collection('scriptures').where('scheduledFor', '<=', now).get();
    let sent = 0;
    for (const doc of snap.docs) {
      if (doc.data().sent === true) continue;
      try {
        await pushScripture(doc.id, doc.data());
        sent++;
        logger.info(`Sent scheduled scripture ${doc.id}`);
      } catch (e) {
        logger.error(`Failed sending ${doc.id}: ${e.message}`);
      }
    }
    logger.info(`Scheduled run complete: ${sent} sent of ${snap.size} due.`);
  }
);

// On-demand send, called from the browser admin page (signed-in admin only).
exports.sendScriptureNow = onCall({ region: REGION }, async (request) => {
  if (request.auth?.token?.email !== ADMIN_EMAIL) {
    throw new HttpsError('permission-denied', 'Admin only.');
  }
  const scriptureId = request.data?.scriptureId;
  if (!scriptureId) {
    throw new HttpsError('invalid-argument', 'scriptureId is required.');
  }
  const doc = await db.collection('scriptures').doc(scriptureId).get();
  if (!doc.exists) {
    throw new HttpsError('not-found', 'Scripture not found.');
  }
  await pushScripture(scriptureId, doc.data());
  return { ok: true };
});
