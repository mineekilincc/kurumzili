const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// Kullanıcı adı + şifre ile giriş kontrolü
exports.loginUser = functions.https.onCall(async (data, context) => {
  const { username, password } = data;

  if (!username || !password) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Kullanıcı adı ve şifre gereklidir."
    );
  }

  try {
    const snapshot = await admin.firestore()
      .collection("users")
      .where("username", "==", username)
      .where("password", "==", password)
      .limit(1)
      .get();

    if (snapshot.empty) {
      throw new functions.https.HttpsError(
        "not-found",
        "Kullanıcı adı veya şifre hatalı."
      );
    }

    const userData = snapshot.docs[0].data();
    return {
      success: true,
      message: "Giriş başarılı",
      user: userData
    };
  } catch (error) {
    throw new functions.https.HttpsError("internal", error.message);
  }
});
