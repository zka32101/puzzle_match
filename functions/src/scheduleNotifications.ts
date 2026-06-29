import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();
const messaging = admin.messaging();

interface UserStats {
  userId: string;
  userName: string;
  currentRank: number;
  fcmToken?: string;
}

export const scheduleRankNotifications = functions
  .region('asia-northeast1')
  .pubsub.schedule('every day 20:00')
  .timeZone('Asia/Tokyo')
  .onRun(async (context) => {
    try {
      const today = new Date().toISOString().split('T')[0];
      const leaderboardRef = db.collection('leaderboards').doc(`puzzle_${today}_global`);
      const leaderboardDoc = await leaderboardRef.get();

      if (!leaderboardDoc.exists) {
        functions.logger.info('No leaderboard found for today');
        return;
      }

      const entries = leaderboardDoc.data()?.entries || [];
      const usersSnapshot = await db.collection('users').get();

      const notifications: Promise<string>[] = [];

      for (const userDoc of usersSnapshot.docs) {
        const user = userDoc.data();
        const fcmToken = user.fcmToken;

        if (!fcmToken) continue;

        const userEntry = entries.find((e: any) => e.userId === userDoc.id);
        if (!userEntry) continue;

        const currentRank = userEntry.rank;
        const targetRank = Math.max(currentRank - 5, 1);
        const usersAhead = currentRank - targetRank;

        const message = {
          notification: {
            title: 'あと何人で上位に？',
            body: `あと${usersAhead}人抜けば${targetRank}位🏃`,
          },
          data: {
            type: 'rank_notification',
            currentRank: currentRank.toString(),
            targetRank: targetRank.toString(),
          },
          token: fcmToken,
        };

        notifications.push(messaging.send(message as admin.messaging.Message));
      }

      const results = await Promise.allSettled(notifications);
      const successful = results.filter((r) => r.status === 'fulfilled').length;

      functions.logger.info(
        `Notifications sent: ${successful}/${notifications.length}`
      );
    } catch (error) {
      functions.logger.error('Error scheduling notifications:', error);
    }
  });
