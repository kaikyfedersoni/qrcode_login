const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { setGlobalOptions } = require("firebase-functions/v2");
const admin = require("firebase-admin");
admin.initializeApp();

setGlobalOptions({ region: "southamerica-east1" });

exports.notifyTeacherOnNewDevice = onDocumentCreated("alerts/{alertId}", async (event) => {
  const alertData = event.data.data();

  if (!alertData) {
    console.log("Nenhum dado encontrado no alerta.");
    return null;
  }

  console.log("Novo alerta detectado:", alertData);

  const teachersRef = admin.firestore().collection("users");
  const teachersSnapshot = await teachersRef.where("role", "==", "teacher").get();

  if (teachersSnapshot.empty) {
    console.log("Nenhum professor encontrado para notificar.");
    return null;
  }

  const message = `
🚨 *Alerta de novo dispositivo detectado!*
Usuário: ${alertData.email}
Novo dispositivo: ${alertData.newDevice}
Antigo dispositivo: ${alertData.oldDevice}
Data: ${alertData.timestamp?.toDate?.() || alertData.timestamp}
  `;

  const promises = teachersSnapshot.docs.map(async (teacherDoc) => {
    const teacher = teacherDoc.data();
    console.log(`Professor ${teacher.email} notificado.`);
    // Aqui poderia ir uma integração com SendGrid, FCM, etc.
  });

  await Promise.all(promises);
  console.log("Notificação enviada com sucesso!");
  return null;
});
