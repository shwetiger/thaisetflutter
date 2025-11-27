importScripts("https://www.gstatic.com/firebasejs/8.6.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.6.1/firebase-messaging.js");
importScripts("https://www.gstatic.com/firebasejs/8.6.1/firebase-firestore.js");
firebase.initializeApp({
apiKey: "AIzaSyAZ9jOxANqlzWIAuh6ysjYJw-PrBe3B3EI",
  authDomain: "thai2dlive-ce088.firebaseapp.com",
  projectId: "thai2dlive-ce088",
  storageBucket: "thai2dlive-ce088.appspot.com",
  messagingSenderId: "963689075560",
  appId: "1:963689075560:web:f78cde8c06529349bcfcdd",
  measurementId: "G-9CRB6HJC31"
});
const messaging = firebase.messaging();

messaging.setBackgroundMessageHandler(function (payload) {
    const promiseChain = clients
        .matchAll({
            type: "window",
            includeUncontrolled: true
        })
        .then(windowClients => {
            for (let i = 0; i < windowClients.length; i++) {
                const windowClient = windowClients[i];
                windowClient.postMessage(payload);
            }
        })
        .then(() => {
            return registration.showNotification("New Message");
        });
    return promiseChain;
});
self.addEventListener('notificationclick', function (event) {
    console.log('notification received: ', event)
});