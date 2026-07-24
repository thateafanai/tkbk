// Handles FCM push messages while the web app is in the background or
// closed. Config values here are the public web client config (safe to
// expose), matching lib/firebase_options.dart.
importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyBHmRgL1f-c3Wj7ezoS5QPvkv4SZZ1RlyE',
  appId: '1:371710579657:web:50dc0cb8b34ad3ac4f4e18',
  messagingSenderId: '371710579657',
  projectId: 'apatani-biisi-kheta',
  authDomain: 'apatani-biisi-kheta.firebaseapp.com',
  storageBucket: 'apatani-biisi-kheta.firebasestorage.app',
});

firebase.messaging();
