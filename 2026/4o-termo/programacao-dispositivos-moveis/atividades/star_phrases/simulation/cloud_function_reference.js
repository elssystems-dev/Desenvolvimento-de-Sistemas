const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();
const db = admin.firestore();

exports.dailyQuoteOfTheDay = onSchedule(
  {
    schedule: "1 0 * * *",
    timeZone: "America/Sao_Paulo",
    retryCount: 3,
  },
  async (event) => {
    console.log("Iniciando execução da Cloud Function: Atualizar Citação do Dia...");

    try {
      const response = await axios.get("https://favqs.com/api/qotd", {
        headers: { Accept: "application/json" },
        timeout: 5000,
      });

      const quoteData = response.data?.quote;
      if (!quoteData || !quoteData.body) {
        throw new Error("Resposta da API de citações inválida.");
      }

      const phrase = quoteData.body;
      const author = quoteData.author || "Autor Desconhecido";

      await db.collection("dailyContent").doc("quoteOfTheDay").set(
        {
          phrase: phrase,
          quote: phrase,
          author: author,
          imageUrl:
            "https://upload.wikimedia.org/wikipedia/commons/8/84/Martin_Luther_King_Jr_NYWTS.jpg?utm_source=pt.wikipedia.org&utm_campaign=index&utm_content=original",
          source: "API FavQs via Cloud Function Agendada",
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          scheduleCron: "1 0 * * *",
        },
        { merge: true }
      );

      console.log(`Citação do dia atualizada com sucesso: "${phrase}" - ${author}`);
      return { success: true };
    } catch (error) {
      console.error("Erro ao executar Cloud Function de citação diária:", error.message);
      throw error;
    }
  }
);
