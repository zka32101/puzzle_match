import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

export const monthlySeasonReset = functions
  .region('asia-northeast1')
  .pubsub.schedule('1 of month 00:00')
  .timeZone('Asia/Tokyo')
  .onRun(async (context) => {
    try {
      const now = new Date();
      const lastSeason = (now.getFullYear() - 2025) * 12 + now.getMonth();

      // 新シーズン作成
      const newSeasonId = lastSeason + 1;
      const startDate = new Date(now.getFullYear(), now.getMonth(), 1);
      const endDate = new Date(now.getFullYear(), now.getMonth() + 1, 0);

      await db.collection('seasons').doc(`season_${newSeasonId}`).set({
        seasonId: newSeasonId,
        name: `Season ${newSeasonId} - ${startDate.getMonth() + 1}月`,
        startDate: startDate.toISOString(),
        endDate: endDate.toISOString(),
        isActive: true,
      });

      // 全ユーザーのランクをリセット
      const usersSnapshot = await db.collection('users').get();
      const batch = db.batch();

      for (const userDoc of usersSnapshot.docs) {
        batch.set(
          db.collection('user_seasons').doc(`${userDoc.id}_${newSeasonId}`),
          {
            userId: userDoc.id,
            seasonId: newSeasonId,
            tier: 0, // Bronze
            points: 0,
            rank: 99999,
            promoted: false,
            demoted: false,
          },
          { merge: true }
        );
      }

      await batch.commit();
      functions.logger.info(`Season ${newSeasonId} reset complete`);
    } catch (error) {
      functions.logger.error('Error during season reset:', error);
    }
  });

export const updateUserTier = functions
  .region('asia-northeast1')
  .https.onCall(async (data: { userId: string; points: number }, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Login required');
    }

    const { userId, points } = data;
    const now = new Date();
    const currentSeasonId = (now.getFullYear() - 2025) * 12 + now.getMonth() + 1;

    // ティア決定：0=Bronze, 1=Silver, 2=Gold, 3=Platinum, 4=Diamond
    let tier = 0;
    if (points >= 4500) tier = 4; // Diamond
    else if (points >= 3500) tier = 3; // Platinum
    else if (points >= 2500) tier = 2; // Gold
    else if (points >= 1500) tier = 1; // Silver

    await db
      .collection('user_seasons')
      .doc(`${userId}_${currentSeasonId}`)
      .update({
        points,
        tier,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

    return { success: true, tier };
  });
