const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { setGlobalOptions } = require("firebase-functions/v2");
const admin = require("firebase-admin");
admin.initializeApp();
setGlobalOptions({ region: "southamerica-east1" });
// Executa quando um documento é criado na coleção "alerts"
exports.notifyTeacherOnNewDevice = onDocumentCreated("alerts/{alertId}", async (event) => {
  const alertData = event.data.data();

  const teachersRef = admin.firestore().collection("users");
  const teachersSnapshot = await teachersRef
    .where("role", "==", "teacher")
    .get();

  const message = `
🚨 *Alerta de novo dispositivo detectado!*
Usuário: ${alertData.email}
Novo dispositivo: ${alertData.newDevice}
Antigo dispositivo: ${alertData.oldDevice}
Data: ${alertData.timestamp.toDate()}
  `;

  // Envia notificação (ou e-mail) para todos os professores
  const promises = teachersSnapshot.docs.map(async (teacherDoc) => {
    const teacher = teacherDoc.data();
    console.log(`Professor ${teacher.email} notificado.`);
    // Aqui você pode integrar com Email API, SendGrid, ou Push Notification
  });

  await Promise.all(promises);
  console.log("Notificação enviada com sucesso!");
  return null;
});
