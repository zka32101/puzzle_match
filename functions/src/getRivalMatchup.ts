import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

interface RivalEntry {
  userId: string;
  userName: string;
  rank: number;
  todayTime?: number;
  country?: string;
  isSelf?: boolean;
}

export const getRivalMatchup = functions
  .region('asia-northeast1')
  .https.onCall(async (data: { puzzleId?: string }, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Login required');
    }

    const userId = context.auth.uid;
    const today = new Date().toISOString().split('T')[0];
    const puzzleId = data.puzzleId ?? `puzzle_1`;

    const leaderboardDoc = await db
      .collection('leaderboards')
      .doc(`${puzzleId}_${today}_global`)
      .get();

    if (!leaderboardDoc.exists) {
      return { rivals: [], mode: 'empty' };
    }

    const entries: any[] = leaderboardDoc.data()?.entries ?? [];
    const dau = entries.length;

    const userEntry = entries.find((e: any) => e.userId === userId);
    const userRank = userEntry?.rank ?? entries.length + 1;

    // DAU < 1000: 前後ランク表示（フォールバックモード）
    const range = 2;
    const rangeEntries = entries.filter(
      (e: any) => Math.abs(e.rank - userRank) <= range
    );

    const rivals: RivalEntry[] = rangeEntries.map((e: any) => ({
      userId: e.userId,
      userName: e.userName ?? 'Player',
      rank: e.rank,
      todayTime: e.timeSeconds,
      country: e.country ?? null,
      isSelf: e.userId === userId,
    }));

    // 自分がリストにいない場合追加
    if (!rivals.find((r) => r.isSelf)) {
      const userDoc = await db.collection('users').doc(userId).get();
      rivals.push({
        userId,
        userName: userDoc.data()?.userName ?? 'あなた',
        rank: userRank,
        isSelf: true,
      });
      rivals.sort((a, b) => a.rank - b.rank);
    }

    return {
      rivals,
      mode: dau >= 1000 ? 'league' : 'rank_neighbors',
      dau,
    };
  });
