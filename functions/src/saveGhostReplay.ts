import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

interface InputLogEntry {
  relativeTimeMs: number;
  action: string;
  value: string;
}

interface SaveGhostReplayRequest {
  puzzleId: string;
  timeSeconds: number;
  rank: number;
  inputLog: InputLogEntry[];
}

export const saveGhostReplay = functions
  .region('asia-northeast1')
  .https.onCall(async (data: SaveGhostReplayRequest, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Login required');
    }

    const userId = context.auth.uid;
    const { puzzleId, timeSeconds, rank, inputLog } = data;

    // 7日後に削除
    const replayableUntil = new Date();
    replayableUntil.setDate(replayableUntil.getDate() + 7);

    const userDoc = await db.collection('users').doc(userId).get();
    const userName = userDoc.data()?.userName ?? 'Unknown';

    await db
      .collection('ghost_replays')
      .doc(`${puzzleId}_${userId}`)
      .set({
        userId,
        userName,
        rank,
        timeSeconds,
        inputLog,
        recordedAt: admin.firestore.FieldValue.serverTimestamp(),
        replayableUntil: admin.firestore.Timestamp.fromDate(replayableUntil),
      });

    return { success: true };
  });

export const getGhostReplays = functions
  .region('asia-northeast1')
  .https.onCall(async (data: { puzzleId: string; userId: string }, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Login required');
    }

    const { puzzleId, userId } = data;

    // 対象ユーザーのランク取得
    const today = new Date().toISOString().split('T')[0];
    const leaderboardDoc = await db.collection('leaderboards').doc(`${puzzleId}_${today}_global`).get();

    if (!leaderboardDoc.exists) {
      return { replays: [] };
    }

    const entries = leaderboardDoc.data()?.entries ?? [];
    const userEntry = entries.find((e: any) => e.userId === userId);
    const userRank = userEntry?.rank ?? 999;

    // 前後2ランクのリプレイを取得
    const targetRanks = [userRank - 2, userRank - 1, userRank + 1, userRank + 2].filter(
      (r) => r > 0
    );

    const replays: any[] = [];
    for (const entry of entries) {
      if (targetRanks.includes(entry.rank)) {
        const replayDoc = await db
          .collection('ghost_replays')
          .doc(`${puzzleId}_${entry.userId}`)
          .get();
        if (replayDoc.exists) {
          replays.push({ ...replayDoc.data(), id: replayDoc.id });
        }
      }
    }

    return { replays };
  });
