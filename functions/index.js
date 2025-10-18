const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.firestore();

// Helper: Haversine distance in KM
function haversineDistanceKm(lat1, lon1, lat2, lon2) {
  const toRad = (v) => (v * Math.PI) / 180;
  const R = 6371; // km
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

// ✅ إشعار لما المريض يعمل طلب جديد
exports.onRequestCreated = functions.firestore
  .document("requests/{requestId}")
  .onCreate(async (snap, context) => {
    const requestData = snap.data();
    const doctorId = requestData.doctorId;
    const patientName = requestData.patientName || "مريض";

    try {
      const doctorDoc = await db.collection("users").doc(doctorId).get();
      if (!doctorDoc.exists) return;

      const token = doctorDoc.data().fcmToken;
      if (!token) return;

      const message = {
        notification: {
          title: "طلب جديد من مريض 🩺",
          body: `قام ${patientName} بإرسال طلب جديد إليك.`,
        },
        token: token,
        data: {
          type: "new_request",
          requestId: context.params.requestId,
        },
      };

      await admin.messaging().send(message);
      console.log("📨 Notification sent to doctor:", doctorId);
    } catch (error) {
      console.error("❌ Error sending to doctor:", error);
    }
  });

// ✅ إشعار لما الدكتور يقبل أو يرفض الطلب
exports.onRequestUpdated = functions.firestore
  .document("requests/{requestId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // لو الحالة ما اتغيرتش نخرج
    if (before.status === after.status) return;

    const patientId = after.patientId;
    const newStatus = after.status;

    try {
      const patientDoc = await db.collection("users").doc(patientId).get();
      if (!patientDoc.exists) return;

      const token = patientDoc.data().fcmToken;
      if (!token) return;

      let title = "";
      let body = "";

      if (newStatus === "accepted") {
        title = "تم قبول طلبك ❤️";
        body = "لقد تم قبول طلبك من الطبيب.";
      } else if (newStatus === "rejected") {
        title = "تم رفض طلبك ❌";
        body = "قام الطبيب برفض طلبك.";
      } else {
        return;
      }

      const message = {
        notification: { title, body },
        token: token,
        data: {
          type: "request_update",
          requestId: context.params.requestId,
          status: newStatus,
        },
      };

      await admin.messaging().send(message);
      console.log("📨 Notification sent to patient:", patientId);
    } catch (error) {
      console.error("❌ Error sending to patient:", error);
    }
  });

// ✅ Update ETA when a request becomes accepted
exports.onRequestAcceptedEta = functions.firestore
  .document("requests/{requestId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // Only when status transitions to 'accepted'
    if ((before.status === after.status) || after.status !== 'accepted') return;

    try {
      const requestId = context.params.requestId;
      const patientLocation = after.patientLocation; // Firestore GeoPoint
      const doctorId = after.doctorId;

      if (!patientLocation || !doctorId) return;

      const doctorDoc = await db.collection('users').doc(doctorId).get();
      if (!doctorDoc.exists) return;

      const doctorData = doctorDoc.data() || {};
      const doctorLocation = doctorData.location; // Firestore GeoPoint
      if (!doctorLocation) return;

      // Calculate distance using Haversine (same idea as app OSM logic)
      const distanceKm = haversineDistanceKm(
        patientLocation.latitude,
        patientLocation.longitude,
        doctorLocation.latitude,
        doctorLocation.longitude
      );

      // ETA in minutes at 40 km/h
      const etaMinutes = Math.ceil((distanceKm / 40) * 60);

      await db.collection('requests').doc(requestId).update({
        distanceKm: Number(distanceKm.toFixed(2)),
        etaMinutes: etaMinutes,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(`ETA updated for request ${requestId}: ${etaMinutes} minutes`);
    } catch (error) {
      console.error('❌ Error updating ETA:', error);
    }
  });
